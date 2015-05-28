function ImageContrast = LocalStdContrast(InputImage, CentreSize)
%LocalStdContrast  calculates the local std of an image
%
% inputs
%   InputImage  the input image with n channel.
%   CentreSize  the size of the neighbourhoud.
%
% outputs
%   ImageContrast  calculated local std of each channel.
%

InputImage = double(InputImage);

if nargin < 2
  CentreSize = 5;
end

hc = fspecial('average', CentreSize);
MeanCentre = imfilter(InputImage, hc);
stdv = (InputImage - MeanCentre) .^ 2;
Mean2 = imfilter(stdv, hc);
ImageContrast = sqrt(Mean2);

end
