function ImageContrast = WeberContrast(InputImage)
%WeberContrast  calculates the Weber contrast.
%   Explanation
%   http://en.wikipedia.org/wiki/Contrast_(vision)#Weber_contrast
%
% Inputs
%   InputImage  the input image with n channel.
%
% Outputs
%   ImageContrast  calculated contrast of each channel.
%

InputImage = double(InputImage);

MeanVals = mean(mean(InputImage));

[rows, cols, chns] = size(InputImage);
ImageContrast = zeros(rows, cols, chns);
for i = 1:chns
  ChannelMean = MeanVals(:, :, i);
  ImageContrast(:, :, i) = abs((InputImage(:, :, i) - ChannelMean) ./ ChannelMean);
end

end
