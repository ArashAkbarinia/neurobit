function [dtmap, luminance] = ColourConstancySurroundModulation(InputImage, plotme, method)
%ColourConstancyOpponency Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
  plotme = 0;
end

if nargin < 3
  MethodName = 'udog';
end

if plotme
  PlotRgb(InputImage);
end

[rows, cols, chns] = size(InputImage);
if isa(InputImage, 'uint16')
  MaxVal = (2 ^ 16) - 1;
elseif isa(InputImage, 'uint8')
  MaxVal = (2 ^ 8) - 1;
else
  MaxVal = 1;
end
InputImageDouble = double(InputImage);

% EQUATION: eq-2.4-2.8 Ebner 2007, "Color Constancy"
rgb2do = ...
  [
  1 / sqrt(2), -1 / sqrt(2),  0;
  1 / sqrt(6),  1 / sqrt(6), -sqrt(2 / 3);
  1 / sqrt(3),  1 / sqrt(3),  1 / sqrt(3);
  ];

% http://graphics.stanford.edu/~boulos/papers/orgb_sig.pdf
rgb2do = ...
  [
  0.2990,  0.5870,  0.1140;
  0.5000,  0.5000, -1.0000;
  0.8660, -0.8660,  0.0000;
  ];

% rgb2do = 1;
do2rgb = rgb2do';
do2rgb = ...
  [
  1.0000    0.1140    0.7436;
  1.0000    0.1140   -0.4111;
  1.0000   -0.8860    0.1663;
  ];

opponent = rgb2do * reshape(InputImageDouble, rows * cols, chns)';
opponent = reshape(opponent', rows, cols, chns);

opponent = opponent ./ MaxVal;

if plotme
  PlotLmsOpponency(InputImage);
end

doresponse = arash(opponent, method);
doresponse = reshape(doresponse, rows * cols, chns);
dtmap = (do2rgb * doresponse')';
dtmap = reshape(dtmap, rows, cols, chns);

luminance = CalculateLuminance(dtmap, InputImage);
luminance = reshape(luminance, 1, 3);
ColourConstantImage = MatChansMulK(InputImageDouble, 1 ./ luminance);

if plotme
  ColourConstantImage = NormaliseChannel(ColourConstantImage, [], [], [],[]);
  
  ColourConstantImage = uint8(ColourConstantImage .* 255);
  figure;
  subplot(1, 2 , 1);
  imshow(InputImage); title('original');
  subplot(1, 2 , 2);
  imshow(ColourConstantImage); title('Colour constant');
end

end

function doresponse = arash(opponent, method)

[CentreGaussian, SurroundGaussian, FarGaussian] = LoadGaussianProcesses(opponent, method);
[CentreContrast, SurroundContrast, FarContrast] = LoadContrastImages(opponent, method);

doresponse = zeros(size(opponent));
for i = 1:3
  doresponse(:, :, i) = CombineCentreSurround(CentreGaussian(:, :, i), SurroundGaussian(:, :, i), FarGaussian(:, :, i), CentreContrast(:, :, i), SurroundContrast(:, :, i), FarContrast(:, :, i), method);
end

end

function [CentreGaussian, SurroundGaussian, FarGaussian] = LoadGaussianProcesses(opponent, method)

[CentreGaussian, SurroundGaussian, FarGaussian] = GaussianProcesses(opponent, method);

end

function [CentreGaussian, SurroundGaussian, FarGaussian] = GaussianProcesses(opponent, method)

GaussianSigma = method{3};
ContrastEnlarge = method{4};
SurroundEnlarge = method{5};
FarEnlarge = 3 * SurroundEnlarge;
nk = method{10};

CentreGaussian = zeros(size(opponent));
SurroundGaussian = zeros(size(opponent));
FarGaussian = zeros(size(opponent));
for i = 1:3
  CentreGaussian(:, :, i) = SingleOpponentContrast(opponent(:, :, i), GaussianSigma, ContrastEnlarge, nk);
  
  % sogr = SurroundContrast(rg, GaussianSigma, ContrastEnlarge, SurroundEnlarge, nk);
  SurroundGaussian(:, :, i) = SingleOpponentGaussian(opponent(:, :, i), GaussianSigma, SurroundEnlarge);
  
  FarGaussian(:, :, i) = SingleOpponentGaussian(opponent(:, :, i), GaussianSigma, FarEnlarge);
end

end

function [CentreContrast, SurroundContrast, FarContrast] = LoadContrastImages(opponent, method)

[CentreContrast, SurroundContrast, FarContrast] = ContrastProcesses(opponent, method);

end

function [CentreContrast, SurroundContrast, FarContrast] = ContrastProcesses(opponent, method)

CentreSize = method{2};
SurroundEnlarge = method{5};
FarEnlarge = 3 * SurroundEnlarge;

CentreContrast = zeros(size(opponent));
SurroundContrast = zeros(size(opponent));
FarContrast = zeros(size(opponent));
for i = 1:3
  CentreContrast(:, :, i) = GetContrastImage(opponent(:, :, i), CentreSize);
  SurroundContrast(:, :, i) = GetContrastImage(opponent(:, :, i), SurroundEnlarge * CentreSize, CentreSize);
  FarContrast(:, :, i) = GetContrastImage(opponent(:, :, i), FarEnlarge * CentreSize, SurroundEnlarge * CentreSize);
end

end

function dorg = CombineCentreSurround(CentreGaussian, SurroundGaussian, FarGaussian, CentreContrast, SurroundContrast, FarContrast, method)

s1 = method{6};
s4 = method{7};
c1 = method{8};
c4 = method{9};
f1 = method{11};
f4 = method{12};

% [rgc, rgs] = RelativePixelContrast(rg, CentreSize, round(SurroundEnlarge) * CentreSize);
% mrgc = mean(rgc(:));
% mrgs = mean(rgs(:));
% c1 = c1 + mrgc;
% c4 = c4 + mrgs;

CentreWeights = NormaliseChannel(CentreContrast, c1, c4, [], []);
SurroundWeights = NormaliseChannel(SurroundContrast, s1, s4, [], []);
FarWeights = NormaliseChannel(FarContrast, f1, f4, [], []);

% [gmag, gdir] = imgradient(rg);
% gdir(gdir < 0) = gdir(gdir < 0) + 180;
% MeanCentre = MeanCentreSurround(gdir, [3, 3], [0, 0]);
% MeanSurround = MeanCentreSurround(gdir, [15, 15], [3, 3]);
% 
% dirdiff = abs(MeanCentre - MeanSurround);
% dirdiff = NormaliseChannel(dirdiff, 0, 0.1, [], []);

% dorg = ApplyNeighbourImpact(rg, sorg, sogr, sofar, ks, js, fs);
dorg = DoubleOpponent(CentreGaussian, SurroundGaussian, SurroundWeights, CentreWeights);
dorg = dorg + FarWeights .* FarGaussian;

end

function MeanImage = MeanCentreSurround(InputImage, WindowSize, CentreSize)

hc = fspecial('average', WindowSize);
hc = CentreZero(hc, CentreSize);
MeanImage = imfilter(InputImage, hc, 'replicate');

end

function luminance = CalculateLuminance(dtmap, InputImage)

% to make the comparison exactly like Joost's Grey Edges
SaturationThreshold = max(InputImage(:));
DarkThreshold = min(InputImage(:));
MaxImage = max(InputImage, [], 3);
MinImage = min(InputImage, [], 3);
SaturatedPixels = dilation33(double(MaxImage >= SaturationThreshold | MinImage <= DarkThreshold));
SaturatedPixels = double(SaturatedPixels == 0);
sigma = 2;
SaturatedPixels = set_border(SaturatedPixels, sigma + 1, 0);

for i = 1:3
  dtmap(:, :, i) = dtmap(:, :, i) .* (dtmap(:, :, i) > 0);
  dtmap(:, :, i) = dtmap(:, :, i) .* SaturatedPixels;
end

% MaxVals = max(max(dtmap));

CentreSize = 3;
dtmap = dtmap ./ max(dtmap(:));
StdImg = LocalStdContrast(dtmap, CentreSize);
Cutoff = mean(StdImg(:));
dtmap = dtmap .* ((2 ^ 8) - 1);
% MaxVals = PoolingHistMax(dtmap, Cutoff, false);
for i = 1:3
  tmp = dtmap(:, :, i);
  tmp = tmp(SaturatedPixels == 1);
  MaxVals(1, i) = PoolingHistMax2(tmp(:), Cutoff, false);
%   MaxVals(1, i) = max(tmp(:));
end

% MaxVals = ColourConstancyMinkowskiFramework(dtmap, 5);

luminance = MaxVals;

end

function dorg = ApplyNeighbourImpact(rg, sorg, sogr, sofar, SurroundImpacts, CentreImpacts, FarImpacts)

nContrastLevels = length(SurroundImpacts);

CentreContrastImage = GetContrastImage(rg, 3);
CentreContrastLevels = GetContrastLevels(CentreContrastImage, nContrastLevels);

nContrastLevelsCentre = unique(CentreContrastLevels(:));
nContrastLevelsCentre = nContrastLevelsCentre';

SurroundContrastImage = GetContrastImage(rg, 15, 3);
SurroundContrastLevels = GetContrastLevels(SurroundContrastImage, nContrastLevels);

nContrastLevelsSurround = unique(SurroundContrastLevels(:));
nContrastLevelsSurround = nContrastLevelsSurround';

dorg = zeros(size(rg));
for i = nContrastLevelsCentre
  for j = nContrastLevelsSurround
    dorg(CentreContrastLevels == i & SurroundContrastLevels == j) = DoubleOpponent(sorg(CentreContrastLevels == i & SurroundContrastLevels == j), sogr(CentreContrastLevels == i & SurroundContrastLevels == j), SurroundImpacts(j), CentreImpacts(i));
  end
end

end

function rfresponse = SingleOpponentContrast(isignal, StartingSigma, ContrastEnlarge, nContrastLevels)

[rows, cols, ~] = size(isignal);

ContrastImx = GetContrastImage(isignal, [17, 1]);
ContrastImy = GetContrastImage(isignal, [1, 17]);

if nargin < 4
  nContrastLevels = 4;
end

FinishingSigma = StartingSigma * ContrastEnlarge;
sigmas = linspace(StartingSigma, FinishingSigma, nContrastLevels);

ContrastLevelsX = GetContrastLevels(ContrastImx, nContrastLevels);
ContrastLevelsY = GetContrastLevels(ContrastImy, nContrastLevels);

nContrastLevelsX = unique(ContrastLevelsX(:));
nContrastLevelsX = nContrastLevelsX';

nContrastLevelsY = unique(ContrastLevelsY(:));
nContrastLevelsY = nContrastLevelsY';

rfresponse = zeros(rows, cols);
for i = nContrastLevelsX
  lambdaxi = sigmas(i);
  for j = nContrastLevelsY
    lambdayi = sigmas(j);
    rfi = GaussianFilter2(lambdaxi, lambdayi, 0, 0);
    rfresponsei = imfilter(isignal, rfi, 'replicate');
    rfresponse(ContrastLevelsX == i & ContrastLevelsY == j) = rfresponsei(ContrastLevelsX == i & ContrastLevelsY == j);
  end
end

end

function rfresponse = SurroundContrast(isignal, StartingSigma, ContrastEnlarge, SurroundEnlarge, nContrastLevels)

[rows, cols, ~] = size(isignal);

ContrastImx = GetContrastImage(isignal, [17, 1]);
ContrastImy = GetContrastImage(isignal, [1, 17]);

if nargin < 5
  nContrastLevels = 4;
end

FinishingSigma = StartingSigma * ContrastEnlarge;
sigmas = linspace(StartingSigma, FinishingSigma, nContrastLevels);

ContrastLevelsX = GetContrastLevels(ContrastImx, nContrastLevels);
ContrastLevelsY = GetContrastLevels(ContrastImy, nContrastLevels);

nContrastLevelsX = unique(ContrastLevelsX(:));
nContrastLevelsX = nContrastLevelsX';

nContrastLevelsY = unique(ContrastLevelsY(:));
nContrastLevelsY = nContrastLevelsY';

rfs = GaussianFilter2(StartingSigma * SurroundEnlarge, StartingSigma * SurroundEnlarge, 0, 0);

rfresponse = zeros(rows, cols);
for i = nContrastLevelsX
  lambdaxi = sigmas(i);
  for j = nContrastLevelsY
    lambdayi = sigmas(j);
    rfc = GaussianFilter2(lambdaxi, lambdayi, 0, 0);
    rfs = CentreZero(rfs, size(rfc));
    rfresponsei = imfilter(isignal, rfs, 'replicate');
    rfresponse(ContrastLevelsX == i & ContrastLevelsY == j) = rfresponsei(ContrastLevelsX == i & ContrastLevelsY == j);
  end
end

end

function ContrastLevels = GetContrastLevels(ContrastIm, nContrastLevels)

MinPix = min(ContrastIm(:));
MaxPix = max(ContrastIm(:));
step = ((MaxPix - MinPix) / nContrastLevels);
levels = MinPix:step:MaxPix;
levels = levels(2:end-1);
ContrastLevels = imquantize(ContrastIm, levels);

end

function rfresponse = SingleOpponentGaussian(isignal, StartingSigma, SurroundEnlarge)

lambdax = StartingSigma * SurroundEnlarge;
lambday = StartingSigma * SurroundEnlarge;

rfs = GaussianFilter2(lambdax, lambday, 0, 0);

rfresponse = imfilter(isignal, rfs, 'replicate');

end

function rfresponse = DoubleOpponent(ab, ba, k, j)

if nargin < 3
  k = 0.5;
end
if nargin < 4
  j = 1.0;
end

rfresponse = j .* ab + k .* ba;
rfresponse = sum(rfresponse, 3);

end

function ContrastImage = GetContrastImageCentre(isignal, cz)

ContrastImx = GetContrastImage(isignal, [cz, 1]);
ContrastImy = GetContrastImage(isignal, [1, cz]);

ContrastImage = (ContrastImx + ContrastImy) ./ 2;

end

function ContrastImage = GetContrastImageSurround(isignal, cz)

ContrastImx = GetContrastImage(isignal, [cz, cz], [cz, 1]);
ContrastImy = GetContrastImage(isignal, [cz, cz], [1, cz]);

ContrastImage = (ContrastImx + ContrastImy) ./ 2;

end

function ContrastImage = GetContrastImage(isignal, SurroundSize, CentreSize)

if nargin < 2
  SurroundSize = [3, 3];
end
if nargin < 3
  CentreSize = [0, 0];
end
contraststd = LocalStdContrast(isignal, SurroundSize, CentreSize);

% contraststd = stdfilt(isignal);
% rf = dog2(GaussianFilter2(0.5), GaussianFilter2(2.5));
% rf = GaussianGradient2(GaussianFilter2(2.5));
% contraststd = imfilter(isignal, rf, 'replicate');
% contraststd = contraststd + abs(min(contraststd(:)));
% contraststd = contraststd ./ max(contraststd(:));

% [rgc, rgs] = RelativePixelContrast(isignal, 3);
% contraststd = rgc ./ rgs;
% contraststd(isnan(contraststd)) = 0;
% contraststd(isinf(contraststd)) = 1;
% contraststd(contraststd > 1) = 1;

% contraststd = WeberContrast(isignal);
% contraststd = contraststd ./ max(contraststd(:));

ContrastImage = 1 - contraststd;

end

function HistMax = PoolingHistMax2(InputImage, CutoffPercent, UseAveragePixels)

if nargin < 3
  UseAveragePixels = false;
end

npixels = length(InputImage);
HistMax = zeros(1, 1);

MaxVal = max(InputImage(:));
if MaxVal == 0
  return;
end

if MaxVal < (2 ^ 8)
  nbins = 2 ^ 8;
elseif MaxVal < (2 ^ 16)
  nbins = 2 ^ 16;
end

if nargin < 2 || isempty(CutoffPercent)
  CutoffPercent = 0.01;
end

LowerMaxPixels = CutoffPercent .* npixels;
% setting the upper bound to 50% bigger than the lower bound, this means we
% try to find the final HistMax between the lower and upper bounds. However
% if we don't succeed we choose the closest value to the lower bound.
UpperMaxPixels = LowerMaxPixels * 1.5;

for i = 1:1
  ichan = InputImage;
  [ihist, centres] = hist(ichan(:), nbins);
  
  HistMax(1, i) = centres(end);
  jpixels = 0;
  for j = nbins - 1:-1:1
    jpixels = ihist(j) + jpixels;
    if jpixels > LowerMaxPixels(i)
      if jpixels > UpperMaxPixels
        % if we have passed the upper bound, final HistMax is the one
        % before the lower bound.
        HistMax(1, i) = centres(j + 1);
        if UseAveragePixels
          AllBiggerPixels = ichan(ichan >= centres(j + 1));
          HistMax(1, i) = mean(AllBiggerPixels(:));
        end
      else
        HistMax(1, i) = centres(j);
        if UseAveragePixels
          AllBiggerPixels = ichan(ichan >= centres(j));
          HistMax(1, i) = mean(AllBiggerPixels(:));
        end
      end
      break;
    end
  end
end

end