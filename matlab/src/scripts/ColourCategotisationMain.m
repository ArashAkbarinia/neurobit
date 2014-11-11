%% Initialisation

clearvars;
close all;
clc;

ImageRGB = imread('Macbeth.png');

%% CIWaM

MidaMin = 4; % it must be power of 2. it's recommended not to use 1 ;)
nplans = floor(log(max(size(ImageRGB(:, :, 1)) - 1) / MidaMin) / log(2)) + 1;

WindowSize = [3, 6];
nu0 = 3;
gamma = 1;
sRGBFlag = 0;

PerceivedImage = CIWaM(ImageRGB, WindowSize, nplans, gamma, sRGBFlag, nu0);
minv = min(PerceivedImage(:));
maxv = max(PerceivedImage(:));
PerceivedImage = uint8(255 .* (PerceivedImage - minv) / (maxv - minv));

figure('NumberTitle', 'Off', 'Name', 'Colour Categorisation - CIWaM');
subplot(1, 2, 1);
imshow(ImageRGB);
title('Original Image');
subplot(1, 2, 2);
imshow(PerceivedImage);
title('Perceived Image');

%% Colour categorisation

ConfigsMat = load('2014_ellipsoid_params');
ColourEllipsoids = ConfigsMat.ellipsoids;

PlotResults = 1;
[BelongingImage, ColouredBelongingImage] = RGB2ColourNaming(PerceivedImage, ColourEllipsoids, PlotResults);

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
imshow(ColouredBelongingImage);
title('Coloured Image');
subplot(1, 2, 2);
imshow(NoiseRemovedImg);
title('Noise removed Image');