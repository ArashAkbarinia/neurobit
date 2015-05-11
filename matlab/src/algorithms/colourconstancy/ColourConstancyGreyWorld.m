function [ColourConstantImage, luminance] = ColourConstancyGreyWorld(InputImage, ScaleFactor)
%ColourConstancyGreyWrold  applies the grey world algorithm to the input.
%   Explanation http://en.wikipedia.org/wiki/Color_normalization#Grey_world
%
% inputs
%   InputImage   the input image.
%   ScaleFactor  the scale factor, default is average intensity value.
%
% outputs
%   ColourConstantImage  the colour constant image in range of [0, 1].
%   luminance            the estimated luminance of the scene.
%
% Examples
%   im = imread('peppers.png');
%   imout = ColourConstancyGreyWorld(im);
%   figure; imshow(uint8(imout .* 255));
%
% See also: ColourConstancy
%

InputImage = im2double(InputImage);

luminance = mean(mean(InputImage));
luminance = reshape(luminance, 1, 3);

if nargin < 2
  ScaleFactor = mean(luminance);
end

k = ScaleFactor ./ luminance;

ColourConstantImage = MatChansMulK(InputImage, k);

end
