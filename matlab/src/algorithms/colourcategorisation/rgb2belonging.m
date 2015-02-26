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
  return;
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
