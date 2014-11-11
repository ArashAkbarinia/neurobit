%% Colour categorisation

clearvars;
close all;
clc;

ConfigsMat = load('2014_ellipsoid_params');
ColourEllipsoids = ConfigsMat.ellipsoids;

Macbeth = zeros(4, 6, 3); 
Macbeth(:,:,1) = [115, 196,  93,  90, 130,  99; 220,  72, 195,  91, 160, 229;  43,  71, 176, 238, 188,   0; 245, 200, 160, 120, 83, 50];
Macbeth(:,:,2) = [ 81, 149, 123, 108, 129, 191; 123,  92,  84,  59, 189, 161;  62, 149,  48, 200,  84, 136; 245, 201, 161, 121, 84, 50];
Macbeth(:,:,3) = [ 67, 129, 157,  65, 176, 171;  45, 168,  98, 105,  62,  41; 147,  72,  56,  22, 150, 166; 240, 201, 161, 121, 85, 50];
Macbeth = uint8(Macbeth);
% ImageRGB = Macbeth;

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