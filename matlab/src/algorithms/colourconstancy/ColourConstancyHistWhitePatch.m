function [ColourConstantImage, luminance] = ColourConstancyHistWhitePatch(InputImage, nbins)
%ColourConstancyHistWhitePatch  applies the modified white patch algorithm.
%   Explanation Ebner 2007, "Color Constancy"
%
% Inputs
%   InputImage  the input image.
%   nbins       number of discrete grey levels, default is 256.
%
% Outputs
%   ColourConstantImage  the colour constant image in range of [0, 1].
%   luminance            the estimated luminance of the scene.
%
% Examples
%   im = imread('peppers.png');
%   imout = ColourConstancyHistWhitePatch(im);
%   figure; imshow(uint8(imout .* 255));
%
% See also: ColourConstancyWhitePatch, ColourConstancy
%

if nargin < 2
  nbins = 256;
end

InputImage = im2double(InputImage);
[rows, cols, chns] = size(InputImage);
npixels = rows * cols;

CutoffPerce = 0.01;
CutoffValue = CutoffPerce * npixels;

luminance = zeros(1, 3);
for i = 1:chns
  ichan = InputImage(:, :, i);
  ihist = imhist(ichan, nbins);
  
  luminance(1, i) = 1;
  jpixels = 0;
  for j = nbins:-1:1
    jpixels = ihist(j) + jpixels;
    if jpixels >= CutoffValue
      luminance(1, i) = j ./ nbins;
      break;
    end
  end
end

ColourConstantImage = MatChansMulK(InputImage, 1.0 ./ luminance);

end
