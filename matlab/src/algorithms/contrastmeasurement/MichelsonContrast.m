function ImageContrast = MichelsonContrast(InputImage)
%MichelsonContrast  calculates the Michelson contrast.
%   Explanation
%   http://en.wikipedia.org/wiki/Contrast_(vision)#Michelson_contrast
%
% Inputs
%   InputImage  the input image with n channel.
%
% Outputs
%   ImageContrast  calculated contrast of each channel.
%

InputImage = double(InputImage);

MaxVal = max(max(InputImage));
MinVal = min(min(InputImage));

ImageContrast = (MaxVal - MinVal) ./ (MaxVal + MinVal);

[~, ~, chns] = size(InputImage);
if chns > 1
  ImageContrast = reshape(ImageContrast, 1, chns);
end

end
