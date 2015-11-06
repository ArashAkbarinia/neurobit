function ImageContrast = LocalMichelsonContrast(InputImage, WindowSize)
%LocalMichelsonContrast  calculates the Local Michelson contrast.
%   Explanation
%   http://en.wikipedia.org/wiki/Contrast_(vision)#Michelson_contrast
%
% Inputs
%   InputImage  the input image with n channel.
%   WindowSize  the neighbourhood size.
%
% Outputs
%   ImageContrast  calculated contrast of each channel.
%

if nargin < 2
  WindowSize = [13, 13];
end

InputImage = double(InputImage);

ImageContrast = zeros(size(InputImage));
for i = 1:size(InputImage, 3)
  fmax = @(x) max(x(:));
  fmin = @(x) min(x(:));
  imax = nlfilter(InputImage(:, :, i), WindowSize, fmax);
  imin = nlfilter(InputImage(:, :, i), WindowSize, fmin);
  ChannelContrast = (imax - imin) ./ (imax + imin);
  ChannelContrast(isinf(ChannelContrast) | isnan(ChannelContrast)) = 0;
  ImageContrast(:, :, i) = ChannelContrast;
end

end
