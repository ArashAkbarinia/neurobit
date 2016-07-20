function OutputImage = GammaCorrection(InputImage, GammaValue)
%GammaCorrection  correcting the image with the given gamma.
%   https://en.wikipedia.org/wiki/Gamma_correction
%
% inputs
%   InputImage  the input image.
%   GammaValue  the gamma value.
%
% outputs
%   OutputImage  the gamma corrected image.
%

if nargin < 2
  GammaValue = 1;
elseif nargin == 2 && GammaValue < 0
  GammaValue = 1;
end

InputImage = double(InputImage);
OutputImage = uint8(255 .* ((InputImage ./ 255) .^ GammaValue));

end
