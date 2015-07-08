function [SigmaCentre, SigmaSurround] = RelativePixelContrast(InputImage, CentreSize, SurroundSize)
%RelativePixelContrast  calculates contrast per pixel.
%
% inputs
%   InputImage    the input image.
%   CentreSize    the size of neighbourhood, default is 17.
%   SurroundSize  the size of surround, default 5 times the centre.
%
% outputs
%   SigmaCentre    contrast of centre.
%   SigmaSurround  contrast of surround.
%   ImageContrast  contrast of pixels.
%

InputImage = double(InputImage);

if nargin < 2
  CentreSize = 17;
end
if nargin < 3
  SurroundSize = 5 * CentreSize;
end

% [~, ~, chns] = size(ImageContrast);
% for i = 1:chns
%   ichannel = ImageContrast(:, :, i);
%   ichannel(isinf(ichannel)) = 0;
%   ichannel(isnan(ichannel)) = 0;
%   ImageContrast(:, :, i) = ichannel;
% end

hc = ones(CentreSize, CentreSize);
hs = ones(SurroundSize, SurroundSize);
hs(1+CentreSize:SurroundSize-CentreSize,1+CentreSize:SurroundSize-CentreSize) = 0;

MeanCentre = conv2(InputImage, hc / CentreSize ^ 2, 'same');
SigmaCentre = sqrt(abs(conv2(InputImage .^ 2, hc / sum(hc(:)), 'same') - MeanCentre .^ 2));
SigmaCentre = SigmaCentre ./ max(SigmaCentre(:));

MeanSurround = conv2(InputImage, hs / SurroundSize ^ 2, 'same');
SigmaSurround = sqrt(abs(conv2(InputImage .^ 2, hs / sum(hs(:)), 'same') - MeanSurround .^ 2));
SigmaSurround = SigmaSurround ./ max(SigmaSurround(:));

% EQUATION: eq-4 Otazu et al. 2007, "Multiresolution wavelet framework
% models brightness induction effect"
% ImageContrast = SigmaCentre ./ SigmaSurround;
% ImageContrast(isnan(ImageContrast)) = 0;
% ImageContrast(isinf(ImageContrast)) = 1;
% ImageContrast = ImageContrast .^ 2 ./ (1 + ImageContrast .^ 2);

end
