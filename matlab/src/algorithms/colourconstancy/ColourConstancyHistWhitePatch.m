function [ColourConstantImage, luminance] = ColourConstancyHistWhitePatch(InputImage, CutoffPercentage)
%ColourConstancyHistWhitePatch  applies the modified white patch algorithm.
%   Explanation Ebner 2007, "Color Constancy"
%
% Inputs
%   InputImage        the input image in RGB colour space, i.e. range
%                     [0, 255].
%   CutoffPercentage  the cut off percentage, default is 0.01. if passed -1
%                     it calculates it authomatically based on local std.
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

InputImage = im2double(InputImage);

if nargin < 2
  CutoffPercentage = 0.01;
elseif CutoffPercentage < 0
  LocalStd = mean(mean(LocalStdContrast(InputImage, 3)));
  LocalStd = reshape(LocalStd, 1, 3);
  CutoffPercentage = mean(LocalStd);
end

luminance = PoolingHistMax(InputImage, CutoffPercentage);

ColourConstantImage = MatChansMulK(InputImage, 1.0 ./ luminance);

ColourConstantImage = NormaliseChannel(ColourConstantImage);

end
