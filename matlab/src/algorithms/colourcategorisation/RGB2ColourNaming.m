function [BelongingImage, ColouredBelongingImage] = RGB2ColourNaming(ImageRGB, ColourEllipsoids, plotme, EllipsoidsTitles, GroundTruth)
%RGB2ColourNaming Summary of this function goes here
%   Detailed explanation goes here

if nargin < 3
  plotme = 0;
end

% gammacorrect = true, max pix value > 1, max luminance = daylight
% TODO: make a more permanent solution, this is just becuase 0 goes to the
% end of the world
ImageRGB = ImageRGB + 1;
lsYImage = XYZ2lsY(sRGB2XYZ(ImageRGB, true, [10 ^ 2, 10 ^ 2, 10 ^ 2]), 'evenly_ditributed_stds');

ncolours = size(EllipsoidsTitles, 2);
EllipsoidsRGBs = zeros(ncolours, 3);
for i = 1:ncolours
  EllipsoidsRGBs(i, :) = name2rgb(EllipsoidsTitles{i});
end

% just for debugging purpose for the small images
% PlotAllPixels(ImageRGB, lsYImage, ColourEllipsoids, EllipsoidsRGBs, GroundTruth);

BelongingImage = lsY2Focals(lsYImage, ColourEllipsoids);

if plotme
  ColouredBelongingImage = PlotAllChannels(ImageRGB, BelongingImage, ColourEllipsoids, EllipsoidsTitles, EllipsoidsRGBs, 'Colour Categorisation - Colour Planes');
  if ~isempty(GroundTruth)
    PlotAllChannels(ImageRGB, GroundTruth, ColourEllipsoids, EllipsoidsTitles, EllipsoidsRGBs, 'Colour Categorisation - Ground Truth');
  end
end

end

function ColouredBelongingImage = PlotAllChannels(ImageRGB, BelongingImage, ColourEllipsoids, EllipsoidsTitles, EllipsoidsRGBs, FigureTitle)

titles = EllipsoidsTitles;
figure('NumberTitle', 'Off', 'Name', FigureTitle);
subplot(4, 4, 1.5);
imshow(ImageRGB);
title('Org');
subplot(4, 4, 3.5);
ColouredBelongingImage = ColourBelongingImage(BelongingImage, EllipsoidsRGBs);
imshow(ColouredBelongingImage);
title('Max');

[nelpisd, ~] = size(ColourEllipsoids);
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

function ColouredBelongingImage = ColourBelongingImage(BelongingImage, EllipsoidsRGBs)

[~, ~, chns] = size(BelongingImage);

[vals, inds] = max(BelongingImage(:, :, 1:chns), [], 3);
% if the maximum value is 0 it means neither of the colours did categorise
% this pixel.
inds(vals == 0) = 11;

ColouredBelongingImage = ColourLabelImage(inds, EllipsoidsRGBs);

end

function [] = PlotAllPixels(ImageRGB, lsYImage, ColourEllipsoids, EllipsoidsRGBs, GroundTruth)

AxesViews = [0, 90; 0, 0; 90, 0;];
if size(ImageRGB, 1) * size(ImageRGB, 2) < 500
  figure();
  for k = 1:3
    h = subplot(1, 3, k);
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
    view(AxesViews(k, :));
  end
end

end
