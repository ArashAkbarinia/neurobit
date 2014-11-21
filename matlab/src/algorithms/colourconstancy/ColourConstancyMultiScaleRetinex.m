function ColourConstantImage = ColourConstancyMultiScaleRetinex(InputImage, sigmas)
%ColourConstancyMultiScaleRetinex applies multi scale retinex algorithm.
%   Explanation
%   http://dragon.larc.nasa.gov/background/pubabs/papers/gspx1.pdf
%
% Inputs
%   InputImage  the input image.
%   sigmas      the sigma of Gaussian kernel, typically ranging from 50 to
%               120, are normally used to produce good single-scale Retinex
%               performance. Default is [50, 85, 120].
%
% Outputs
%   ColourConstantImage  the colour constant image in range of [0, 1].
%
% Examples
%   im = imread('peppers.png');
%   imout = ColourConstancyMultiScaleRetinex(im);
%   figure; imshow(uint8(imout .* 255));
%
% See also: ColourConstancy, ColourConstancySingleScaleRetinex
%

if nargin < 2
  sigmas = [50, 85, 120];
end

InputImage = im2double(InputImage);
[rows, cols, chns] = size(InputImage);

SingleRetinex = zeros(rows, cols, chns);
for i = 1:length(sigmas)
  SingleRetinex = SingleRetinex + ColourConstancySingleScaleRetinex(InputImage, sigmas(i));
end

ColourConstantImage = SingleRetinex ./ length(sigmas);

end
