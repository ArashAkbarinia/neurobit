function [ColourConstantImage, luminance] = ColourConstancyHistWhitePatch(InputImage, CutoffPercentage)
%ColourConstancyHistWhitePatch  applies the modified white patch algorithm.
%   Explanation Ebner 2007, "Color Constancy"
%
% Inputs
%   InputImage        the input image in RGB colour space, i.e. range
%                     [0, 255].
%   CutoffPercentage  the cut off percentage, default is 0.01.
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
  CutoffPercentage = 0.01;
end

InputImage = double(InputImage);

luminance = PoolingHistMax(InputImage, CutoffPercentage);

ColourConstantImage = MatChansMulK(InputImage, 1.0 ./ luminance);

end
