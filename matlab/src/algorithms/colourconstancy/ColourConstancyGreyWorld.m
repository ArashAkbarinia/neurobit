function ColourConstantImage = ColourConstancyGreyWorld(InputImage, ScaleFactor)
%ColourConstancyGreyWrold  applies the grey world algorithm to the input.
%   Explanation http://en.wikipedia.org/wiki/Color_normalization#Grey_world
%
% Inputs
%   InputImage   the input image.
%   ScaleFactor  the scale factor, default is average intensity value.
%
% Outputs
%   ColourConstantImage  the colour constant image in range of [0, 1].
%
% Examples
%   im = imread('peppers.png');
%   imout = ColourConstancyGreyWorld(im);
%   figure; imshow(uint8(imout .* 255));
%
% See also: ColourConstancy
%

InputImage = im2double(InputImage);

immean = mean(mean(InputImage));

if nargin < 2
  ScaleFactor = mean(immean);
end

k = ScaleFactor / immean;

ColourConstantImage = MatChansMulK(InputImage, k);

end
