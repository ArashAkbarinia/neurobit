function OutputImage = ApproximateToD65(InputImage)
%ApproximateToD65  approximates the white point by the maximum RGB.
%
% inputs
%   InputImage   the RGB image.
%
% outputs
%   OutputImage  converted image to D65 illuminant.
%

WhitePoint = ApproximateWp(InputImage);
ImageLAB = rgb2lab(InputImage, 'whitepoint', WhitePoint);
OutputImage = lab2rgb(ImageLAB, 'whitepoint', whitepoint('d65'));
OutputImage = uint8(min(OutputImage, 1) .* 255);

end
