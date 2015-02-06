function BelongingImage = rgb2belonging(ImageRGB, ColourSpace, ConfigsMat, plotme, GroundTruth)
%RGB2BELONGING  labels each pixel in the image as one of the focal
%               eleven colours.

if nargin < 2
  ColourSpace = 'lab';
end
ColourSpace = lower(ColourSpace);

if nargin < 5
  plotme = 0;
end

ColourConstantImage = ColourConstancyACE(ImageRGB);
ColourConstantImage = uint8(NormaliseChannel(ColourConstantImage, 0, 255, [], []));

% TODO: make a more permanent solution, this is just becuase 0 goes to the
% end of the world
ImageRGB = ImageRGB + 1;

if strcmpi(ColourSpace, 'lsy')
  if isempty(ConfigsMat)
    ConfigsMat = load('lsy_ellipsoid_params');
  end
  % gammacorrect = true, max pix value > 1, max luminance = daylight
  ImageOpponent = XYZ2lsY(sRGB2XYZ(ImageRGB, true, [10 ^ 2, 10 ^ 2, 10 ^ 2]), 'evenly_ditributed_stds');
  ImageOpponentConstant = XYZ2lsY(sRGB2XYZ(ColourConstantImage, true, [10 ^ 2, 10 ^ 2, 10 ^ 2]), 'evenly_ditributed_stds');
  axes = {'l', 's', 'y'};
elseif strcmpi(ColourSpace, 'lab')
  if isempty(ConfigsMat)
    ConfigsMat = load('lab_ellipsoid_params');
  end
  ImageOpponent = double(applycform(ImageRGB, makecform('srgb2lab')));
  ImageOpponentConstant = double(applycform(ColourConstantImage, makecform('srgb2lab')));
  axes = {'l', 'a', 'b'};
end
ColourEllipsoids = ConfigsMat.ColourEllipsoids;

% BelongingImage(:, :, 1:8) = ChromaticEllipsoidBelonging(ImageOpponent, ColourEllipsoids);
BelongingImage = AllEllipsoidsEvaluateBelonging(ImageOpponent, ColourEllipsoids);
% BelongingImage(:, :, 9:11) = max(AchromaticEllipsoidBelonging(ImageOpponentConstant, ColourEllipsoids), BelongingImage(:, :, 9:11));
BelongingImage(:, :, 9:11) = AchromaticEllipsoidBelonging(ImageOpponentConstant, ColourEllipsoids) * 0.33 + BelongingImage(:, :, 9:11);

if plotme
  EllipsoidsTitles = ConfigsMat.RGBTitles;
  EllipsoidsRGBs = name2rgb(EllipsoidsTitles);
  % just for debugging purpose for the small images
  PlotAllPixels(ImageRGB, ImageOpponent, ColourEllipsoids, EllipsoidsRGBs, axes, GroundTruth, -1);
  
  PlotAllChannels(ImageRGB, BelongingImage, EllipsoidsTitles, EllipsoidsRGBs, 'Colour Categorisation - Colour Planes');
  if ~isempty(GroundTruth)
    PlotAllChannels(ImageRGB, GroundTruth, EllipsoidsTitles, EllipsoidsRGBs, 'Colour Categorisation - Ground Truth');
  end
end

end

function [] = PlotAllPixels(ImageRGB, ImageOpponent, ColourEllipsoids, EllipsoidsRGBs, axes, GroundTruth, ColourIndex)

if isempty(GroundTruth) || isempty(ColourIndex)
  return;
end

[rows, cols, chns] = size(ImageOpponent);
if ColourIndex == -1
  GroundTruth = ones(rows, cols, 1);
  ColourIndex = 1;
end

ImageRGB = im2double(ImageRGB);
ImageRGB = reshape(ImageRGB, rows * cols, chns);
ImageOpponent = reshape(ImageOpponent, rows * cols, chns);

AxesViews = [0, 90; 0, 0; 90, 0;];
if rows * cols < 500
  nfigures = 3;
else
  nfigures = 1;
end
figure();
for k = 1:nfigures
  h = subplot(1, nfigures, k);
  hold on;
  grid on;
  scatter3(ImageOpponent(:, 1), ImageOpponent(:, 2), ImageOpponent(:, 3), 36, ImageRGB);
  %     for i = 1:size(ImageOpponent, 1)
  %       for j = 1:size(ImageOpponent, 2)
  %         if GroundTruth(i, j, ColourIndex) > 0
  %           plot3(ImageOpponent(i, j, 1), ImageOpponent(i, j, 2), ImageOpponent(i, j, 3), 'marker', 'o', 'MarkerFaceColor', im2double(ImageRGB(i, j, :)), 'MarkerEdgeColor', [0, 0, 0]);
  %         end
  %       end
  %     end
  PlotAllEllipsoids(ColourEllipsoids, EllipsoidsRGBs, h);
  xlabel(axes{1});
  ylabel(axes{2});
  zlabel(axes{3});
  view(AxesViews(k, :));
end

end
