function [SigmaCentre, SigmaSurround] = RelativePixelContrast(InputImage, CentreSize, SurroundSize)
%RelativePixelContrast  calculates contrast per pixel.
%
% inputs
%   CentreSize    the size of neighbourhood, default is 17.
%   SurroundSize  the size of surround, default 5 times the centre.
%
% outputs
%   SigmaCentre    contrast of centre.
%   SigmaSurround  contrast of surround.
%

InputImage = double(InputImage);

if nargin < 2
  CentreSize = 17;
end
if nargin < 3
  SurroundSize = 5 * CentreSize;
end

if mod(CentreSize, 2) == 0
  CentreSize = CentreSize + 1;
end
if mod(SurroundSize, 2) == 0
  SurroundSize = SurroundSize + 1;
end

hc = ones(CentreSize, CentreSize);
hs = ones(SurroundSize, SurroundSize);
[hcx, hcy] = size(hc);
d = [(hcx + 1) / 2, (hcy + 1) / 2] - 1;
[hsx, hsy] = size(hs);
m = [(hsx + 1) / 2, (hsy + 1) / 2];
hs((m(1) - d(1)):(m(1) + d(1)), (m(2) - d(2)):(m(2) + d(2))) = 0;

[rows, cols, chns] = size(InputImage);
SigmaCentre = zeros(rows, cols, chns);
SigmaSurround = zeros(rows, cols, chns);
for i = 1:chns
  SigmaCentre(:, :, i) = stdfilt(InputImage, hc);
  SigmaSurround(:, :, i) = stdfilt(InputImage, hs);
end

end
