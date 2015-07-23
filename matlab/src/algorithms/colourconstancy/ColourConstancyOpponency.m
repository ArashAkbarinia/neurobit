function [ColourConstantImage, luminance] = ColourConstancyOpponency(InputImage, plotme, method)
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

MethodName = method{1};
if strcmpi(MethodName, 'cgaussian')
  [dorg, doyb, dowb] = ApplyGaussianContrast(rg, yb, wb);
elseif strcmpi(MethodName, 'gaussian')
  [dorg, doyb, dowb] = ApplyGaussianNormal(rg, yb, wb);
elseif strcmpi(MethodName, 'cudog')
  [dorg, doyb, dowb] = ApplyUnbalancedDogContrast(rg, yb, wb);
elseif strcmpi(MethodName, 'udog')
  [dorg, doyb, dowb] = ApplyUnbalancedDogNormal(rg, yb, wb);
elseif strcmpi(MethodName, 'cd1')
  [dorg, doyb, dowb] = ApplyGaussianGradientContrast1(rg, yb, wb);
elseif strcmpi(MethodName, 'd1')
  [dorg, doyb, dowb] = ApplyGaussianGradientNormal1(rg, yb, wb);
elseif strcmpi(MethodName, 'cd2')
  [dorg, doyb, dowb] = ApplyGaussianGradientContrast2(rg, yb, wb);
elseif strcmpi(MethodName, 'd2')
  [dorg, doyb, dowb] = ApplyGaussianGradientNormal2(rg, yb, wb);
elseif strcmpi(MethodName, 'arash')
  [dorg, doyb, dowb] = arash(rg, yb, wb, method);
end
% [dorg, doyb, dowb] = ApplyDog(rg, yb, wb);

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

function [dorg, doyb, dowb] = arash(rg, yb, wb, method)

dorg = raquel(rg, method);
doyb = raquel(yb, method);
dowb = raquel(wb, method);

end

function dorg = raquel(rg, method)

CentreSize = method{2};
x = method{3};
ContrastEnlarge = method{4};
SurroundEnlarge = method{5};
s1 = method{6};
s4 = method{7};
c1 = method{8};
c4 = method{9};
nk = method{10};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sorg = SingleOpponentContrast(rg, 1);

EnlargeFactor = 4;
sogr = SingleOpponentGaussian(rg, EnlargeFactor);
% sogr = SingleOpponentContrast(rg, 2);

ks = linspace(s1, s4, nk);
dorg = ApplyNeighbourImpact(rg, sorg, sogr, ks);
% dorg(dorg < 0) = 0;
% dorg = dorg ./ max(dorg(:));
% 
% dorg = dorg - rg;
% dorg = rg - dorg;
% dorg(dorg < 0) = 0;

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[rows, cols] = size(rg);

if CentreSize == -1
  CentreSize = floor(visualangle2pixel(0.36, [], [], rows));
end
[rgc, rgs] = RelativePixelContrast(rg, CentreSize, 5 * CentreSize);

rgcth = 0.10;%graythresh(rgc);
rgsth = 0.20;%graythresh(rgs);
rgcbw = im2bw(rgc, rgcth);
rgsbw = im2bw(rgs, rgsth);

% x = 0.80;
% ContrastEnlarge = 2.0;

% SurroundEnlarge = 5.0;

sd = (s1 - s4) / 3;
s2 = s1 - sd;
s3 = s4 + sd;

cd = (c1 - c4) / 3;
c2 = c1 - cd;
c3 = c4 + cd;

dorg = zeros(rows, cols);

dog1a = SingleOpponentGaussian(rg, x);
dog1b = SingleOpponentGaussian(rg, x * ContrastEnlarge);

dog2a = SingleOpponentGaussian(rg, x * SurroundEnlarge);
% dog2b = SingleOpponentGaussian(rg, x * 5.2);

dorg( rgcbw &  rgsbw) = DoubleOpponent(dog1a( rgcbw &  rgsbw), dog2a( rgcbw &  rgsbw), s1);
dorg( rgcbw & ~rgsbw) = DoubleOpponent(dog1a( rgcbw & ~rgsbw), dog2a( rgcbw & ~rgsbw), s2);
dorg(~rgcbw &  rgsbw) = DoubleOpponent(dog1b(~rgcbw &  rgsbw), dog2a(~rgcbw &  rgsbw), s3);
dorg(~rgcbw & ~rgsbw) = DoubleOpponent(dog1b(~rgcbw & ~rgsbw), dog2a(~rgcbw & ~rgsbw), s4);

% either this or that
% dogk1 = SurroundInfluence(rg, x, x * SurroundEnlarge, c1, s1);
% dogk2 = SurroundInfluence(rg, x, x * SurroundEnlarge, c2, s2);
% dogk3 = SurroundInfluence(rg, x * ContrastEnlarge, x * SurroundEnlarge, c3, s3);
% dogk4 = SurroundInfluence(rg, x * ContrastEnlarge, x * SurroundEnlarge, c4, s4);
% 
% dorg( rgcbw &  rgsbw) = dogk1( rgcbw &  rgsbw);
% dorg( rgcbw & ~rgsbw) = dogk2( rgcbw & ~rgsbw);
% dorg(~rgcbw &  rgsbw) = dogk3(~rgcbw &  rgsbw);
% dorg(~rgcbw & ~rgsbw) = dogk4(~rgcbw & ~rgsbw);



% g2rga = SingleOpponentGradientGaussian(rg, x * ContrastEnlarge, 2);
% g2rgb = SingleOpponentGradientGaussian(rg, x * Surroundmatlabpool closeEnlarge, 2);
% for i = 1:2
%   g2rga(:, :, i) = im2bw(g2rga(:, :, i), mean2(g2rga(:, :, i)));
%   g2rgb(:, :, i) = im2bw(g2rgb(:, :, i), mean2(g2rgb(:, :, i)));
% end

% hedgesa = edge(dorg1a, 'prewitt', [], 'horizontal', 'nothinning');
% vedgesa = edge(dorg1a, 'prewitt', [], 'vertical', 'nothinning');
% hedgesb = edge(dorg1b, 'prewitt', [], 'horizontal', 'nothinning');
% vedgesb = edge(dorg1b, 'prewitt', [], 'vertical', 'nothinning');
% 
% dorg(~rgcbw & ~rgsbw) = dorg(~rgcbw & ~rgsbw) .* ~(vedgesa(~rgcbw & ~rgsbw) .* hedgesb(~rgcbw & ~rgsbw)) + (1.0 .* DoubleOpponent(dorg1b(~rgcbw & ~rgsbw), dorg2a(~rgcbw & ~rgsbw), -0.6) .* vedgesa(~rgcbw & ~rgsbw) .* hedgesb(~rgcbw & ~rgsbw));
% dorg(~rgcbw & ~rgsbw) = dorg(~rgcbw & ~rgsbw) .* ~(vedgesa(~rgcbw & ~rgsbw) .* hedgesb(~rgcbw & ~rgsbw)) + (1.0 .* DoubleOpponent(dorg1b(~rgcbw & ~rgsbw), dorg2a(~rgcbw & ~rgsbw), -0.6) .* vedgesb(~rgcbw & ~rgsbw) .* hedgesa(~rgcbw & ~rgsbw));

end

function luminance = CalculateLuminance(dtmap, InputImage)

% to make the comparison exactly like Joost's Grey Edges
SaturationThreshold = max(InputImage(:));
SaturatedPixels = (dilation33(double(max(InputImage, [], 3) >= SaturationThreshold)));
SaturatedPixels = double(SaturatedPixels == 0);
sigma = 2;
SaturatedPixels = set_border(SaturatedPixels, sigma + 1, 0);

for i = 1:3
  tmp = dtmap(:, :, i);
  tmp(tmp < 0) = 0;
  dtmap(:, :, i) = tmp;
  dtmap(:, :, i) = dtmap(:, :, i) .* SaturatedPixels;
end

% MaxVals = max(max(dtmap));

CentreSize = 3;
dtmap = dtmap ./ max(dtmap(:));
StdImg = LocalStdContrast(dtmap, CentreSize);
stddtmap = mean(mean(StdImg));
stddtmap = reshape(stddtmap, 1, 3);
Cutoff = mean(stddtmap);
dtmap = dtmap .* ((2 ^ 8) - 1);
MaxVals = PoolingHistMax(dtmap, Cutoff, false);

% mean(mean(mean(LocalStdContrast(bs.data ./ max(bs.data(:)), CentreSize))))
% fun = @(bs) PoolingHistMax(bs.data, 0.01, true);
% lumr = blockproc(dtmap(:, :, 1), [256, 256], fun);
% lumg = blockproc(dtmap(:, :, 2), [256, 256], fun);
% lumb = blockproc(dtmap(:, :, 3), [256, 256], fun);
% MaxVals = [mean(lumr(:)), mean(lumg(:)), mean(lumb(:))];

luminance = MaxVals;

end

function [dorg, doyb, dowb] = ApplyGaussianGradientNormal1(rg, yb, wb)

dorg = SingleOpponentGradientGaussian(rg, 1, 1);
doyb = SingleOpponentGradientGaussian(yb, 1, 1);
dowb = SingleOpponentGradientGaussian(wb, 1, 1);

end

function [dorg, doyb, dowb] = ApplyGaussianGradientContrast1(rg, yb, wb)

dorg = SingleOpponentContrastGradientGaussian(rg, 1, 1);
doyb = SingleOpponentContrastGradientGaussian(yb, 1, 1);
dowb = SingleOpponentContrastGradientGaussian(wb, 1, 1);

end

function [dorg, doyb, dowb] = ApplyGaussianGradientNormal2(rg, yb, wb)

dorg = SingleOpponentGradientGaussian(rg, 1, 2);
doyb = SingleOpponentGradientGaussian(yb, 1, 2);
dowb = SingleOpponentGradientGaussian(wb, 1, 2);

end

function [dorg, doyb, dowb] = ApplyGaussianGradientContrast2(rg, yb, wb)

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

[rows, cols, ~] = size(isignal);

zctr = GetContrastImage(isignal);

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

angles = 0:pi/2:pi;
chns = length(angles) - 1;
weights = ones(length(angles), 1);
weights([1, ceil(end / 2), end]) = 1;
rfresponse = zeros(rows, cols, chns);

for i = 1:chns
  for j = nContrastLevels
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

function rfresponse = SurroundInfluence(rg, EnlargeFactor, SurroundEnlarge, ci, si)

StartingSigma = 2.5;
lambdax = StartingSigma * EnlargeFactor;
lambday = StartingSigma * EnlargeFactor;
rf1 = GaussianFilter2(lambdax, lambday, 0, 0);

lambdax = StartingSigma * SurroundEnlarge;
lambday = StartingSigma * SurroundEnlarge;
rf2 = GaussianFilter2(lambdax, lambday, 0, 0);

% rf = dog2(rf1, rf2);
rf = rf2 .* si;
m = ceil(size(rf2, 1) / 2);
d = floor(size(rf1, 1) / 2);
rf(m-d:m+d, m-d:m+d) = rf1 + rf2(m-d:m+d, m-d:m+d) .* ci;
% rf(m-d:m+d, m-d:m+d) = rf1 ./ ((rf2(m-d:m+d, m-d:m+d) .* -ci) + 1e-6);

rfresponse = imfilter(rg, rf, 'replicate');

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

EnlargeFactor = 3;
sogr = SingleOpponentGaussian(-rg, EnlargeFactor);
soby = SingleOpponentGaussian(-yb, EnlargeFactor);
sobw = SingleOpponentGaussian(-wb, EnlargeFactor);

k = 0.7;
dorg = DoubleOpponent(sorg, sogr, k);
doyb = DoubleOpponent(soyb, soby, k);
dowb = DoubleOpponent(sowb, sobw, k);

end

function dorg = ApplyNeighbourImpact(rg, sorg, sogr, SurroundImpacts)

nContrastLevels = length(SurroundImpacts);
zctr = GetContrastImage(rg);

MinPix = min(zctr(:));
MaxPix = max(zctr(:));
step = ((MaxPix - MinPix) / nContrastLevels);
levels = MinPix:step:MaxPix;
levels = levels(2:end-1);
ContrastLevels = imquantize(zctr, levels);

nContrastLevels = unique(ContrastLevels(:));
nContrastLevels = nContrastLevels';

dorg = zeros(size(rg));
for i = nContrastLevels
  dorg(ContrastLevels == i) = DoubleOpponent(sorg(ContrastLevels == i), sogr(ContrastLevels == i), SurroundImpacts(i));
end

end

function rfresponse = SingleOpponentContrast(isignal, EnlargeFactor)

[rows, cols, ~] = size(isignal);

zctr = GetContrastImage(isignal);

nContrastLevels = 4;
StartingSigma = 2 * EnlargeFactor;
FinishingSigma = 4 * EnlargeFactor;
sigmas = linspace(StartingSigma, FinishingSigma, nContrastLevels);

MinPix = min(zctr(:));
MaxPix = max(zctr(:));
step = ((MaxPix - MinPix) / nContrastLevels);
levels = MinPix:step:MaxPix;
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

function rfresponse = SingleOpponentGaussian(isignal, EnlargeFactor, iscentre)

StartingSigma = 2.5;
lambdax = StartingSigma * EnlargeFactor;
lambday = StartingSigma * EnlargeFactor;

rf = GaussianFilter2(lambdax, lambday, 0, 0);
if nargin > 2 && iscentre
  rf = rf ./ max(rf(:));
end
rfresponse = imfilter(isignal, rf, 'replicate');

end

function rfresponse = DoubleOpponent(ab, ba, k)

if nargin < 3
  k = 0.5;
end

rfresponse = ab + k .* ba;
rfresponse = sum(rfresponse, 3);

end

function ContrastImage = GetContrastImage(isignal)

contraststd = LocalStdContrast(isignal, 3);
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