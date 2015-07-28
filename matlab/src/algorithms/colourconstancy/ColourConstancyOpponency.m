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

function dorg = raquel1(rg, method)

CentreSize = method{2};
x = method{3};
ContrastEnlarge = method{4};
SurroundEnlarge = method{5};
s1 = method{6};
s4 = method{7};
c1 = method{8};
c4 = method{9};
nk = method{10};

sorg = SingleOpponentContrast(rg, 1);

EnlargeFactor = 10 / 2.5;
sogr = SingleOpponentGaussian(rg, EnlargeFactor);

ks = linspace(s1, s4, nk);
% OppositeOrientaions = OrinetationSelectivity(rg, 4 / 2.5, 10 / 2.5);
dorg = ApplyNeighbourImpact(rg, sorg, sogr, ks);

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

[rows, cols] = size(rg);

if CentreSize == -1
  CentreSize = floor(visualangle2pixel(0.36, [], [], rows));
end
[rgc, rgs] = RelativePixelContrast(rg, CentreSize, SurroundEnlarge * CentreSize);

rgcth = graythresh(rgc);
rgsth = graythresh(rgs);
rgcbw = im2bw(rgc, rgcth);
rgsbw = im2bw(rgs, rgsth);

% x = 0.80;
% ContrastEnlarge = 2.0;

% SurroundEnlarge = 5.0;

% m1 = 1 - mean(mean((rgc( rgcbw &  rgsbw) + rgs( rgcbw &  rgsbw)))) ./ 2;
% m4 = 1 - mean(mean((rgc(~rgcbw & ~rgsbw) + rgs(~rgcbw & ~rgsbw)))) ./ 2;

% mpercent = m1 / m4;
% s4 = s1 * mpercent;

%%%%%%%%%%%%%%%%%%%%%
% sorg = SingleOpponentContrast(rg, 1);
% 
% EnlargeFactor = 10 / 2.5;
% sogr = SingleOpponentGaussian(rg, EnlargeFactor);
% ks = linspace(s1, s4, nk);
% dorg = ApplyNeighbourImpact(rg, sorg, sogr, ks);
% return;
%%%%%%%%%%%%%%%%%%%%%

sd = (s1 - s4) ./ 3;
s2 = s1 - sd;
s3 = s4 + sd;

s1 = ones(rows, cols) .* s1;
s2 = ones(rows, cols) .* s2;
s3 = ones(rows, cols) .* s3;
s4 = ones(rows, cols) .* s4;

c1 = 1 + mean(rgc(:));
c4 = 1 + mean(rgs(:));
cd = (c1 - c4) ./ 3;
c2 = c1 - cd;
c3 = c4 + cd;

c1 = ones(rows, cols) .* c1;
c2 = ones(rows, cols) .* c2;
c3 = ones(rows, cols) .* c3;
c4 = ones(rows, cols) .* c4;

dorg = zeros(rows, cols);

dog1a = SingleOpponentGaussian(rg, x);
dog1b = SingleOpponentGaussian(rg, x * ContrastEnlarge);

dog2a = SingleOpponentGaussian(rg, x * SurroundEnlarge);

%%%%%%%%%%%%%%%%%%%%%
% [mag1a, dir1a] = imgradient(dog1a);
% [mag1b, dir1b] = imgradient(dog1b);
% [mag2a, dir2a] = imgradient(dog2a);
% 
% dir1a(dir1a < 0) = dir1a(dir1a < 0) + 180;
% dir1b(dir1b < 0) = dir1b(dir1b < 0) + 180;
% dir2a(dir2a < 0) = dir2a(dir2a < 0) + 180;
% 
% dir1a = dir1a ./ 180;
% dir1b = dir1b ./ 180;
% dir2a = dir2a ./ 180;

% s1 = s1 + abs(dir1a - dir2a);
% s1 = s1( rgcbw &  rgsbw);
% 
% s2 = s2 + abs(dir1a - dir2a);
% s2 = s2( rgcbw & ~rgsbw);
% 
% s3 = s3 + abs(dir1b - dir2a);
% s3 = s3(~rgcbw &  rgsbw);
% 
% s4 = s4 + abs(dir1b - dir2a);
% s4 = s4(~rgcbw & ~rgsbw);
%%%%%%%%%%%%%%%%%%%%%

dorg( rgcbw &  rgsbw) = DoubleOpponent(dog1a( rgcbw &  rgsbw), dog2a( rgcbw &  rgsbw), s1( rgcbw &  rgsbw), c1( rgcbw &  rgsbw));
dorg( rgcbw & ~rgsbw) = DoubleOpponent(dog1a( rgcbw & ~rgsbw), dog2a( rgcbw & ~rgsbw), s2( rgcbw & ~rgsbw), c2( rgcbw & ~rgsbw));
dorg(~rgcbw &  rgsbw) = DoubleOpponent(dog1b(~rgcbw &  rgsbw), dog2a(~rgcbw &  rgsbw), s3(~rgcbw &  rgsbw), c3(~rgcbw &  rgsbw));
dorg(~rgcbw & ~rgsbw) = DoubleOpponent(dog1b(~rgcbw & ~rgsbw), dog2a(~rgcbw & ~rgsbw), s4(~rgcbw & ~rgsbw), c4(~rgcbw & ~rgsbw));

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

end

function dorg = OrinetationSelectivity(rg, ContrastSigma, SurroundSigma)

g2rga = ApplyGaussianGradient(rg, ContrastSigma, 2, 4);
g2rgb = ApplyGaussianGradient(rg, SurroundSigma, 2, 4);
dorg = false(size(rg));
j = size(g2rga, 3) / 2;
for i = 1:size(g2rga, 3)
  aedges = logical(im2bw(g2rga(:, :, i), mean2(g2rga(:, :, i))));
  j = j + 1;
  if j > size(g2rga, 3)
    j = 1;
  end
  bedges = logical(im2bw(g2rgb(:, :, j), mean2(g2rgb(:, :, j))));
  dorg = dorg | (aedges & bedges);
end

end

function luminance = CalculateLuminance(dtmap, InputImage)

% to make the comparison exactly like Joost's Grey Edges
SaturationThreshold = max(InputImage(:));
SaturatedPixels = (dilation33(double(max(InputImage, [], 3) >= SaturationThreshold)));
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
MaxVals = PoolingHistMax(dtmap, Cutoff, false);

% MaxVals = ColourConstancyMinkowskiFramework(dtmap, 5);

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

function GaussianGradients = ApplyGaussianGradient(isignal, EnlargeFactor, order, nangles)

if nargin < 4
  nangles = 2;
end

[rows, cols] = size(isignal);

StartingSigma = 2.5;
lambdax = StartingSigma * EnlargeFactor;
lambday = StartingSigma * EnlargeFactor;

angles = 0:pi/nangles:pi;
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

GaussianGradients = sqrt(rfresponse);

end

function rfresponse = SingleOpponentGradientGaussian(isignal, EnlargeFactor, order, nangles)

if nargin < 4
  nangles = 2;
end

GaussianGradients = ApplyGaussianGradient(isignal, EnlargeFactor, order, nangles);
rfresponse = sum(GaussianGradients, 3);

end

function rfresponse = SingleOpponentContrastGradientGaussian(isignal, EnlargeFactor, order, nangles)

if nargin < 4
  nangles = 2;
end

[rows, cols, ~] = size(isignal);

zctr = GetContrastImage(isignal);

nContrastLevels = 4;
StartingSigma = 2 * EnlargeFactor;
FinishingSigma = 4 * EnlargeFactor;
sigmas = linspace(StartingSigma, FinishingSigma, nContrastLevels);

MinPix = min(zctr(:));
MaxPix = max(zctr(:));
step = ((MaxPix - MinPix) / nContrastLevels);
levels = MinPix:step:1;
levels = levels(2:end-1);
ContrastLevels = imquantize(zctr, levels);

nContrastLevels = unique(ContrastLevels(:));
nContrastLevels = nContrastLevels';

angles = 0:pi/nangles:pi;
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
%   dorg(ContrastLevels == i & ~OppositeOrientaions) = DoubleOpponent(sorg(ContrastLevels == i & ~OppositeOrientaions), sogr(ContrastLevels == i & ~OppositeOrientaions), SurroundImpacts(i));
%   j = length(SurroundImpacts) + 1 - i;
%   dorg(ContrastLevels == i & OppositeOrientaions) = DoubleOpponent(sorg(ContrastLevels == i & OppositeOrientaions), sogr(ContrastLevels == i & OppositeOrientaions), -SurroundImpacts(j) * 1.1);
end

% dorg(OppositeOrientaions) = DoubleOpponent(sorg(OppositeOrientaions), sogr(OppositeOrientaions), 0.64);

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

function rfresponse = SingleOpponentGaussian(isignal, EnlargeFactor)

StartingSigma = 2.5;
lambdax = StartingSigma * EnlargeFactor;
lambday = StartingSigma * EnlargeFactor;

rf = GaussianFilter2(lambdax, lambday, 0, 0);
rfresponse = imfilter(isignal, rf, 'replicate');

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