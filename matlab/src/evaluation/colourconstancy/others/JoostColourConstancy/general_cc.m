% general_cc: estimates the light source of an input_image. 
%
% Depending on the parameters the estimation is equal to Grey-Wolrd, Max-RGB, general Grey-World,
% Shades-of-Gray or Grey-Edge algorithm.
%
% SYNOPSIS:
%    [white_R ,white_G ,white_B,output_data] = general_cc(input_data,njet,mink_norm,sigma,mask_im)
%    
% INPUT :
%   input_data    : color input image (NxMx3)
%	njet          : the order of differentiation (range from 0-2). 
%	mink_norm     : minkowski norm used (if mink_norm==-1 then the max
%                   operation is applied which is equal to minkowski_norm=infinity).
%   mask_im       : binary images with zeros on image positions which
%                   should be ignored.
% OUTPUT: 
%   [white_R,white_G,white_B]           : illuminant color estimation
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

function [white_R ,white_G ,white_B] = general_cc(input_data,njet,mink_norm,sigma,mask_im)

InputImage = input_data;

if(nargin<2), njet=0; end
if(nargin<3), mink_norm=1; end
if(nargin<4), sigma=1; end
if(nargin<5), mask_im=zeros(size(input_data,1),size(input_data,2)); end

% remove all saturated points
saturation_threshold = 1;
mask_im2 = mask_im + (dilation33(double(max(input_data,[],3)>=saturation_threshold)));   
mask_im2=double(mask_im2==0);
mask_im2=set_border(mask_im2,sigma+1,0);
% the mask_im2 contains pixels higher saturation_threshold and which are
% not included in mask_im.

% output_data=input_data;

if(njet==0)
   if(sigma~=0)
     for ii=1:3
        input_data(:,:,ii)=gDer(input_data(:,:,ii),sigma,0,0);
     end
   end
end

if(njet>0)
    [Rx,Gx,Bx]=norm_derivative(input_data, sigma, njet);
%     [Rx,Gx,Bx]=norm_derivative_arash(input_data, sigma, njet);
    
    input_data(:,:,1)=Rx;
    input_data(:,:,2)=Gx;
    input_data(:,:,3)=Bx;    
end

input_data=abs(input_data);

if(mink_norm~=-1)          % minkowski norm = (1,infinity >
    kleur=power(input_data,mink_norm);
 
    white_R = power(sum(sum(kleur(:,:,1).*mask_im2)),1/mink_norm);
    white_G = power(sum(sum(kleur(:,:,2).*mask_im2)),1/mink_norm);
    white_B = power(sum(sum(kleur(:,:,3).*mask_im2)),1/mink_norm);

    som=sqrt(white_R^2+white_G^2+white_B^2);

    white_R=white_R/som;
    white_G=white_G/som;
    white_B=white_B/som;
else                    %minkowski-norm is infinit: Max-algorithm     
    R=input_data(:,:,1);
    G=input_data(:,:,2);
    B=input_data(:,:,3);
    
    white_R=max(R(:).*mask_im2(:));
    white_G=max(G(:).*mask_im2(:));
    white_B=max(B(:).*mask_im2(:));
    
    som=sqrt(white_R^2+white_G^2+white_B^2);

    white_R=white_R/som;
    white_G=white_G/som;
    white_B=white_B/som;
end

% ARASH
% InputImage = InputImage ./ max(InputImage(:));
% luminance = CalculateLuminance(input_data, InputImage);
% white_R = luminance(1);
% white_G = luminance(2);
% white_B = luminance(3);

% output_data(:,:,1)=output_data(:,:,1)/(white_R*sqrt(3));
% output_data(:,:,2)=output_data(:,:,2)/(white_G*sqrt(3));
% output_data(:,:,3)=output_data(:,:,3)/(white_B*sqrt(3));

end

function luminance = CalculateLuminance(dtmap, InputImage)

% to make the comparison exactly like Joost's Grey Edges
SaturationThreshold = max(InputImage(:));
DarkThreshold = min(InputImage(:));
MaxImage = max(InputImage, [], 3);
MinImage = min(InputImage, [], 3);
SaturatedPixels = dilation33(double(MaxImage >= SaturationThreshold | MinImage <= DarkThreshold));
SaturatedPixels = double(SaturatedPixels == 0);
sigma = 2;
SaturatedPixels = set_border(SaturatedPixels, sigma + 1, 0);

for i = 1:3
  dtmap(:, :, i) = dtmap(:, :, i) .* (dtmap(:, :, i) > 0);
  dtmap(:, :, i) = dtmap(:, :, i) .* SaturatedPixels;
end

% MaxVals = max(max(dtmap));

CentreSize = 3;
dtmap = dtmap ./ max(dtmap(:));
StdImg = LocalStdContrast(dtmap, CentreSize);
Cutoff = mean(StdImg(:));
dtmap = dtmap .* ((2 ^ 8) - 1);
% MaxVals = PoolingHistMax(dtmap, Cutoff, false);
for i = 1:3
  tmp = dtmap(:, :, i);
  tmp = tmp(SaturatedPixels == 1);
  MaxVals(1, i) = PoolingHistMax2(tmp(:), Cutoff, false);
end

% MaxVals = ColourConstancyMinkowskiFramework(dtmap, 5);

luminance = MaxVals;

end

function HistMax = PoolingHistMax2(InputImage, CutoffPercent, UseAveragePixels)

if nargin < 3
  UseAveragePixels = false;
end

npixels = length(InputImage);
HistMax = zeros(1, 1);

MaxVal = max(InputImage(:));
if MaxVal == 0
  return;
end

if MaxVal < (2 ^ 8)
  nbins = 2 ^ 8;
elseif MaxVal < (2 ^ 16)
  nbins = 2 ^ 16;
end

if nargin < 2 || isempty(CutoffPercent)
  CutoffPercent = 0.01;
end

LowerMaxPixels = CutoffPercent .* npixels;
% setting the upper bound to 50% bigger than the lower bound, this means we
% try to find the final HistMax between the lower and upper bounds. However
% if we don't succeed we choose the closest value to the lower bound.
UpperMaxPixels = LowerMaxPixels * 1.5;

for i = 1:1
  ichan = InputImage;
  [ihist, centres] = hist(ichan(:), nbins);
  
  HistMax(1, i) = centres(end);
  jpixels = 0;
  for j = nbins - 1:-1:1
    jpixels = ihist(j) + jpixels;
    if jpixels > LowerMaxPixels(i)
      if jpixels > UpperMaxPixels
        % if we have passed the upper bound, final HistMax is the one
        % before the lower bound.
        HistMax(1, i) = centres(j + 1);
        if UseAveragePixels
          AllBiggerPixels = ichan(ichan >= centres(j + 1));
          HistMax(1, i) = mean(AllBiggerPixels(:));
        end
      else
        HistMax(1, i) = centres(j);
        if UseAveragePixels
          AllBiggerPixels = ichan(ichan >= centres(j));
          HistMax(1, i) = mean(AllBiggerPixels(:));
        end
      end
      break;
    end
  end
end

end