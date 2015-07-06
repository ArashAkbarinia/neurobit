function [ColourConstantImage, luminance] = ColourConstancyColourEdge(InputImage)
%ColourConstancyColourEdge  coloru constancy through colour edges.
%
% inputs
%   InputImage  the input image.
%
% outputs
%   ColourConstantImage  the colour constant image in range of [0, 1].
%   luminance            the estimated luminance of the scene.
%

[BelongingImage, ~] = ColourNamingTestImage(InputImage, 'ourlab', false);

[rows, cols, chns] = size(BelongingImage);
derivaties = zeros(rows, cols, chns);

sigma = 2;
order = 1;
for i = 1:chns
  derivaties(:, :, i) = NormDerivative(BelongingImage(:, :, i), sigma, order);
end

edges = mean(derivaties, 3);

LuminanceImage = zeros(rows, cols, 3);
for i = 1:3
  LuminanceImage(:, :, i) = NormDerivative(InputImage(:, :, i), sigma, order) .* edges;
end

MinkNorm = 5;
luminance = ColourConstnacyMinkowskiFramework(LuminanceImage, MinkNorm, InputImage);
ColourConstantImage = MatChansMulK(InputImage, 1.0 ./ luminance);

end
