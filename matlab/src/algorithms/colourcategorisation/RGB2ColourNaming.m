function [BelongingImage, ColouredBelongingImage] = RGB2ColourNaming(ImageRGB, ColourEllipsoids, plotme, EllipsoidsRGBs, EllipsoidsTitles)
%RGB2ColourNaming Summary of this function goes here
%   Detailed explanation goes here

if nargin < 3
  plotme = 0;
end

[nelpisd, ~] = size(ColourEllipsoids);

% gammacorrect = true, max pix value > 1, max luminance = daylight
% TODO: make a more permanent solution, this is just becuase 0 goes to the
% end of the world
ImageRGB = ImageRGB + 1;
lsYImage = XYZ2lsY(sRGB2XYZ(ImageRGB, true, [10 ^ 2, 10 ^ 2, 10 ^ 2]), 'evenly_ditributed_stds');

% just for debugging purpose for the small images
PlotAllPixels(ImageRGB, lsYImage, ColourEllipsoids, EllipsoidsRGBs);

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

function [] = PlotAllPixels(ImageRGB, lsYImage, ColourEllipsoids, EllipsoidsRGBs)

if size(ImageRGB, 1) * size(ImageRGB, 2) < 120
  h = figure();
  hold on;
  grid on;
  for i = 1:size(lsYImage, 1)
    for j = 1:size(lsYImage, 2)
      plot3(lsYImage(i, j, 1), lsYImage(i, j, 2), lsYImage(i, j, 3), 'marker', 'o', 'MarkerFaceColor', im2double(ImageRGB(i, j, :)), 'MarkerEdgeColor', [0, 0, 0]);
    end
  end
  PlotAllEllipsoids(ColourEllipsoids, EllipsoidsRGBs, h);
  xlabel('l');
  ylabel('s');
  zlabel('Y');
end

end
