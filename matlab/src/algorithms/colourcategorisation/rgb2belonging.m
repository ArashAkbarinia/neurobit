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
configs.lumindc = 1;
configs.luminda = 4;
configs.rgindc = 2;
configs.rginda = 5;
configs.ybindc = 3;
configs.ybinda = 6;

% middle point of colour opponency
configs.lumavg = 128;
configs.rgavg = 128;
configs.ybavg = 128;

% maximums and minimums
configs.rgmin = 70;
configs.ybmin = 70;
configs.rgmax = 190;
configs.ybmax = 190;

configs.LabMin = max(max(ImageOpponent));
configs.LabMax = max(max(ImageOpponent));
configs.LabAvg = mean(mean(ImageOpponent));
configs.LabStd = std(std(ImageOpponent));

ColourEllipsoids = AdaptEllipsoidsMaxs(ColourEllipsoids, configs);
ColourEllipsoids = AdaptEllipsoidsMins(ColourEllipsoids, configs);
ColourEllipsoids = AdaptEllipsoidsStds(ColourEllipsoids, configs);
ColourEllipsoids = AdaptEllipsoidsAvgs(ColourEllipsoids, configs);

end

function ColourEllipsoids = AdaptEllipsoidsMaxs(ColourEllipsoids, configs)

% indices of colour ooponency
rgindc = configs.rgindc;
rginda = configs.rginda;
ybindc = configs.ybindc;
ybinda = configs.ybinda;

% maximums and minimums
rgmax = configs.rgmax;
ybmax = configs.ybmax;

LabMax = configs.LabMax;

% if maximum value of rg-channel is too low
if LabMax(rgindc) < rgmax
  rgmaxper = LabMax(rgindc) / rgmax;
  ColourInds = 9:11;
  diff = ColourEllipsoids(ColourInds, rginda) .* rgmaxper;
  
  % make the achromatic bigger
  ColourEllipsoids(ColourInds, rgindc) = ColourEllipsoids(ColourInds, rgindc) + (diff / 2);
  ColourEllipsoids(ColourInds, rginda) = ColourEllipsoids(ColourInds, rginda) + (diff / 2);
  fprintf('Max-RG - Colour %d %d %d, channel %d, being streched on POS %f %f %f\n', ColourInds, rgindc, diff);
end

% if maximum value of yb-channel is too high
if LabMax(ybindc) > ybmax
  ybmaxper = 1 - (ybmax / LabMax(ybindc));
  ColourInds = 1:8;
  diff = ColourEllipsoids(ColourInds, ybinda) .* ybmaxper;
  
  % make chromatic ellipsoids smaller
  %   ColourEllipsoids(ColourInds, ybindc) = ColourEllipsoids(ColourInds, ybindc) + (diff / 2) .* sign(ColourEllipsoids(ColourInds, ybindc));
  ColourEllipsoids(ColourInds, ybinda) = ColourEllipsoids(ColourInds, ybinda) - (diff / 2);
  fprintf('Max-YB - Colour chromatic, channel %d, being shrinked %f %f %f %f %f %f %f %f\n', ybindc, diff);
end

end

function ColourEllipsoids = AdaptEllipsoidsMins(ColourEllipsoids, configs)

% indices of colour ooponency
rgindc = configs.rgindc;
rginda = configs.rginda;
ybindc = configs.ybindc;
ybinda = configs.ybinda;

% maximums and minimums
rgmin = configs.rgmin;
ybmin = configs.ybmin;

LabMin = configs.LabMin;

% if minimum value of rg-channel is too high
if LabMin(rgindc) > rgmin
  rgminper = rgmin / LabMin(rgindc);
  ColourInds = 9:11;
  diff = ColourEllipsoids(ColourInds, rginda) .* rgminper;
  
  % make the achromatic bigger
  ColourEllipsoids(ColourInds, rgindc) = ColourEllipsoids(ColourInds, rgindc) + (diff / 2);
  ColourEllipsoids(ColourInds, rginda) = ColourEllipsoids(ColourInds, rginda) + (diff / 2);
  fprintf('Min-RG - Colour %d %d %d, channel %d, being streched on POS %f %f %f\n', ColourInds, rgindc, diff);
end

% if minimum value of yb-channel is too high
if LabMin(ybindc) > ybmin
  ybminper = ybmin / LabMin(ybindc);
  ColourInds = 9:11;
  diff = ColourEllipsoids(ColourInds, ybinda) .* ybminper;
  
  % make the achromatic bigger
  ColourEllipsoids(ColourInds, ybindc) = ColourEllipsoids(ColourInds, ybindc) + (diff / 2);
  ColourEllipsoids(ColourInds, ybinda) = ColourEllipsoids(ColourInds, ybinda) + (diff / 2);
  fprintf('Min-YB - Colour %d %d %d, channel %d, being streched on POS %f %f %f\n', ColourInds, ybindc, diff);
end

end

function ColourEllipsoids = AdaptEllipsoidsStds(ColourEllipsoids, configs)

% indices of colour ooponency
lumindc = configs.lumindc;
rgindc = configs.rgindc;
rginda = configs.rginda;
ybindc = configs.ybindc;
ybinda = configs.ybinda;

% middle point of colour opponency
lumavg = configs.lumavg;
rgavg = configs.rgavg;
ybavg = configs.ybavg;

LabAvg = configs.LabAvg;
LabStd = configs.LabStd;

% if there is more than 0.10 per cent deviation in luminance
lumstddiff = abs(LabStd(lumindc) - 0.1 * lumavg);
if lumstddiff > 1
  lumstdper = lumstddiff / (0.025 * lumavg);
  % make achromatics larger
  if LabAvg(lumindc) > (lumavg + 0.25 * lumavg)
    ColourInds = [9, 11];
    diff = ColourEllipsoids(ColourInds, [rginda, ybinda]) .* lumstdper;
    diff(1, :) = diff(1, :) / 2;
    diff = diff/ 2;
    ColourEllipsoids(ColourInds, [rginda, ybinda]) = ColourEllipsoids(ColourInds, [rginda, ybinda]) + diff;
  elseif LabAvg(lumindc) < (lumavg - 0.25 * lumavg)
    ColourInds = [9, 10];
    diff = ColourEllipsoids(ColourInds, [rginda, ybinda]) .* lumstdper;
    diff(1, :) = diff(1, :) / 2;
    diff = diff/ 2;
    ColourEllipsoids(ColourInds, [rginda, ybinda]) = ColourEllipsoids(ColourInds, [rginda, ybinda]) + diff;
  else
    ColourInds = [10, 11];
    diff = ColourEllipsoids(ColourInds, [rginda, ybinda]) .* lumstdper;
    diff = diff/ 2;
    ColourEllipsoids(ColourInds, [rginda, ybinda]) = ColourEllipsoids(ColourInds, [rginda, ybinda]) + diff;
  end
  fprintf('STD-Lum - Colour %d %d, channel %d, being streched %f %f\n', ColourInds, rgindc, diff(:, 1));
  fprintf('STD-Lum - Colour %d %d, channel %d, being streched %f %f\n', ColourInds, ybindc, diff(:, 2));
end

% if there is more than 0.025 per cent deviation in rg-channel
rgstddiff = abs(LabStd(rgindc) - 0.025 * rgavg);
if rgstddiff > 1
  GreenSmallerPercent = max((1 / rgstddiff), 0.65);
  ColourInds = 1;
  ColourEllipsoids(ColourInds, ybinda) = ColourEllipsoids(ColourInds, ybinda) * GreenSmallerPercent;
  fprintf('STD-RG - Colour %d, channel %d, being shrinked to %f per-cent\n', ColourInds, ybindc, GreenSmallerPercent);
  
  %   ColourEllipsoids(4, luminda) = ColourEllipsoids(4, luminda) / rgstddiff;
  ColourInds = 9:11;
  rgstdper = rgstddiff / (0.025 * rgavg);
  diff = ColourEllipsoids(ColourInds, rginda) .* rgstdper;
  diff = diff / 2;
  ColourEllipsoids(ColourInds, rginda) = ColourEllipsoids(ColourInds, rginda) + diff;
  fprintf('STD-RG - Colour %d %d %d, channel %d, being streched %f %f %f\n', ColourInds, rgindc, diff);
end

% if there is more than 0.025 per cent deviation in yb-channel
ybstddiff = abs(LabStd(ybindc) - 0.025 * ybavg);
if ybstddiff > 1
  %   ColourEllipsoids(2, luminda) = ColourEllipsoids(2, luminda) / ybstddiff;
  ColourInds = 9:11;
  ybstdper = ybstddiff / (0.025 * ybavg);
  diff = ColourEllipsoids(ColourInds, ybinda) .* ybstdper;
  diff = diff/ 2;
  ColourEllipsoids(ColourInds, ybinda) = ColourEllipsoids(ColourInds, ybinda) + diff;
  fprintf('STD-YB - Colour %d %d %d, channel %d, being streched %f %f %f\n', ColourInds, ybindc, diff);
end

end

function ColourEllipsoids = AdaptEllipsoidsAvgs(ColourEllipsoids, configs)

% indices of colour ooponency
lumindc = configs.lumindc;
luminda = configs.luminda;
rgindc = configs.rgindc;
rginda = configs.rginda;
ybindc = configs.ybindc;
ybinda = configs.ybinda;

% middle point of colour opponency
lumavg = configs.lumavg;
rgavg = configs.rgavg;
ybavg = configs.ybavg;

LabAvg = configs.LabAvg;
LabStd = configs.LabStd;

% too dark
if LabAvg(lumindc) < lumavg
  diff = abs(lumavg - LabAvg(lumindc));
  ColourInds = 1;
  ColourEllipsoids(ColourInds, lumindc) = ColourEllipsoids(ColourInds, lumindc) - (diff / 2);
  ColourEllipsoids(ColourInds, luminda) = ColourEllipsoids(ColourInds, luminda) - (diff / 2);
  fprintf('AVG-Lum - Colour %d, channel %d, being shrinked on POS %f\n', ColourInds, lumindc, diff);
  
  ColourInds = 7;
  diff = ColourEllipsoids(ColourInds, rginda) * (LabAvg(lumindc) / lumavg);
  ColourEllipsoids(ColourInds, rgindc) = ColourEllipsoids(ColourInds, rgindc) - (diff / 2);
  ColourEllipsoids(ColourInds, rginda) = ColourEllipsoids(ColourInds, rginda) + (diff / 2);
  fprintf('AVG-Lum - Colour %d, channel %d, being streched on NEG %f\n', ColourInds, rgindc, diff);
  
  ColourInds = 4;
  PinkSmallerPercent = LabAvg(lumindc) / lumavg;
  ColourEllipsoids(ColourInds, luminda) = ColourEllipsoids(ColourInds, luminda) * PinkSmallerPercent;
  fprintf('AVG-Lum - Colour %d, channel %d, being shrinked %f per-cent\n', ColourInds, lumindc, PinkSmallerPercent);
  
  %   ColourInds = 10;
  %   WhiteBigger = ColourEllipsoids(ColourInds, rginda) * (1 - PinkSmaller);
  %   ColourEllipsoids(ColourInds, rgindc) = ColourEllipsoids(ColourInds, rgindc) + WhiteBigger / 2;
  %   ColourEllipsoids(ColourInds, rginda) = ColourEllipsoids(ColourInds, rginda) + WhiteBigger;
end

% too much green
if LabAvg(rgindc) < rgavg
  rgdiff = rgavg - LabAvg(rgindc);
  %   ColourEllipsoids(1, rginda) = ColourEllipsoids(1, rginda) - abs(rgdiff / 2);
  %   ColourEllipsoids(1, rgindc) = ColourEllipsoids(1, rgindc) - rgdiff;
  
  % shift the pink
  %   ColourEllipsoids(4, rgindc) = ColourEllipsoids(4, rgindc) + rgdiff;
  
  % make the achromatic bigger
  diff = abs(rgdiff);
  ColourInds = 9:11;
  ColourEllipsoids(ColourInds, rgindc) = ColourEllipsoids(ColourInds, rgindc) - (diff / 2);
  ColourEllipsoids(ColourInds, rginda) = ColourEllipsoids(ColourInds, rginda) + (diff / 2);
  fprintf('AVG-RG - Colour %d %d %d, channel %d, being streched on NEG %f\n', ColourInds, rgindc, diff);
end

% too much yellow and bright
if LabAvg(ybindc) > ybavg
  ybdiff = ybavg - LabAvg(ybindc);
  
  if LabAvg(lumindc) > (lumavg + 0.25 * lumavg)
    % shift the blue
    ColourInds = 2;
    ColourEllipsoids(ColourInds, ybindc) = ColourEllipsoids(ColourInds, ybindc) + ybdiff;
    fprintf('AVG-YB - Colour %d, channel %d, shifts centre on POS %f\n', ColourInds, ybindc, ybdiff);
  end
  
  % make the achromatic bigger
  ColourInds = 9:11;
  ColourEllipsoids(ColourInds, ybindc) = ColourEllipsoids(ColourInds, ybindc) + (ybdiff / 2);
  ColourEllipsoids(ColourInds, ybinda) = ColourEllipsoids(ColourInds, ybinda) + abs(ybdiff / 2);
  fprintf('AVG-YB - Colour %d %d %d, channel %d, shifts centre on POS %f\n', ColourInds, ybindc, ybdiff);
end

for ColourInds = 9:11
  ColourEllipsoids = CoverAvgStd(ColourEllipsoids, ColourInds, LabAvg, LabStd, rgindc, rginda);
  ColourEllipsoids = CoverAvgStd(ColourEllipsoids, ColourInds, LabAvg, LabStd, ybindc, ybinda);
end

end

function ColourEllipsoids = CoverAvgStd(ColourEllipsoids, ColourInds, LabAvg, LabStd, indc, inda)

poslim = ColourEllipsoids(ColourInds, indc) + ColourEllipsoids(ColourInds, inda);

if poslim < LabAvg(indc) + LabStd(indc)
  diff = abs(poslim - LabAvg(indc) - LabStd(indc));
  ColourEllipsoids(ColourInds, indc) = ColourEllipsoids(ColourInds, indc) + (diff / 2);
  ColourEllipsoids(ColourInds, inda) = ColourEllipsoids(ColourInds, inda) + (diff / 2);
  fprintf('AVG-STD - Colour %d, channel %d, being streched on POS %f\n', ColourInds, indc, diff);
end

neglim = ColourEllipsoids(ColourInds, indc) - ColourEllipsoids(ColourInds, inda);
if neglim > LabAvg(indc) - LabStd(indc)
  diff = abs(neglim - LabAvg(indc) - LabStd(indc));
  ColourEllipsoids(ColourInds, indc) = ColourEllipsoids(ColourInds, indc) - (diff / 2);
  ColourEllipsoids(ColourInds, inda) = ColourEllipsoids(ColourInds, inda) + (diff / 2);
  fprintf('AVG-STD - Colour %d, channel %d, being streched on NEG %f\n', ColourInds, indc, diff);
end

end
