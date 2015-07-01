function [logemp,emp] = calc_reflectance_distr_em(imdir,Xfiles,varargin)


br = 1:0.1:6;
maxiter = 20;
wbsetting = 'autowb';
space = 'rgb';
nBins = 32;
dark_pixel = 8;
ind = Inf; % use all images
proxy = 'gt';
use_clipping = 0;
method = 'empirical';

for i=1:2:nargin-2
    eval(sprintf('%s = varargin{%d+1};',varargin{i},i));
end

Ltrue = load_gt(Xfiles,imdir);
outdoor = load_outdoor_label(Xfiles);

warning off
addpath ~/colorconstancy/colorspaces
addpath ~/colorconstancy/rosenberg
warning on

emp = zeros(1,nBins^3);

fprintf('estimating reflectance distribution...\n');
fprintf('with brigthness reestimation!\n');
fprintf('\tin color space %s\n',space);
if use_clipping
    fprintf('\tusing clipping\n');
end
switch proxy
 case 'gt'
  fprintf('\tusing Ground Truth data\n');
 case 'sbm'
  fprintf('\tusing Scale-By-Max as a proxy\n');
end

tic
for i=1:numel(Xfiles)

    fname = Xfiles{i};
    [I,mask] = read_image(fname,imdir);

    figure(1); clf;
    imagesc(I.*repmat(mask,[1,1,3]))
    drawnow;
    
    [n1,n2,n3] = size(I);
    I = reshape(I,n1*n2,n3);
    mask = mask(:);
    I(mask>0,:) = [];
    
    ind = find(max(I,[],2) == 255);
    I(ind,:) = [];

    ind = find(sum(I,2)<dark_pixel);
    I(ind,:) = [];

    switch proxy
     case 'gt'
      J = rgbscaling(srgb2rgb(I),Ltrue(i,:),'d65','rgb');
      J = J./max(J(:));
     case 'sbm'
      J = srgb2rgb(I);
      L = max(J);
      J = J * diag(1./L);
     otherwise
      error('no such proxy');
    end
    
    h = mex_histc(J,nBins)';
    h = double(h);
    
    if use_clipping
	h(h>1) = 1;
    end

    emp = emp + h(:)';

    % compute the histograms for all possible brightnesses
    for k=1:numel(br)
	im = J/br(k);
	h = mex_histc(im,nBins)';
	hists{i,k} = sparse(double(h));
    end
    
    if ~mod(i,100)
	fprintf('%d of %d done\n',i,numel(Xfiles));
	toc
	tic
    end
end
fprintf('%d of %d done\n',i,numel(Xfiles));
toc

bestBr_old = ones(numel(Xfiles),1);
empnew = emp;

switch method
 case 'empirical'

  for tt=1:maxiter
      bestBr = [];
      logemp = mexlog(empnew+1e-9);
      logemp = logemp - sumlogs(logemp,2);
      nrmemp = empnew./sum(empnew(:));
      empnew = 0;
      for i=1:numel(Xfiles)


	  for k=1:numel(br)
	      % histogram for this brightness
	      h = full(hists{i,k});
	      
	      % ... and the difference to the estimated one
	      if (0)
		  %h = hists{i,k};
		  h = mexlog(h+1e-9);
		  h = h-sumlogs(h,2);
		  err(k) = sumlogs(2*(logemp./h),2);
	      else
		  h = h./sum(h(:));
		  err(k) = sum( (nrmemp-h).^2);
	      end
	  end

	  %... choose best fit
	  err=err+1e-9*randn(size(err));
	  [ignore,bestBr(i,1)] = min(err);

	  h = full(hists{i,bestBr(i)});
	  
	  empnew = empnew + h(:)';
      end
      
      changed = sum(bestBr_old~=bestBr);
      c = hist(bestBr,1:numel(br));
      c
      fprintf('brightness changed: %d\n',changed);
      if changed == 0
	  break;
      end
      
      bestBr_old = bestBr;
      
  end
 case 'maxlogp'
  
  % MAXIMIZE LOGPOSTERIOR

  for tt=1:maxiter
      selected_br = [];
      logemp = mexlog(empnew+1e-9);
      logemp = logemp - sumlogs(logemp,2);
      empnew = 0;
      for i=1:numel(Xfiles)

	  for k=1:numel(br)
	      if (1)
		  h = full(hists{i,k});
	      else
		  im = images{i}/br(k);
		  h = mex_histc(im,nBins)';
		  hists{k} = h;
	      end
	      n = sum(h(:)); % number of pixels
	      logprod = log(prod(br(k) * Ltrue(k,:)));
	      logp(k) = -logprod + sum(logemp(h>0))/sum(h>0);
	  end
	  [ignore,selected_br(i,1)] = max(logp);
	  if(0)
	      h = hists{selected_br(i,1)};
	  else
	      h = full(hists{i,selected_br(i,1)});
	  end
	  empnew = empnew + h(:)';
      end
      changed = sum(selected_old~=selected_br);
      c = hist(selected_br,1:numel(br));
      c
      fprintf('brightness changed: %d\n',changed);
      if changed == 0
	  break;
      end
      
      selected_old = selected_br;
      
  end

  
 otherwise
  error('no such method');
end


emp = empnew;


logemp = mexlog(emp+1e-9);
logemp = logemp - sumlogs(logemp,2);

warning('on','MATLAB:dispatcher:pathWarning');
warning('on','MATLAB:rmpath:DirNotFound');
