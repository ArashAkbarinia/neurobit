function BelongingImage = rgb2belonging(ImageRGB, ColourSpace, ConfigsMat, plotme, GroundTruth)
%RGB2BELONGING  labels each pixel in the image as one of the focal eleven
%               colours.

if nargin < 2
  ColourSpace = 'lab';
end
ColourSpace = lower(ColourSpace);

if nargin < 5
  plotme = 0;
end

if max(ImageRGB(:)) <= 1
  ImageRGB = uint8(ImageRGB .* 255);
end

% TODO: try CMYK as well
if strcmpi(ColourSpace, 'lsy')
  if isempty(ConfigsMat)
    ConfigsMat = load('lsy_ellipsoid_params_new');
  end
  % TODO: make a more permanent solution, this is just becuase 0 goes to the
  % end of the world (ImageRGB + 1)
  % gammacorrect = true, max pix value > 1, max luminance = daylight
  ImageOpponent = XYZ2lsY(sRGB2XYZ(ImageRGB + 1, true, [10 ^ 2, 10 ^ 2, 10 ^ 2]), 'evenly_ditributed_stds');
  axes = {'l', 's', 'y'};
elseif strcmpi(ColourSpace, 'lab')
  if isempty(ConfigsMat)
    ConfigsMat = load('lab_ellipsoid_params_new');
  end
  ImageOpponent = double(applycform(ImageRGB, makecform('srgb2lab')));
  axes = {'l', 'a', 'b'};
end
ColourEllipsoids = ConfigsMat.ColourEllipsoids;

% FIXME: put it in the mat file
ColourEllipsoids(9:11, 5:6) = 8;
ColourEllipsoids(5, 2) = 176;
ColourEllipsoids(5, 7) = pi - 0.1;

if size(ImageOpponent, 1) * size(ImageOpponent, 2) > 500
  ColourEllipsoids = AdaptEllipsoids(ImageOpponent, ColourEllipsoids);
end

BelongingImage = AllEllipsoidsEvaluateBelonging(ImageOpponent, ColourEllipsoids);

if plotme
  EllipsoidsTitles = ConfigsMat.RGBTitles;
  EllipsoidsRGBs = name2rgb(EllipsoidsTitles);
  % just for debugging purpose for the small images
  PlotAllPixels(ImageRGB, ImageOpponent, ColourEllipsoids, EllipsoidsRGBs, axes, GroundTruth);
  
  PlotAllChannels(ImageRGB, BelongingImage, EllipsoidsTitles, EllipsoidsRGBs, 'Colour Categorisation - Colour Planes');
  if ~isempty(GroundTruth)
    PlotAllChannels(ImageRGB, GroundTruth, EllipsoidsTitles, EllipsoidsRGBs, 'Colour Categorisation - Ground Truth');
  end
end

end

function [] = PlotAllPixels(ImageRGB, ImageOpponent, ColourEllipsoids, EllipsoidsRGBs, axes, GroundTruth)

if isempty(GroundTruth)
  return;
end

[rows, cols, chns] = size(ImageOpponent);
if rows * cols < 500
  nfigures = 3;
else
  nfigures = 3;
  ScaleFactor = 0.1;
  ImageOpponent = imresize(ImageOpponent, ScaleFactor);
  ImageRGB = imresize(ImageRGB, ScaleFactor);
  [rows, cols, chns] = size(ImageOpponent);
end

ImageRGB = im2double(ImageRGB);
ImageRGB = reshape(ImageRGB, rows * cols, chns);
ImageOpponent = reshape(ImageOpponent, rows * cols, chns);

AxesViews = [0, 90; 0, 0; 90, 0;];
figure();
for k = 1:nfigures
  h = subplot(1, nfigures, k);
  hold on;
  grid on;
  scatter3(ImageOpponent(:, 1), ImageOpponent(:, 2), ImageOpponent(:, 3), 36, ImageRGB, '*');
  PlotAllEllipsoids(ColourEllipsoids, EllipsoidsRGBs, h);
  xlabel(axes{1});
  ylabel(axes{2});
  zlabel(axes{3});
  view(AxesViews(k, :));
end

end

function ColourEllipsoids = AdaptEllipsoids(ImageOpponent, ColourEllipsoids)

% indices of colour ooponency
lumindc = 1;
luminda = 4;
rgindc = 2;
rginda = 5;
ybindc = 3;
ybinda = 6;

% middle point of colour opponency
lumavg = 128;
rgavg = 128;
ybavg = 128;

% maximums and minimums
rgmax = 190;
ybmax = 190;

LabMax = max(max(ImageOpponent));
LabAvg = mean(mean(ImageOpponent));
LabStd = std(std(ImageOpponent));

% if maximum value of rg-channel is too low
if LabMax(rgindc) < rgmax
  rgmaxper = LabMax(rgindc) / rgmax;
  fprintf('RG Max %f\n', rgmaxper);
  rgdiff = ColourEllipsoids(9:11, rginda) .* rgmaxper;
  
  % make the achromatic bigger
  ColourEllipsoids(9:11, rgindc) = ColourEllipsoids(9:11, rgindc) + (rgdiff / 2);
  ColourEllipsoids(9:11, rginda) = ColourEllipsoids(9:11, rginda) + abs(rgdiff / 2);
end

% if maximum value of yb-channel is too high
if LabMax(ybindc) > ybmax
  ybmaxper = 1 - (ybmax / LabMax(ybindc));
  fprintf('YB Max %f\n', ybmaxper);
  ybdiff = ColourEllipsoids(1:8, ybindc) .* ybmaxper;
  
  % make chromatic ellipsoids smaller
  ColourEllipsoids(1:8, ybindc) = ColourEllipsoids(1:8, ybindc) + (ybdiff / 2) .* sign(ColourEllipsoids(1:8, ybindc));
  ColourEllipsoids(1:8, ybinda) = ColourEllipsoids(1:8, ybinda) - abs(ybdiff);
end

% if there is more than 0.10 per cent deviation in luminance
lumstddiff = abs(LabStd(lumindc) - 0.1 * lumavg);
if lumstddiff > 1
  lumstdper = lumstddiff / (0.025 * lumavg);
  fprintf('Lum STD %f\n', lumstdper);
  % make achromatics larger
  if LabAvg(lumindc) > (lumavg + 0.25 * lumavg)
    colinds = [9, 11];
    AxesChange = ColourEllipsoids(colinds, [rginda, ybinda]) .* lumstdper;
    AxesChange(1, :) = AxesChange(1, :) / 2;
    ColourEllipsoids(colinds, [rginda, ybinda]) = ColourEllipsoids(colinds, [rginda, ybinda]) + AxesChange / 2;
  elseif LabAvg(lumindc) < (lumavg - 0.25 * lumavg)
    colinds = [9, 10];
    AxesChange = ColourEllipsoids(colinds, [rginda, ybinda]) .* lumstdper;
    AxesChange(1, :) = AxesChange(1, :) / 2;
    ColourEllipsoids(colinds, [rginda, ybinda]) = ColourEllipsoids(colinds, [rginda, ybinda]) + AxesChange / 2;
  else
    colinds = [10, 11];
    AxesChange = ColourEllipsoids(colinds, [rginda, ybinda]) .* lumstdper;
    ColourEllipsoids(colinds, [rginda, ybinda]) = ColourEllipsoids(colinds, [rginda, ybinda]) + AxesChange / 2;
  end
end

% if there is more than 0.025 per cent deviation in rg-channel
rgstddiff = abs(LabStd(rgindc) - 0.025 * rgavg);
if rgstddiff > 1
  fprintf('RG STD %f\n', rgstddiff);
  GreenSmaller = max((1 / rgstddiff), 0.65);
  ColourEllipsoids(1, ybinda) = ColourEllipsoids(1, ybinda) * GreenSmaller;
  
%   ColourEllipsoids(4, luminda) = ColourEllipsoids(4, luminda) / rgstddiff;
  rgstdper = rgstddiff / (0.025 * rgavg);
  AxesChange = ColourEllipsoids(9:11, rginda) .* rgstdper;
  ColourEllipsoids(9:11, rginda) = ColourEllipsoids(9:11, rginda) + AxesChange / 2;
end

% if there is more than 0.025 per cent deviation in yb-channel
ybstddiff = abs(LabStd(ybindc) - 0.025 * ybavg);
if ybstddiff > 1
  fprintf('YB STD %f\n', ybstddiff);
  %   ColourEllipsoids(2, luminda) = ColourEllipsoids(2, luminda) / ybstddiff;
  ybstdper = ybstddiff / (0.025 * ybavg);
  AxesChange = ColourEllipsoids(9:11, ybinda) .* ybstdper;
  ColourEllipsoids(9:11, ybinda) = ColourEllipsoids(9:11, ybinda) + AxesChange / 2;
end

% too dark
if LabAvg(lumindc) < lumavg
  PinkSmaller = LabAvg(lumindc) / lumavg;
  fprintf('Lum AVG %f\n', PinkSmaller);
  
  lumdiff = abs(lumavg - LabAvg(lumindc));
  ColourEllipsoids(1, lumindc) = ColourEllipsoids(1, lumindc) - lumdiff;
  ColourEllipsoids(1, luminda) = ColourEllipsoids(1, luminda) - lumdiff / 2;
  YellowBigger = ColourEllipsoids(7, rginda) * (LabAvg(lumindc) / lumavg);
  ColourEllipsoids(7, rgindc) = ColourEllipsoids(7, rgindc) - YellowBigger / 4;
  ColourEllipsoids(7, rginda) = ColourEllipsoids(7, rginda) + YellowBigger / 2;
  
  ColourEllipsoids(4, luminda) = ColourEllipsoids(4, luminda) * PinkSmaller;
  
%   ColourInds = 10;
%   WhiteBigger = ColourEllipsoids(ColourInds, rginda) * (1 - PinkSmaller);
%   ColourEllipsoids(ColourInds, rgindc) = ColourEllipsoids(ColourInds, rgindc) + WhiteBigger / 2;
%   ColourEllipsoids(ColourInds, rginda) = ColourEllipsoids(ColourInds, rginda) + WhiteBigger;
end

% too much green
if LabAvg(rgindc) < rgavg
  rgdiff = rgavg - LabAvg(rgindc);
  fprintf('RG AVG %f\n', rgdiff);
  %   ColourEllipsoids(1, rginda) = ColourEllipsoids(1, rginda) - abs(rgdiff / 2);
  %   ColourEllipsoids(1, rgindc) = ColourEllipsoids(1, rgindc) - rgdiff;
  
  % shift the pink
%   ColourEllipsoids(4, rgindc) = ColourEllipsoids(4, rgindc) + rgdiff;
  
  % make the achromatic bigger
  ColourEllipsoids(9:11, rgindc) = ColourEllipsoids(9:11, rgindc) - (rgdiff / 2);
  ColourEllipsoids(9:11, rginda) = ColourEllipsoids(9:11, rginda) + abs(rgdiff / 2);
end

% too much yellow and bright
if LabAvg(ybindc) > ybavg
  ybdiff = ybavg - LabAvg(ybindc);
  fprintf('YB AVG %f\n', ybdiff);
  
  if LabAvg(lumindc) > (lumavg + 0.25 * lumavg)
    % shift the blue
    ColourEllipsoids(2, ybindc) = ColourEllipsoids(2, ybindc) + ybdiff;
  end
  
  % make the achromatic bigger
  ColourEllipsoids(9:11, ybindc) = ColourEllipsoids(9:11, ybindc) + (ybdiff / 2);
  ColourEllipsoids(9:11, ybinda) = ColourEllipsoids(9:11, ybinda) + abs(ybdiff / 2);
end

end
