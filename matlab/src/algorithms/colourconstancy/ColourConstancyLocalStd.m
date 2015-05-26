function [ColourConstantImage, luminance] = ColourConstancyLocalStd(InputImage, CentreSize)
%ColourConstancyLocalStd  applies colour constancy with local std.
%
% inputs
%   InputImage  the input image.
%
% outputs
%   ColourConstantImage  the colour constant image in range of [0, 1].
%   luminance            the estimated luminance of the scene.
%
% Examples
%   im = imread('peppers.png');
%   imout = ColourConstancyLocalStd(im);
%   figure; imshow(uint8(imout .* 255));
%
% See also: ColourConstancy
%

if nargin < 2
  CentreSize = 11;
end

InputImage = double(InputImage);

ImageContrast = LocalStdContrast(InputImage, CentreSize);

luminance = max(max(ImageContrast));
luminance = reshape(luminance, 1, 3);
ColourConstantImage = MatChansMulK(InputImage, 1.0 ./ luminance);

end
