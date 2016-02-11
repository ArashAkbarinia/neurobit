function ImageContrast = LocalStdCustom(InputImage, CustomPixels)
%LocalStdCustom  calculates the local std of pixels provided in a mask.
%
% inputs
%   InputImage    the input image with n channel.
%   CustomPixels  tpixels to eb considered for local std.
%
% outputs
%   ImageContrast  calculated local std of each channel.
%

InputImage = double(InputImage);

npixels = sum(CustomPixels(:));
hc = double(CustomPixels) ./ npixels;
MeanCentre = imfilter(InputImage, hc, 'symmetric');
stdv = (InputImage - MeanCentre) .^ 2;
MeanStdv = imfilter(stdv, hc, 'symmetric');
ImageContrast = sqrt(MeanStdv);

end
