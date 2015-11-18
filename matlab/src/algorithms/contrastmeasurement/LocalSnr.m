function lsnr = LocalSnr(InputImage, WindowSize, CentreSize, cliplstd)
%LocalSnr  calculates the local SNR of an image
% Explanation  https://en.wikipedia.org/wiki/Decibel#Definition
%
% inputs
%   InputImage  the input image with n channel.
%   WindowSize  the size of the neighbourhoud.
%   CentreSize  if provided the centre is set to 0.
%   clipstd     if true small local stds are clipped to avoid infinitiy.
%
% outputs
%   lsnr  calculated local snr of each channel.
%

InputImage = double(InputImage);

if nargin < 2 || isempty(WindowSize)
  WindowSize = 3;
end
if length(WindowSize) == 1
  WindowSize(1, 2) = WindowSize(1, 1);
end
if nargin < 3 || isempty(CentreSize)
  CentreSize = 0;
end
if length(CentreSize) == 1
  CentreSize(1, 2) = CentreSize(1, 1);
end
if nargin < 4
  cliplstd = true;
end

hc = fspecial('average', WindowSize);
hc = CentreZero(hc, CentreSize);
MeanCentre = imfilter(InputImage, hc, 'replicate');
stdv = (InputImage - MeanCentre) .^ 2;
MeanStdv = imfilter(stdv, hc, 'replicate');
lstd = sqrt(MeanStdv);

dbcons = 1;
lsnr = dbcons .* log10(MeanCentre ./ lstd);

if cliplstd
  for i = 1:size(InputImage, 3)
    CurrentChannel = lsnr(:, :, i);
    CurrentChannel(lstd(:, :, i) < 1e-4) = max(CurrentChannel(~isinf(CurrentChannel)));
    lsnr(:, :, i) = CurrentChannel;
  end
  lsnr = max(lsnr, 0);
end

end
