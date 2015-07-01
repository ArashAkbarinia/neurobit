function [L,logpl_Y] = rosenberg(image,mask,logemp,varargin)

% [L,logpl_Y] = rosenberg(image,inputformat,logemp)
% [L,logpl_Y] = rosenberg(image)
%
% estimates the illuminant based on the method from the paper "Bayesian
% Color Constancy with Non-Gaussian Models". 
%
% where
%       image - is the mxnx3 image 
%       inputformat - 'linearrgb','srgb'(default),etc. 
%
%       L - is the estimated illuminant in linearRGB space (!)
%       logpl_X - is the posterior distribution over the illuminant set
%                 given the image Y 
%
% Peter Gehler

fittoopt = 0;
scaledown = 1;
max_lrlglb = 6;
step_lrlglb = 0.1;
posteriormean = 1;
scale_down_factor = 3;

for i=1:2:nargin-3
    eval(sprintf('%s = varargin{%d+1};',varargin{i},i));
end

if isinteger(image)
    image = double(image);
end

if ~exist('mask','var')
    mask = zeros(size(image,1),size(image,2));
end

if ~exist('lambda','var')
    lambda = Inf;
end

if ~exist('eta','var')
    eta = 1;
end

dark_pixel = 8;

if max(image(:))<=1
    dark_pixel = dark_pixel/255;
    mask(max(image,[],3)>=1) = 1;
else
    mask(max(image,[],3)>=255) = 1;
end
mask = mask | sum(image,3)<dark_pixel;



if (scaledown)
    if ndims(image) == 3 && scale_down_factor ~= 0
	for i=1:3
	    II(:,:,i) = convolve2(double(image(:,:,i)),ones(scale_down_factor,scale_down_factor)/scale_down_factor^2,'same');
	end
	image = II(2:scale_down_factor:end,2:scale_down_factor:end,:);
	mask = mask(2:scale_down_factor:end,2:scale_down_factor:end,:);
	clear II;
    end
end

if ndims(image) == 3
    [n1,n2,n3] = size(image); 
    image = reshape(image,n1*n2,n3);
    mask = reshape(mask,n1*n2,1);
end

image(mask,:) = [];

image = srgb2rgb(image);

if ~exist('prior','var')
    fprintf('loading the standard set of illuminants\n');
    % The set of possible illumintants
    load('train_rg.mat','train_rg');
    prior = train_rg;
end

nIllums = size(prior,1);

if size(prior,2) ~= 2
    prior = prior';
end
if size(prior,2) ~= 2
    error('prior given in wrong format');
end

min_lr = max(image(:,1));
min_lg = max(image(:,2));
min_lb = max(image(:,3));

min_lrlglb = min_lr + min_lg + min_lb;

%logp_l = - log(numel(0:step_lrlglb:max_lrlglb) * nIllums);


if fittoopt
    nBins = 32;

    J = rgbscaling(image,rg,'d65','rgb');
    J = J./max(J(:));
    emp = mex_histc(J,nBins);
    logemp = mexlog(emp+1e-9);
    logemp = logemp - sumlogs(logemp,2);
end

brightness = step_lrlglb:step_lrlglb:max_lrlglb;
[ignore,min_brightness_indx] = max(brightness > min_lrlglb);

pos_emp = logemp~=-Inf;

if ~exist('logp_l','var')
    logp_l = zeros(nIllums,1);
end


logpl_Y = -Inf * ones(numel(brightness),nIllums);
N = size(image,1);
clear Lr Lg Lb
for j=1:nIllums
    
    for k=min_brightness_indx:numel(brightness)

        lrlglb = brightness(k);

        l1 = prior(j,1);
        lr = l1 * lrlglb;
        if lr < min_lr
            continue;
        end

        l2 = prior(j,2);
        lg = l2 * lrlglb;
        if lg < min_lg
            continue;
        end

        lb = lrlglb-lr-lg;
        if lb < min_lb 
            continue;
        end
	
        Lr(k,j) = lr;
        Lg(k,j) = lg;
        Lb(k,j) = lb;
        
        X = image * diag(1./[lr,lg,lb]);

	% estimate log(p(X)), if lambda==Inf, usual thresholding,
        % otherwise soft clipping is applied
	logp = logp_X(X,logemp,lambda);
	
	% compute p(l|Y)
	logpl_Y(k,j) = eta*(-N *mexlog(prod([lr,lg,lb])+1e-9) + logp) + logp_l(j);

    end
end

logpl_Y(:,size(Lr,2)+1:end) = [];

logpl_Y = logpl_Y - sumlogs(logpl_Y(:));
logp = logpl_Y(:);

Lr = Lr(:);
Lg = Lg(:);
Lb = Lb(:);


if posteriormean

    % compute the posterior mean of the estimates
    L(1) = exp(sumlogs(mexlog(Lr+1e-9) + logp));
    L(2) = exp(sumlogs(mexlog(Lg+1e-9) + logp));
    L(3) = exp(sumlogs(mexlog(Lb+1e-9) + logp));

else 
    fprintf('max likelihood solution');
    [ignore,ind]= max(logp);
    L(1) = Lr(ind);
    L(2) = Lg(ind);
    L(3) = Lb(ind);
end

