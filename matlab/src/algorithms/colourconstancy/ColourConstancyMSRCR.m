function ColourConstantImage = ColourConstancyMSRCR(InputImage, alpha, beta)
%ColourConstancyMSRCR applies multiscale retinex with color restoration.
%
% Inputs
%   InputImage  the input image.
%   alpha       controls the strength of nonlinearity.
%   beta        is a gain constant.
%
% Outputs
%   ColourConstantImage  the colour constant image in range of [0, 1].
%
% Examples
%   im = imread('peppers.png');
%   imout = ColourConstancyMSRCR(im);
%   figure; imshow(uint8(imout .* 255));
%
% See also: ColourConstancy, ColourConstancySingleScaleRetinex,
%           ColourConstancyMultiScaleRetinex
%

if nargin < 2
  alpha = 85;
  beta = 0.9;
end

InputImage = im2double(InputImage);
[~, ~, chns] = size(InputImage);

MultiScaleRetinex = ColourConstancyMultiScaleRetinex(InputImage);

ImageSum = sum(InputImage, 3);
for i = 2:chns
  ImageSum(:, :, i) = ImageSum(:, :, 1);
end

c = beta .* (log(alpha .* InputImage) - log(ImageSum));

ColourConstantImage = c .* MultiScaleRetinex;

end
