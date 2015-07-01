%
% Calculate the empirical reflectance distribution for the images
% 'Xfiles' in the directory 'imdir'
%
function [logemp,emp] = calc_reflectance_distr(imdir,Xfiles,varargin)

method = 'empirical'; % or ml (maximum likelihood)
nBins = 32;
dark_pixel = 8;
ind = Inf; % use all images
proxy = 'gt';
use_clipping = 0;
lambda = Inf;

for i=1:2:nargin-2
    eval(sprintf('%s = varargin{%d+1};',varargin{i},i));
end

Ltrue = load_gt(Xfiles,imdir);
outdoor = load_outdoor_label(Xfiles);

warning('off','MATLAB:dispatcher:pathWarning');
addpath ~/projects/colorconstancy/colorspaces
addpath ~/projects/colorconstancy/rosenberg
warning('on','MATLAB:dispatcher:pathWarning');

emp = zeros(1,nBins^3);
if strcmp(method,'ml')
    a_k = zeros(1,nBins^3);
end

fprintf('estimating reflectance distribution...\n');
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

    imagesc(I.*repmat(mask,[1,1,3]))

    [n1,n2,n3] = size(I);
    I = reshape(I,n1*n2,n3);
    mask = mask(:);
    I(mask>0,:) = [];

    % remove saturated pixels...
    ind = find(max(I,[],2) == 255);
    I(ind,:) = [];

    % ... and dark pixels
    ind = find(sum(I,2)<dark_pixel);
    I(ind,:) = [];

    switch proxy
     case 'nocc'
      J = srgb2rgb(I);
      error('probably scaling ?');
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

    % use a soft-clipping
    if ~isinf(lambda)
	h = tanh(lambda * h);
    end
    
    
    emp = emp + h(:)';
    switch method
     case 'ml'
      h=h>0;
      h = h./sum(h(:));
      a_k = a_k + size(J,1) *h;
    end
    
    if ~mod(i,100)
	fprintf('%d of %d done\n',i,numel(Xfiles));
	toc
	tic
    end
end
fprintf('%d of %d done\n',i,numel(Xfiles));
toc


switch method
 case 'empirical'
  logemp = mexlog(emp+1e-9);
  logemp = logemp - sumlogs(logemp,2);
 case 'ml'
  logemp = mexlog(emp+1e-9);
  logemp = logemp-sumlogs(logemp,2);
  
 otherwise 
  error('no such method');
end


warning('on','MATLAB:dispatcher:pathWarning');
warning('on','MATLAB:rmpath:DirNotFound');
