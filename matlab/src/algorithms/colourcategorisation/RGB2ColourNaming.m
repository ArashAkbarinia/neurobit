function [BelongingImage, ColouredBelongingImage] = RGB2ColourNaming(ImageRGB, ColourEllipsoids, plotme)
%RGB2COLOURNAMING Summary of this function goes here
%   Detailed explanation goes here

if nargin > 3
  plotme = 0;
end

[nelpisd, ~] = size(ColourEllipsoids);
[rows, cols, ~] = size(ImageRGB);
BelongingImage = zeros(rows, cols, nelpisd + 1);

% ImageRGB = im2double(ImageRGB);
%
% ColorTransform = makecform('srgb2lab');
% ImageLab = applycform(ImageRGB, ColorTransform);
% ImageXYZ = Lab2XYZ(ImageLab);
% ImagelsY = XYZ2lsY(ImageXYZ, 'evenly_ditributed_stds');
%
% Imagels = reshape(ImagelsY(:, :, 1:2), rows * cols, 2);
% for i = 1:nelpisd
%   [distance, p] = point_to_ellipse(Imagels, ColourEllipsoids(i, [1:2, 4:5, 7]));
%   RSS = ColourEllipsoids(i, 8);
%
%   belonging = (1 + exp(5 .* (RSS .^ -0.5) - distance)) .^ -1;
%   OutputImage(:, :, i) = reshape(belonging, rows, cols);
% end

% gammacorrect = true, max pix value > 1, max luminance = daylight
lsY = XYZ2lsY(sRGB2XYZ(ImageRGB, true, false, [10 ^ 2, 10 ^ 2, 10 ^ 2]), 'evenly_ditributed_stds');

BelongingImage = lsY2Focals(lsY, ColourEllipsoids);

if plotme
  % TODO: add this titles to the ellipsoids themselves
  titles = {'G', 'B', 'Pp', 'Pk', 'R', 'O', 'Y', 'Br', 'Gr', 'Lum'};
  figure('NumberTitle', 'Off', 'Name', 'Colour Categorisation - Colour Planes');
  subplot(3, 5, 2);
  imshow(ImageRGB);
  title('Org');
  subplot(3, 5, 4);
  ColouredBelongingImage = ColourBelongingImage(BelongingImage);
  imshow(ColouredBelongingImage);
  title('Max');
  for i = 1:nelpisd + 1
    subplot(3, 5, i + 5);
    imshow(BelongingImage(:, :, i), []);
    title(titles{i});
  end
end

end

function ColouredBelongingImage = ColourBelongingImage(BelongingImage)

[~, ~, chns] = size(BelongingImage);

% the last channel is the luminance
ncolcats = chns - 1;
[~, inds] = max(BelongingImage(:, :, 1:ncolcats), [], 3);

% TODO: add this titles to the ellipsoids themselves
colors(1, :) = [0, 255, 0];
colors(2, :) = [0, 0, 255];
colors(3, :) = [128, 0, 128];
colors(4, :) = [188, 84, 150];
colors(5, :) = [255, 0, 0];
colors(6, :) = [255, 165, 0];
colors(7, :) = [255, 255, 0];
colors(8, :) = [115, 81, 67];
colors(9, :) = [128, 128, 128];

ColouredBelongingImage = ColourLabelImage(inds, colors);

end