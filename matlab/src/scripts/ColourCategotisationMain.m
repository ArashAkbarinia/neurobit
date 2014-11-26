%% Initialisation

clearvars;
close all;
clc;

dociwam = 0;
docolourconstancy = 0;

ImageRGB = imread('Macbeth.png');

%% Colour constancy

if docolourconstancy
  ColourConstantImage = ColourConstancyACE(ImageRGB);
  CategorisationInput = ColourConstantImage;
  
  figure('NumberTitle', 'Off', 'Name', 'Colour Categorisation - ACE');
  subplot(1, 2, 1);
  imshow(ImageRGB);
  title('Original Image');
  subplot(1, 2, 2);
  imshow(ColourConstantImage);
  title('Colour constancy ACE');
else
  CategorisationInput = ImageRGB;
end

%% CIWaM

if dociwam
  MidaMin = 4; % it must be power of 2. it's recommended not to use 1 ;)
  nplans = floor(log(max(size(ImageRGB(:, :, 1)) - 1) / MidaMin) / log(2)) + 1;
  
  WindowSize = [3, 6];
  nu0 = 3;
  gamma = 1;
  sRGBFlag = 0;
  
  CIWaMImage = CIWaM(ImageRGB, WindowSize, nplans, gamma, sRGBFlag, nu0);
  minv = min(CIWaMImage(:));
  maxv = max(CIWaMImage(:));
  CIWaMImage = uint8(255 .* (CIWaMImage - minv) / (maxv - minv));
  CategorisationInput = CIWaMImage;
  
  figure('NumberTitle', 'Off', 'Name', 'Colour Categorisation - CIWaM');
  subplot(1, 2, 1);
  imshow(ImageRGB);
  title('Original Image');
  subplot(1, 2, 2);
  imshow(CIWaMImage);
  title('Perceived Image');
else
  CategorisationInput = ImageRGB;
end

%% Colour categorisation

ConfigsMat = load('2014_ellipsoid_params');
ColourEllipsoids = ConfigsMat.ellipsoids;
EllipsoidsRGBs = ConfigsMat.RGBValues;
EllipsoidsTitles = ConfigsMat.RGBTitles;

PlotResults = 1;
[BelongingImage, ColouredBelongingImage] = RGB2ColourNaming(CategorisationInput, ColourEllipsoids, PlotResults, EllipsoidsRGBs, EllipsoidsTitles);

%% Noise removal

[rows, cols, chns] = size(BelongingImage);
[~, inds] = max(BelongingImage(:, :, 1:chns - 1), [], 3);

FilteresInds = medfilt2(inds, 'symmetric');

NoiseRemovedImg = ColourLabelImage(FilteresInds, EllipsoidsRGBs);

figure('NumberTitle', 'Off', 'Name', 'Colour Categorisation - Noise Removal');
subplot(1, 2, 1);
imshow(ColouredBelongingImage);
title('Coloured Image');
subplot(1, 2, 2);
imshow(NoiseRemovedImg);
title('Noise removed Image');
