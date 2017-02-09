function OutputImage = ApproximateToD65(InputImage)
%ApproximateToD65 Summary of this function goes here
%   Detailed explanation goes here

WhitePoint = ApproximateWp(InputImage);
ImageLAB = rgb2lab(InputImage, 'whitepoint', WhitePoint);
OutputImage = lab2rgb(ImageLAB, 'whitepoint', whitepoint('d65'));
OutputImage = uint8(min(OutputImage, 1) .* 255);

end
