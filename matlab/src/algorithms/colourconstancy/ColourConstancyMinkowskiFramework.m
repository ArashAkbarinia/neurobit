function luminance = ColourConstancyMinkowskiFramework(LuminanceImage, MinkNorm, OriginalImage)
%ColourConstancyMinkowskiFramework  the genral colour constancy framework.
%   Explanation van de Weijer 2007, "Edge-based color constancy".
%
% inputs
%   LuminanceImage  the luminance image.
%   MinkNorm        the Minkowski norm, default is 5.
%   OriginalImage   original image, if provided the borders are cropped.
%
% outputs
%   luminance  the esimated luminance.
%

if nargin > 2
  SaturationThreshold = 1;
  sigma = 2;
  MaskImage = dilation33(double(max(OriginalImage, [], 3) >= SaturationThreshold));
  MaskImage = double(MaskImage == 0);
  MaskImage = set_border(MaskImage, sigma + 1, 0);
else
  MaskImage = ones(size(LuminanceImage, 1), size(LuminanceImage, 2));
end

if nargin < 2
  MinkNorm = 5;
end

if MinkNorm ~= -1
  kleur = power(LuminanceImage, MinkNorm);
  
  lr = power(sum(sum(kleur(:, :, 1) .* MaskImage)), 1 / MinkNorm);
  lg = power(sum(sum(kleur(:, :, 2) .* MaskImage)), 1 / MinkNorm);
  lb = power(sum(sum(kleur(:, :, 3) .* MaskImage)), 1 / MinkNorm);
else
  lr = max(max(LuminanceImage(:, :, 1) .* MaskImage));
  lg = max(max(LuminanceImage(:, :, 2) .* MaskImage));
  lb = max(max(LuminanceImage(:, :, 3) .* MaskImage));
end

luminance = [lr, lg, lb];

end
