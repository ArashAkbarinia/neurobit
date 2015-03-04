function ind = biwam(InputImage, WindowSizes, nplans, nu0)
%BIWAM  returns saliency map for  a grey-scale image.
%
% inputs
%   InputImage   input image
%   WindowSizes  window sizes for computing relative contrast; suggested
%                value of [3 6].
%   nplans       number of wavelet levels.
%   nu_0         peak spatial frequency for CSF; suggested value of 4.
%
% outputs
%   ind  saliency map for image
%

if nargin < 2
  MidaMin = 4;
  nplans = floor(log(max(size(InputImage) - 1) / MidaMin) / log(2)) + 1;
  
  WindowSizes = [3, 6];
  nu0 = 3;
end

MaxPixel = max(InputImage(:));

if MaxPixel <= 1.0
  InputImage = InputImage .* 3;
else
  InputImage = im2double(InputImage);
  InputImage = InputImage .* 3;
end

ind = CIWAM_per_channel(InputImage, nplans, nu0, 'intensity', WindowSizes);

end
