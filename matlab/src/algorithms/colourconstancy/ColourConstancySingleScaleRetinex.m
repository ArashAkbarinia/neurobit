function ColourConstantImage = ColourConstancySingleScaleRetinex(InputImage, sigma)
%ColourConstancySingleScaleRetinex applies Retinex algorithm.
%   Explanation
%   http://dragon.larc.nasa.gov/background/pubabs/papers/gspx1.pdf
%
% Inputs
%   InputImage  the input image.
%   sigma       the sigma of Gaussian kernel, typically ranging from 50 to
%               120, are normally used to produce good single-scale Retinex
%               performance. Default is 85.
%
% Outputs
%   ColourConstantImage  the colour constant image in range of [0, 1].
%
% Examples
%   im = imread('peppers.png');
%   imout = ColourConstancySingleScaleRetinex(im);
%   figure; imshow(uint8(imout .* 255));
%
% See also: ColourConstancy, ColourConstancyMultiScaleRetinex
%

% TODO: maybe better only apply it to the value channel of HSV.

if nargin < 2
  sigma = 85;
end

InputImage = im2double(InputImage);
[rows, cols, chns] = size(InputImage);

[x, y] = meshgrid(1:cols, 1:rows);

gaussian = exp(-((y .^ 2) + (x .^ 2)) ./ (sigma .^ 2));
k = 1 / (sum(sum(gaussian)));
gaussianfft = fftshift(fft2(k .* gaussian));

retinex = zeros(rows, cols, chns);
for i = 1:chns
  ichan = InputImage(:, :, i);
  
  ichanfft = fftshift(fft2(ichan));
  ichanfft = gaussianfft .* ichanfft;
  ichanfft = real(ifft2(ifftshift(ichanfft)));
  
  retinex(:, :, i) = log(ichan) - log(ichanfft);
end

ColourConstantImage = MatChansMulK(retinex, 1 ./ max(max(retinex)));

end
