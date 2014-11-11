%% Colour categorisation

clearvars;
close all;
clc;

ConfigsMat = load('2014_ellipsoid_params');
ColourEllipsoids = ConfigsMat.ellipsoids;

ImageRGB = imread('colorapp_pep.png');
PlotResults = 1;
[BelongingImage, ColouredBelongingImage] = RGB2ColourNaming(ImageRGB, ColourEllipsoids, PlotResults);

%% Noise removal

[rows, cols, chns] = size(BelongingImage);
[~, inds] = max(BelongingImage(:, :, 1:chns - 1), [], 3);

FilteresInds = medfilt2(inds, 'symmetric');

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

NoiseRemovedImg = ColourLabelImage(FilteresInds, colors);

figure('NumberTitle', 'Off', 'Name', 'Colour Categorisation - Noise Removal');
subplot(1, 2, 1);
imshow(ColouredBelongingImage, []);
title('Coloured Image');
subplot(1, 2, 2);
imshow(NoiseRemovedImg, []);
title('Noise removed Image');