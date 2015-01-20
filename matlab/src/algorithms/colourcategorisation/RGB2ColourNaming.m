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
PlotAllPixels(ImageRGB, lsYImage, ColourEllipsoids, EllipsoidsRGBs);

BelongingImage = lsY2Focals(lsYImage, ColourEllipsoids);

if plotme
  ColouredBelongingImage = PlotAllChannels(ImageRGB, BelongingImage, EllipsoidsTitles, EllipsoidsRGBs, 'Colour Categorisation - Colour Planes');
  if ~isempty(GroundTruth)
    PlotAllChannels(ImageRGB, GroundTruth, EllipsoidsTitles, EllipsoidsRGBs, 'Colour Categorisation - Ground Truth');
  end
end

end

function [] = PlotAllPixels(ImageRGB, lsYImage, ColourEllipsoids, EllipsoidsRGBs)

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
