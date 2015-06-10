function [ColourConstantImage, luminance] = ColourConstancyWhitePatch(InputImage)
%ColourConstancyWhitePatch applies the white patch algorithm to the input.
%   Explanation Ebner 2007, "Color Constancy"
%
% Inputs
%   InputImage  the input image.
%
% Outputs
%   ColourConstantImage  the colour constant image in range of [0, 1].
%   luminance            the estimated luminance of the scene.
%
% Examples
%   im = imread('peppers.png');
%   imout = ColourConstancyWhitePatch(im);
%   figure; imshow(uint8(imout .* 255));
%
% See also: ColourConstancy
%

InputImage = double(InputImage);

luminance = max(max(InputImage));
luminance = reshape(luminance, 1, 3);
ColourConstantImage = MatChansMulK(InputImage, 1.0 ./ luminance);

end
