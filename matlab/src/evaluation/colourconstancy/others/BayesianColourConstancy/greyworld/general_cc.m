% general_cc: estimates the light source of an input_image. 
%
% Depending on the parameters the estimation is equal to Grey-Wolrd, Max-RGB, general Grey-World,
% Shades-of-Gray or Grey-Edge algorithm.
%
% SYNOPSIS:
%    [RGB,output_data] = general_cc(input_data,njet,mink_norm,sigma,mask_im)
%
% INPUT :
%   input_data    : color input image (NxMx3)
%	njet          : the order of differentiation (range from 0-2).
%	mink_norm     : minkowski norm used (if mink_norm==-1 then the max
%                   operation is applied which is equal to
%                   minkowski_norm=infinity).
% OUTPUT:
%   [RBG]           : illuminant color estimation in linear RGB!!!!
%   output_data                         : color corrected image

% LITERATURE :
%
% J. van de Weijer, Th. Gevers, A. Gijsenij
% "Edge-Based Color Constancy"
% IEEE Trans. Image Processing, accepted 2007.
%
% The paper includes references to other Color Constancy algorithms
% included in general_cc.m such as Grey-World, and max-RGB, and
% Shades-of-Gray.

function [RGB,output_data] = general_cc(input_data,njet,mink_norm,sigma,varargin)

if nargin==0
    help general_cc;
    return;
end

%
% default parameters
%
if(nargin<2), njet=0; end
if(nargin<3), mink_norm=1; end
if(nargin<4), sigma=1; end
clip = 0;
rgclip = 0;
inputformat = 'srgb';
where = 'rgb';
eta = 1; % posterior : likelihood^eta * prior
scale_w = ones(3,1);

%
% parse input arguments
%
for i=1:2:nargin-4
    eval(sprintf('%s = varargin{%d+1};',varargin{i},i));
end

if(~exist('mask','var'))
    mask=false(size(input_data,1),size(input_data,2));
end

if njet > 0 && sigma ==0
    error('provide a derivative width');
end

if nargout > 1,output_data=input_data;end


%
% remove all saturated points
%
switch inputformat
 case 'srgb'
  saturation_threshold = 255;
 case {'rgb'}
  saturation_threshold = 1;
end 

%
% remove the border if a smoothing filter is applied
%
mask = double(mask);
mask_im2 = mask + (dilation33(double(max(input_data,[],3)>=saturation_threshold)));   
mask_im2=double(mask_im2==0);
mask_im2=set_border(mask_im2,sigma+1,0);

if(njet==0)
    if(sigma~=0)
	input_data = double(input_data);
        for ii=1:3
            input_data(:,:,ii)=gDer(input_data(:,:,ii),sigma,0,0);
        end
        input_data=abs(input_data);
    end
end

if(njet>0)
    [Rx,Gx,Bx]=norm_derivative(input_data, sigma, njet);

    input_data = double(input_data);
    input_data(:,:,1)=Rx;
    input_data(:,:,2)=Gx;
    input_data(:,:,3)=Bx;

    % trying out normalization
    %input_data = input_data-min(input_data(:));
    %input_data = input_data./max(input_data(:));
    %input_data = 255 * input_data;
    
end
input_data=abs(input_data);

[n1,n2,n3] = size(input_data);
input_data = reshape(input_data,n1*n2,n3);
%mask = reshape(mask,n1*n2,1);
%input_data(mask,:) = [];
mask_im2 = reshape(mask_im2,n1*n2,1);
input_data(mask_im2==0,:) = [];

switch inputformat
 case 'srgb';
  switch where
   case 'srgb';
    input_data = double(input_data)/255;
   case {'rgb','linrgb','linearrgb','lin'}
    input_data = srgb2rgb(input_data);
   case 'Lab'
    input_data = xyz2Lab(srgb2xyz(input_data));
    maxL = max(input_data(:,1));
    input_data = input_data(:,2:3);
   case 'Luv'
    input_data = xyz2Luv(linearrgb2xyz(srgb2rgb(input_data)));
    maxL = max(input_data(:,1));
    input_data = input_data(:,2:3);
    error('not implemented yet');
   case 'xyz'
    input_data = srgb2xyz(input_data);
   otherwise
    error('inputformat not known');
  end
 case {'rgb'}
  if ~strcmp(where,'rgb')
      error('not implemented yet');
      end
 otherwise
  error('inputformat not supported ''srgb'' or ''rgb'' ');
end

if rgclip > 0

    error('IMPLEMENT AND CHECK THIS ONE');
    
    R = round(255*input_data(:,1));
    G = round(255*input_data(:,2));
    B = round(255*input_data(:,3));

    RGB = R+G+B;
    rg(:,1)= R./RGB;
    rg(:,2)= G./RGB;
     
    [in,ind1,ind2] = unique(rg,'rows');

    meanR = mean(input_data(ind1,1));
    meanG = mean(input_data(ind1,2));
    meanB = mean(input_data(ind1,3));
    
    sumR = sum(input_data(ind1,1));
    sumG = sum(input_data(ind1,2));
    sumB = sum(input_data(ind1,3));
    
    nr_pixel = numel(ind1);
    
elseif clip>0
    
    R = round(255*input_data(:,1));
    G = round(255*input_data(:,2));
    B = round(255*input_data(:,3));
    ll = linspace(0,255,256)';
    in1 = histc(R,ll);
    in2 = histc(G,ll);
    in3 = histc(B,ll);
    
    in1(in1>clip) = clip;
    in2(in2>clip) = clip;
    in3(in3>clip) = clip;

    nr_pixel(1,1) = sum(in1);
    nr_pixel(2,1) = sum(in2);
    nr_pixel(3,1) = sum(in3);
    
    %    nr_pixel = mean(nr_pixel);
    
    ll = (1+ll)/256;

    if mink_norm ~= -1
	ll = ll.^mink_norm;
    end
    
    meanR = sum(in1.*ll)/sum(in1);
    meanG = sum(in2.*ll)/sum(in2);
    meanB = sum(in3.*ll)/sum(in3);
    
    sumR = sum(in1.*ll);
    sumG = sum(in2.*ll);
    sumB = sum(in3.*ll);
    
    
elseif clip < 0
    tclip = -clip;

    input_data = round(255 * input_data)/255;
    
    [in,ind1,ind2] = unique(input_data,'rows');
    h = hist(ind2,1:numel(ind1));
    h(h>tclip) = tclip;
    h = h';
    
    if mink_norm > 1
	in = in.^mink_norm;
    end

    nr_pixel = sum(h);

    meanR = sum(in(:,1).*h)/nr_pixel;
    meanG = sum(in(:,2).*h)/nr_pixel;
    meanB = sum(in(:,3).*h)/nr_pixel;

    sumR = meanR * nr_pixel;
    sumG = meanG * nr_pixel;
    sumB = meanB * nr_pixel;
    
    
else

    if numel(mink_norm)> 1
	if any(mink_norm<=0) 
	    error('minkowski norm must be >0');
	end
	input_data(:,1) = (scale_w(1) * input_data(:,1)).^mink_norm(1);
	input_data(:,2) = (scale_w(2) * input_data(:,2)).^mink_norm(2);
	input_data(:,3) = (scale_w(3) * input_data(:,3)).^mink_norm(3);
	R = input_data(:,1);
	G = input_data(:,2);
	B = input_data(:,3);
    elseif mink_norm == 1 
	R = input_data(:,1);
	G = input_data(:,2);
	B = input_data(:,3);
    elseif mink_norm == -1
	R = max(input_data(:,1));
	G = max(input_data(:,2));
	B = max(input_data(:,3));
    elseif mink_norm > 0
	input_data = input_data.^mink_norm;
	R = input_data(:,1);
	G = input_data(:,2);
	B = input_data(:,3);
    end	
    
    meanR = mean(R);
    meanG = mean(G);
    meanB = mean(B);

    sumR = sum(R);
    sumG = sum(G);
    sumB = sum(B);
    
    nr_pixel = size(input_data,1);

end

sumy(1) = sumR;
sumy(2) = sumG;
sumy(3) = sumB;


% Include a Gaussian Prior over the illuminant
if exist('sig2','var') 

    %checkgrad('logposterior_new',log(ones(3,1)+.1*rand(3,1)),1e-3,sumy,inv(C+1e-9*eye(size(C))),mu,sig2,size(input_data,1),mink_norm,eta)
    
    ll = minimize(log(ones(3,1)/3),'logposterior_new',100,sumy,inv(C+1e-9*eye(size(C))),mu,sig2,nr_pixel,mink_norm,eta);
    RGB = exp(ll);
  
elseif exist('mu','var') || exist('C','var')

    
    %    checkgrad('logposterior',log(ones(3,1)+.1*rand(3,1)),1e-3,sumy,inv(C+1e-9*eye(size(C))),mu,size(input_data,1),mink_norm,eta)
    
    ll = minimize(log(ones(3,1)/3),'logposterior',100,sumy,inv(C+1e-9*eye(size(C))),mu,nr_pixel,mink_norm,eta,scale_w);
    RGB = exp(ll);

    % Include a Dirichlet Prior for the illuminant
elseif exist('al','var')
    
    if mink_norm==1
        sumy = sum(input_data);
    elseif mink_norm < 0
    else
        sumy = sum(input_data.^mink_norm);
    end

    %checkgrad('logposterior_dirichlet',log(ones(3,1)/3),1e-3,sumy,al,size(input_data,1),mink_norm)

    ll = minimize(log(ones(3,1)/3),'logposterior_dirichlet',100,sumy,al,size(input_data,1),mink_norm,eta);
    RGB = exp(ll);

    %
    % Common Greyworld algorithm
    %
else

    if(mink_norm==-1)          % minkowski norm = 1 (Greyworld)
	RGB(1) = max(R(:));
	RGB(2) = max(G(:));
	RGB(3) = max(B(:));

    elseif (mink_norm==-2) % Tobys median algorithm

        RGB = median(input_data);

    else % minkowski norm = (1,infinity >

	if numel(mink_norm)>1
	    RGB(1) = meanR.^(1/mink_norm(1));
	    RGB(2) = meanG.^(1/mink_norm(2));
	    RGB(3) = meanB.^(1/mink_norm(3));
	else
	    RGB(1) = meanR.^(1/mink_norm);
	    RGB(2) = meanG.^(1/mink_norm);
	    RGB(3) = meanB.^(1/mink_norm);
	end
        %color=input_data.^mink_norm;
        %RGB = (sum(color)/size(input_data,1)).^(1/mink_norm);

	% corresponding rosenberg: 
	%ll = minimize(log(ones(3,1)/3),'logposterior',100,sumy,0,0,nr_pixel,mink_norm,eta);

    end
end

switch where
 case 'Lab'
  RGB = [maxL ,RGB]; % it is crucial which luminance is estimated
  RGB = double(squeeze(xyz2rgb(Lab2xyz(RGB))));
 case 'srgb'
  %RGB = srgb2rgb(RGB);
 otherwise
end



if nargout > 1

    error('Need to implement a correct version');
    
    output_data = double(output_data);

    output_data(:,:,1)=output_data(:,:,1)/(RGB(1)*sqrt(3));
    output_data(:,:,2)=output_data(:,:,2)/(RGB(2)*sqrt(3));
    output_data(:,:,3)=output_data(:,:,3)/(RGB(3)*sqrt(3));
end
