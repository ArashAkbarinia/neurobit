function [ColourConstantImage, luminance] = ColourConstancyOpponency(InputImage, plotme, method)
%ColourConstancyOpponency Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
  plotme = 0;
end

if nargin < 3
  method = 'udog';
end

if plotme
  PlotRgb(InputImage);
end

% to make the comparison exactly like Joost's Grey Edges
SaturationThreshold = max(InputImage(:));
SaturatedPixels = (dilation33(double(max(InputImage, [], 3) >= SaturationThreshold)));
SaturatedPixels = double(SaturatedPixels == 0);
sigma = 2;
SaturatedPixels = set_border(SaturatedPixels, sigma + 1, 0);

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
rgb2do = 1;
do2rgb = rgb2do';

opponent = rgb2do * reshape(InputImageDouble, rows * cols, chns)';
opponent = reshape(opponent', rows, cols, chns);

opponent = opponent ./ MaxVal;

if plotme
  PlotLmsOpponency(InputImage);
end

% cone opoonent retinal ganglion cells
rg = opponent(:, :, 1);
yb = opponent(:, :, 2);
wb = opponent(:, :, 3);

if strcmpi(method, 'cgaussian')
  [dorg, doyb, dowb] = ApplyGaussianContrast(rg, yb, wb);
elseif strcmpi(method, 'gaussian')
  [dorg, doyb, dowb] = ApplyGaussianNormal(rg, yb, wb);
elseif strcmpi(method, 'cudog')
  [dorg, doyb, dowb] = ApplyUnbalancedDogContrast(rg, yb, wb);
elseif strcmpi(method, 'udog')
  [dorg, doyb, dowb] = ApplyUnbalancedDogNormal(rg, yb, wb);
end
% [dorg, doyb, dowb] = ApplyDog(rg, yb, wb);
% [dorg, doyb, dowb] = ApplyGaussianGradient1(rg, yb, wb);
% [dorg, doyb, dowb] = ApplyGaussianGradient2(rg, yb, wb);

if plotme
  figure;
  FigRow = 2;
  FigCol = 2;
  subplot(FigRow, FigCol, 1); imshow(dorg, []); title('DO R-G');
  subplot(FigRow, FigCol, 2); imshow(doyb, []); title('DO G-R');
  subplot(FigRow, FigCol, 3:4); imshow(dowb, []); title('DO Luminance');
end

doresponse = zeros(rows, cols, chns);
doresponse(:, :, 1) = dorg;
doresponse(:, :, 2) = doyb;
doresponse(:, :, 3) = dowb;
doresponse = reshape(doresponse, rows * cols, chns);
dtmap = (do2rgb * doresponse')';
dtmap = reshape(dtmap, rows, cols, chns);

dtmap(:, :, 1) = dtmap(:, :, 1) .* SaturatedPixels;
dtmap(:, :, 2) = dtmap(:, :, 2) .* SaturatedPixels;
dtmap(:, :, 3) = dtmap(:, :, 3) .* SaturatedPixels;
luminance = CalculateLuminance(dtmap);
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

function luminance = CalculateLuminance(dtmap)

dtmap = dtmap ./ max(dtmap(:));
stddtmap = mean(mean(LocalStdContrast(dtmap, 3)));
stddtmap = reshape(stddtmap, 1, 3);
Cutoff = mean(stddtmap);
dtmap = dtmap .* ((2 ^ 16) - 1);

% MaxVals = max(max(dtmap));
MaxVals = PoolingHistMax(dtmap, Cutoff);
luminance = MaxVals;

end

function [dorg, doyb, dowb] = ApplyGaussianGradient1(rg, yb, wb)

% dorg = SingleOpponentGradientGaussian(rg, 1, 1);
% doyb = SingleOpponentGradientGaussian(yb, 1, 1);
% dowb = SingleOpponentGradientGaussian(wb, 1, 1);

dorg = SingleOpponentContrastGradientGaussian(rg, 1, 1);
doyb = SingleOpponentContrastGradientGaussian(yb, 1, 1);
dowb = SingleOpponentContrastGradientGaussian(wb, 1, 1);

end

function [dorg, doyb, dowb] = ApplyGaussianGradient2(rg, yb, wb)

% dorg = SingleOpponentGradientGaussian(rg, 1, 2);
% doyb = SingleOpponentGradientGaussian(yb, 1, 2);
% dowb = SingleOpponentGradientGaussian(wb, 1, 2);

dorg = SingleOpponentContrastGradientGaussian(rg, 1, 2);
doyb = SingleOpponentContrastGradientGaussian(yb, 1, 2);
dowb = SingleOpponentContrastGradientGaussian(wb, 1, 2);

end

function rfresponse = SingleOpponentGradientGaussian(isignal, EnlargeFactor, order)

[rows, cols] = size(isignal);

StartingSigma = 2.5;
lambdax = StartingSigma * EnlargeFactor;
lambday = StartingSigma * EnlargeFactor;

angles = 0:pi/2:pi;
chns = length(angles) - 1;
weights = ones(length(angles), 1);
weights([1, ceil(end / 2), end]) = 1;
rfresponse = zeros(rows, cols, chns);

rf = GaussianFilter2(lambdax, lambday, 0, 0);

for i = 1:chns
  if order == 1
    rfi = GaussianGradient1(rf, angles(i));
  elseif order == 2
    rfi = GaussianGradient2(rf, angles(i));
  end
  rfresponsei = imfilter(isignal, rfi, 'replicate');
  rfresponse(:, :, i) = (rfresponsei .^ 2) * weights(i);
end

rfresponse = sqrt(rfresponse);
rfresponse = sum(rfresponse, 3);

end

function rfresponse = SingleOpponentContrastGradientGaussian(isignal, EnlargeFactor, order)

[rows, cols] = size(isignal);

contraststd = LocalStdContrast(isignal, 3);
zctr = 1 - contraststd;

nContrastLevels = 4;
StartingSigma = 1.25 * EnlargeFactor;
FinishingSigma = 12 * StartingSigma * EnlargeFactor;
sigmas = linspace(StartingSigma, FinishingSigma, nContrastLevels);
% StartingSigma = 1.5 * EnlargeFactor;
% sigmas = zeros(1, nContrastLevels);
% for i = 1:nContrastLevels
%   sigmas(i) = StartingSigma ^ i;
% end
sigmas = sigmas(end:-1:1);

levels = 0:(1.0 / nContrastLevels):1;
levels = levels(2:end-1);
ContrastLevels = imquantize(zctr, levels);

nContrastLevels = max(ContrastLevels(:));

angles = 0:pi/2:pi;
chns = length(angles) - 1;
weights = ones(length(angles), 1);
weights([1, ceil(end / 2), end]) = 1;
rfresponse = zeros(rows, cols, chns);

for i = 1:chns
  for j = 1:nContrastLevels
    lambdaxj = sigmas(j);
    lambdayj = sigmas(j);
    rf = GaussianFilter2(lambdaxj, lambdayj, 0, 0);
    
    if order == 1
      rfi = GaussianGradient1(rf, angles(i));
    elseif order == 2
      rfi = GaussianGradient2(rf, angles(i));
    end
    rfresponsei = imfilter(isignal, rfi, 'replicate');
    rfresponsei = (rfresponsei .^ 2) * weights(i);
    PreviousRfresponse = rfresponse(:, :, i);
    PreviousRfresponse(ContrastLevels == j) = rfresponsei(ContrastLevels == j);
    rfresponse(:, :, i) = PreviousRfresponse;
  end
end

rfresponse = sqrt(rfresponse);
rfresponse = sum(rfresponse, 3);

end

function [dorg, doyb, dowb] = ApplyGaussianNormal(rg, yb, wb)

dorg = SingleOpponentGaussian(rg, 1);
doyb = SingleOpponentGaussian(yb, 1);
dowb = SingleOpponentGaussian(wb, 1);

end

function [dorg, doyb, dowb] = ApplyGaussianContrast(rg, yb, wb)

dorg = SingleOpponentContrast(rg, 1);
doyb = SingleOpponentContrast(yb, 1);
dowb = SingleOpponentContrast(wb, 1);

end

function [dorg, doyb, dowb] = ApplyDog(rg, yb, wb)

% TODO: add k here because unbalcned Dog can be faster implemented

StartingSigma = 2.5;
lambdax = StartingSigma;
lambday = StartingSigma;
rf1 = GaussianFilter2(lambdax, lambday, 0, 0);

EnlargeFactor = 2;
lambdax = StartingSigma * EnlargeFactor;
lambday = StartingSigma * EnlargeFactor;
rf2 = GaussianFilter2(lambdax, lambday, 0, 0);

rf = dog2(rf1, rf2);
dorg = imfilter(rg, rf, 'replicate');
doyb = imfilter(yb, rf, 'replicate');
dowb = imfilter(wb, rf, 'replicate');

end

function [dorg, doyb, dowb] = ApplyUnbalancedDogNormal(rg, yb, wb)

sorg = SingleOpponentGaussian(rg, 1);
soyb = SingleOpponentGaussian(yb, 1);
sowb = SingleOpponentGaussian(wb, 1);

EnlargeFactor = 2;
sogr = SingleOpponentGaussian(-rg, EnlargeFactor);
soby = SingleOpponentGaussian(-yb, EnlargeFactor);
sobw = SingleOpponentGaussian(-wb, EnlargeFactor);

k = 0.7;
dorg = DoubleOpponent(sorg, sogr, k);
doyb = DoubleOpponent(soyb, soby, k);
dowb = DoubleOpponent(sowb, sobw, k);

end

function [dorg, doyb, dowb] = ApplyUnbalancedDogContrast(rg, yb, wb)

sorg = SingleOpponentContrast(rg, 1);
soyb = SingleOpponentContrast(yb, 1);
sowb = SingleOpponentContrast(wb, 1);

EnlargeFactor = 2;
sogr = SingleOpponentContrast(-rg, EnlargeFactor);
soby = SingleOpponentContrast(-yb, EnlargeFactor);
sobw = SingleOpponentContrast(-wb, EnlargeFactor);

k = 0.7;
dorg = DoubleOpponent(sorg, sogr, k);
doyb = DoubleOpponent(soyb, soby, k);
dowb = DoubleOpponent(sowb, sobw, k);

end

function rfresponse = SingleOpponentContrast(isignal, EnlargeFactor)

[rows, cols, ~] = size(isignal);

contraststd = LocalStdContrast(isignal, 3);
zctr = 1 - contraststd;

nContrastLevels = 4;
StartingSigma = 1.5 * EnlargeFactor;
FinishingSigma = 3.5 * EnlargeFactor;
sigmas = linspace(StartingSigma, FinishingSigma, nContrastLevels);

MinPix = min(zctr(:));
MaxPix = max(zctr(:));
step = ((MaxPix - MinPix) / nContrastLevels);
levels = MinPix:step:1;
levels = levels(2:end-1);
ContrastLevels = imquantize(zctr, levels);

nContrastLevels = unique(ContrastLevels(:));
nContrastLevels = nContrastLevels';

rfresponse = zeros(rows, cols);
for i = nContrastLevels
  lambdaxi = sigmas(i);
  lambdayi = sigmas(i);
  rfi = GaussianFilter2(lambdaxi, lambdayi, 0, 0);
  rfresponsei = imfilter(isignal, rfi, 'replicate');
  rfresponse(ContrastLevels == i) = rfresponsei(ContrastLevels == i);
end

end

function rfresponse = SingleOpponentGaussian(isignal, EnlargeFactor)

StartingSigma = 2.5;
lambdax = StartingSigma * EnlargeFactor;
lambday = StartingSigma * EnlargeFactor;

rf = GaussianFilter2(lambdax, lambday, 0, 0);
rfresponse = imfilter(isignal, rf, 'replicate');

end

function rfresponse = DoubleOpponent(ab, ba, k)

if nargin < 3
  k = 0.5;
end

rfresponse = ab + k .* ba;
rfresponse = sum(rfresponse, 3);

end
