function WhitePoint = ApproximateWp(InputImage)
%ApproximateWp  approximated the white point as the maximum RGB.
%
% inputs
%   InputImage  the RGB image.
%
% outputs
%   WhitePoint  the pixel with the maxium values.
%

DoubleIm = im2double(InputImage);
SumAll = sum(DoubleIm, 3);
[~, indmax] = max(SumAll(:));
ImVector = reshape(DoubleIm, size(DoubleIm, 1) * size(DoubleIm, 2), 3);
WhitePoint = ImVector(indmax, :);

end
