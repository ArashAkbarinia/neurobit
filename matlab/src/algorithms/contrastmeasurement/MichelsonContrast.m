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


MaxVal = max(max(InputImage));
MinVal = min(min(InputImage));

ImageContrast = (MaxVal - MinVal) ./ (MaxVal + MinVal);

end
