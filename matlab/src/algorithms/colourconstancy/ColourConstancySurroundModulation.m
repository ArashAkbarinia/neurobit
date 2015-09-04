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
if strcmpi(MethodName, 'arash')
  [dorg, doyb, dowb] = arash(rg, yb, wb, method);
end

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
GaussianSigma = method{3};
ContrastEnlarge = method{4};
SurroundEnlarge = method{5};
s1 = method{6};
s4 = method{7};
c1 = method{8};
c4 = method{9};
nk = method{10};

[rgc, rgs] = RelativePixelContrast(rg, CentreSize, round(SurroundEnlarge) * CentreSize);
mrgc = mean(rgc(:));
mrgs = mean(rgs(:));
% c1 = 1 + mrgc;
% c4 = 1 + mrgs;

sorg = SingleOpponentContrast(rg, GaussianSigma, ContrastEnlarge, nk);

sogr = SingleOpponentGaussian(rg, GaussianSigma * SurroundEnlarge);

ks = linspace(s1, s4, nk);
js = linspace(c1, c4, nk);

dorg = ApplyNeighbourImpact(rg, sorg, sogr, ks, js);

end

function dorg = raque1(rg, method)

CentreSize = method{2};
GaussianSigma = method{3};
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
[rgc, rgs] = RelativePixelContrast(rg, CentreSize, round(SurroundEnlarge) * CentreSize);

rgcth = graythresh(rgc);
rgsth = graythresh(rgs);
rgcbw = im2bw(rgc, rgcth);
rgsbw = im2bw(rgs, rgsth);

mrgc = mean(rgc(:));
mrgs = mean(rgs(:));

sd = (s1 - s4) ./ 3;
s2 = s1 - sd;
s3 = s4 + sd;

s1 = ones(rows, cols) .* s1;
s2 = ones(rows, cols) .* s2;
s3 = ones(rows, cols) .* s3;
s4 = ones(rows, cols) .* s4;

c1 = c1 + mrgc;
c4 = c4 + mrgs;
cd = (c1 - c4) ./ 3;
c2 = c1 - cd;
c3 = c4 + cd;

c1 = ones(rows, cols) .* c1;
c2 = ones(rows, cols) .* c2;
c3 = ones(rows, cols) .* c3;
c4 = ones(rows, cols) .* c4;

dorg = zeros(rows, cols);

dog1a = SingleOpponentGaussian(rg, GaussianSigma);
dog1b = SingleOpponentGaussian(rg, GaussianSigma * ContrastEnlarge);

dog2a = SingleOpponentGaussian(rg, GaussianSigma * SurroundEnlarge);

dorg( rgcbw &  rgsbw) = DoubleOpponent(dog1a( rgcbw &  rgsbw), dog2a( rgcbw &  rgsbw), s1( rgcbw &  rgsbw), c1( rgcbw &  rgsbw));
dorg( rgcbw & ~rgsbw) = DoubleOpponent(dog1a( rgcbw & ~rgsbw), dog2a( rgcbw & ~rgsbw), s2( rgcbw & ~rgsbw), c2( rgcbw & ~rgsbw));
dorg(~rgcbw &  rgsbw) = DoubleOpponent(dog1b(~rgcbw &  rgsbw), dog2a(~rgcbw &  rgsbw), s3(~rgcbw &  rgsbw), c3(~rgcbw &  rgsbw));
dorg(~rgcbw & ~rgsbw) = DoubleOpponent(dog1b(~rgcbw & ~rgsbw), dog2a(~rgcbw & ~rgsbw), s4(~rgcbw & ~rgsbw), c4(~rgcbw & ~rgsbw));

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

function dorg = ApplyNeighbourImpact(rg, sorg, sogr, SurroundImpacts, CentreImpacts)

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
  dorg(ContrastLevels == i) = DoubleOpponent(sorg(ContrastLevels == i), sogr(ContrastLevels == i), SurroundImpacts(i), CentreImpacts(i));
%   dorg(ContrastLevels == i & ~OppositeOrientaions) = DoubleOpponent(sorg(ContrastLevels == i & ~OppositeOrientaions), sogr(ContrastLevels == i & ~OppositeOrientaions), SurroundImpacts(i));
%   j = length(SurroundImpacts) + 1 - i;
%   dorg(ContrastLevels == i & OppositeOrientaions) = DoubleOpponent(sorg(ContrastLevels == i & OppositeOrientaions), sogr(ContrastLevels == i & OppositeOrientaions), -SurroundImpacts(j) * 1.1);
end

% dorg(OppositeOrientaions) = DoubleOpponent(sorg(OppositeOrientaions), sogr(OppositeOrientaions), 0.64);

end

function rfresponse = SingleOpponentContrast(isignal, StartingSigma, ContrastEnlarge, nContrastLevels)

[rows, cols, ~] = size(isignal);

zctr = GetContrastImage(isignal);

if nargin < 4
  nContrastLevels = 4;
end

FinishingSigma = StartingSigma * ContrastEnlarge;
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

function rfresponse = SingleOpponentGaussian(isignal, StartingSigma)

lambdax = StartingSigma;
lambday = StartingSigma;

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