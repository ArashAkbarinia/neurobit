function ColourConstantImage = ColourConstancyHisteq(InputImage, nbins)
%ColourConstancyHisteq applies histogram equalisation to value channel.
%   This function converts the image to HSV colour space and apply the
%   histeq to the value channel.
%
% Inputs
%   InputImage  the input image.
%   nbins       number of discrete grey levels, default is 8.
%
% Outputs
%   ColourConstantImage  the histogram equalised image in range of [0, 1].
%
% Examples
%   im = imread('peppers.png');
%   imout = ColourConstancyHisteq(im, 8);
%   figure; imshow(uint8(imout .* 255));
%
% See also: ColourConstancy
%

if nargin < 2
  nbins = 8;
end

InputImage = im2double(InputImage);

hsvim = rgb2hsv(InputImage);

hsvim(:, :, 3) = histeq(hsvim(:, :, 3), nbins);

ColourConstantImage = hsv2rgb(hsvim);

end
