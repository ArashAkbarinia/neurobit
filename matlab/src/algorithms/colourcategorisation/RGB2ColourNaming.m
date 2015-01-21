function [BelongingImage, ColouredBelongingImage] = RGB2ColourNaming(ImageRGB, ColourSpace, plotme, GroundTruth)
%RGB2ColourNaming Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
  ColourSpace = 'lab';
end
ColourSpace = lower(ColourSpace);

if nargin < 4
  plotme = 0;
end

% TODO: make a more permanent solution, this is just becuase 0 goes to the
% end of the world
ImageRGB = ImageRGB + 1;

if strcmpi(ColourSpace, 'lsy')
  ConfigsMat = load('lsy_ellipsoid_params_arash');
  % gammacorrect = true, max pix value > 1, max luminance = daylight
  ImageOpponent = XYZ2lsY(sRGB2XYZ(ImageRGB, true, [10 ^ 2, 10 ^ 2, 10 ^ 2]), 'evenly_ditributed_stds');
elseif strcmpi(ColourSpace, 'lab')
  ConfigsMat = load('lab_ellipsoid_params_arash');
  ImageOpponent = double(applycform(ImageRGB, makecform('srgb2lab')));
end
ColourEllipsoids = ConfigsMat.ColourEllipsoids;
EllipsoidsTitles = ConfigsMat.RGBTitles;

ncolours = size(EllipsoidsTitles, 2);
EllipsoidsRGBs = zeros(ncolours, 3);
for i = 1:ncolours
  EllipsoidsRGBs(i, :) = name2rgb(EllipsoidsTitles{i});
end

% just for debugging purpose for the small images
PlotAllPixels(ImageRGB, ImageOpponent, ColourEllipsoids, EllipsoidsRGBs, GroundTruth, []);

BelongingImage = lsY2Focals(ImageOpponent, ColourEllipsoids);

if plotme
  ColouredBelongingImage = PlotAllChannels(ImageRGB, BelongingImage, EllipsoidsTitles, EllipsoidsRGBs, 'Colour Categorisation - Colour Planes');
  if ~isempty(GroundTruth)
    PlotAllChannels(ImageRGB, GroundTruth, EllipsoidsTitles, EllipsoidsRGBs, 'Colour Categorisation - Ground Truth');
  end
end

end

function [] = PlotAllPixels(ImageRGB, lsYImage, ColourEllipsoids, EllipsoidsRGBs, GroundTruth, ColourIndex)

[rows, cols, ~] = size(lsYImage);

if isempty(GroundTruth) || isempty(ColourIndex)
  GroundTruth = ones(rows, cols, 1);
  ColourIndex = 1;
end

AxesViews = [0, 90; 0, 0; 90, 0;];
if size(ImageRGB, 1) * size(ImageRGB, 2) < 500
  figure();
  for k = 1:3
    h = subplot(1, 3, k);
    hold on;
    grid on;
    for i = 1:size(lsYImage, 1)
      for j = 1:size(lsYImage, 2)
        if GroundTruth(i, j, ColourIndex) > 0
          plot3(lsYImage(i, j, 1), lsYImage(i, j, 2), lsYImage(i, j, 3), 'marker', 'o', 'MarkerFaceColor', im2double(ImageRGB(i, j, :)), 'MarkerEdgeColor', [0, 0, 0]);
        end
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
