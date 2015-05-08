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

CutoffPercentage = 0.01;
luminance = PoolingHistMax(InputImage, nbins, CutoffPercentage, 1);

ColourConstantImage = MatChansMulK(InputImage, 1.0 ./ luminance);

end
