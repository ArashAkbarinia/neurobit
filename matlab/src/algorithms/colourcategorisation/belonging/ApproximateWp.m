function WhitePoint = ApproximateWp(InputImage)
%ApproximateWp Summary of this function goes here
%   Detailed explanation goes here

DoubleIm = im2double(InputImage);
SumAll = sum(DoubleIm, 3);
[~, indmax] = max(SumAll(:));
ImVector = reshape(DoubleIm, size(DoubleIm, 1) * size(DoubleIm, 2), 3);
WhitePoint = ImVector(indmax, :);

end
