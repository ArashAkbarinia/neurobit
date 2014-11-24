function [BelongingImage, ColouredBelongingImage] = RGB2ColourNaming(ImageRGB, ColourEllipsoids, plotme, EllipsoidsRGBs, EllipsoidsTitles)
%RGB2ColourNaming Summary of this function goes here
%   Detailed explanation goes here

if nargin < 3
  plotme = 0;
end

[nelpisd, ~] = size(ColourEllipsoids);

% gammacorrect = true, max pix value > 1, max luminance = daylight
lsYImage = XYZ2lsY(sRGB2XYZ(ImageRGB, true, [10 ^ 2, 10 ^ 2, 10 ^ 2]), 'evenly_ditributed_stds');

BelongingImage = lsY2Focals(lsYImage, ColourEllipsoids);

if plotme
  titles = EllipsoidsTitles;
  figure('NumberTitle', 'Off', 'Name', 'Colour Categorisation - Colour Planes');
  subplot(3, 5, 2);
  imshow(ImageRGB);
  title('Org');
  subplot(3, 5, 4);
  ColouredBelongingImage = ColourBelongingImage(BelongingImage, EllipsoidsRGBs);
  imshow(ColouredBelongingImage);
  title('Max');
  for i = 1:nelpisd + 1
    subplot(3, 5, i + 5);
    imshow(BelongingImage(:, :, i), []);
    title(titles{i});
  end
end

end

function ColouredBelongingImage = ColourBelongingImage(BelongingImage, EllipsoidsRGBs)

[~, ~, chns] = size(BelongingImage);

% the last channel is the luminance
ncolcats = chns - 1;
[~, inds] = max(BelongingImage(:, :, 1:ncolcats), [], 3);

ColouredBelongingImage = ColourLabelImage(inds, EllipsoidsRGBs);

end