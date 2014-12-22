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
  subplot(4, 4, 1.5);
  imshow(ImageRGB);
  title('Org');
  subplot(4, 4, 3.5);
  ColouredBelongingImage = ColourBelongingImage(BelongingImage, EllipsoidsRGBs);
  imshow(ColouredBelongingImage);
  title('Max');
  for i = 1:nelpisd
    PlotIndex = i + 4;
    if PlotIndex > 12
      PlotIndex = PlotIndex + 0.5;
    end
    subplot(4, 4, PlotIndex);
    imshow(BelongingImage(:, :, i), []);
    title(titles{i});
  end
end

end

function ColouredBelongingImage = ColourBelongingImage(BelongingImage, EllipsoidsRGBs)

[~, ~, chns] = size(BelongingImage);

[~, inds] = max(BelongingImage(:, :, 1:chns), [], 3);

ColouredBelongingImage = ColourLabelImage(inds, EllipsoidsRGBs);

end