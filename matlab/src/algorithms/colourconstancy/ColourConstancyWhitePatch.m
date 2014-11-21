function ColourConstantImage = ColourConstancyWhitePatch(InputImage)
%ColourConstancyWhitePatch applies the white patch algorithm to the input.
%
% Inputs
%   InputImage  the input image.
%
% Outputs
%   ColourConstantImage  the colour constant image in range of [0, 1].
%
% Examples
%   im = imread('peppers.png');
%   imout = ColourConstancyWhitePatch(im);
%   figure; imshow(uint8(imout .* 255));
%
% See also: ColourConstancy
%

InputImage = im2double(InputImage);

immax = max(max(InputImage));
k = 1.0 / immax;

ColourConstantImage = MatChansMulK(InputImage, k);

end
