%% Initialisation

clearvars;
% close all;
clc;

dociwam = 0;
docolourconstancy = 0;
donoiseremoval = 0;
docomparegt = 0;

ColourSpace = 'lab';

[ImageRGB, GroundTruth] = ColourBoxes();

ImageRGB = WcsChart();
GroundTruth = WcsResults({'berlin', 'sturges', 'benavente'});

% ImageRGB = imread('/home/arash/Software/Repositories/neurobit/data/dataset/ColourNameDataset/ebay/cars/black/011.jpg');
ImageRGB = imread('peppers.png');
GroundTruth = [];

% ImageRGB = MacbethColourChecker();
% [ImageRGB, GroundTruth] = SatfacesColourCube();

%% Colour constancy

if docolourconstancy
  ColourConstantImage = ColourConstancyACE(ImageRGB);
  ColourConstantImage = uint8(NormaliseChannel(ColourConstantImage, 0, 255, [], []));
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
end

%% Colour categorisation

PlotResults = 1;
BelongingImage = rgb2belonging(CategorisationInput, ColourSpace, [], PlotResults, GroundTruth);

% PostProcessedImage = PostProcessBelongingImage(ImageRGB, BelongingImage, 1);

%% compare with gt
if docomparegt
  ColouredBelongingImage = belonging2naming(BelongingImage);
  [ErrorIndsB, GtIndsB] = CompareResultGroundTruth(ColouredBelongingImage, belonging2naming(WcsResults({'berlin'})));
  [ErrorIndsS, GtIndsS] = CompareResultGroundTruth(ColouredBelongingImage, belonging2naming(WcsResults({'sturges'})));
  
  figure;
  subplot(121);image(ColourLabelImage(ErrorIndsB));
  subplot(122);image(ColourLabelImage(GtIndsB));
  figure;
  subplot(121);image(ColourLabelImage(ErrorIndsS));
  subplot(122);image(ColourLabelImage(GtIndsS));
end

%% Noise removal

if donoiseremoval
  [rows, cols, chns] = size(BelongingImage);
  [~, inds] = max(BelongingImage(:, :, 1:chns), [], 3);
  
  FilteresInds = medfilt2(inds, 'symmetric');
  
  NoiseRemovedImg = ColourLabelImage(FilteresInds, EllipsoidsRGBs);
  
  figure('NumberTitle', 'Off', 'Name', 'Colour Categorisation - Noise Removal');
  subplot(1, 2, 1);
  imshow(ColouredBelongingImage);
  title('Coloured Image');
  subplot(1, 2, 2);
  imshow(NoiseRemovedImg);
  title('Noise removed Image');
end
