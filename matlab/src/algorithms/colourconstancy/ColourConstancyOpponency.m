function [ColourConstantImage, luminance] = ColourConstancyOpponency(InputImage, plotme)
%ColourConstancyOpponency Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
  plotme = 0;
end

if plotme
  PlotRgb(InputImage);
end

[rows, cols, chns] = size(InputImage);
InputImageDouble = double(InputImage);

% EQUATION: eq-2.4-2.8 Ebner 2007, "Color Constancy"
rgb2do = ...
  [
  1 / sqrt(2), -1 / sqrt(2),  0;
  1 / sqrt(6),  1 / sqrt(6), -sqrt(2 / 3);
  1 / sqrt(3),  1 / sqrt(3),  1 / sqrt(3);
  ];
do2rgb = rgb2do';

opponent = rgb2do * reshape(InputImageDouble, rows * cols, chns)';
opponent = reshape(opponent', rows, cols, chns);

% cone opoonent retinal ganglion cells
rg = opponent(:, :, 1);
yb = opponent(:, :, 2);
wb = opponent(:, :, 3);

if plotme
  PlotLmsOpponency(InputImage);
end

lambda = 3;
sorg = SingleOpponent(rg, lambda);
soyb = SingleOpponent(yb, lambda);
sowb = SingleOpponent(wb, lambda);

lambda = lambda * 2;
sogr = SingleOpponent(-rg, lambda);
soby = SingleOpponent(-yb, lambda);
sobw = SingleOpponent(-wb, lambda);

k = 0.9;
dorg = DoubleOpponent(sorg, sogr, k);
doyb = DoubleOpponent(soyb, soby, k);
dowb = DoubleOpponent(sowb, sobw, k);

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

% luminance = mean(mean(dtmap));
MaxVals = max(max(dtmap));
luminance = MaxVals;

end

function rfresponse = SingleOpponent(isignal, lambda)

if nargin < 2
  lambda = 3;
end

CentreSize = 5;
SurroundSize = 11;
hc = fspecial('average', CentreSize);
MeanCentre = conv2(isignal, hc / CentreSize ^ 2, 'same');
SigmaCentre = sqrt(conv2(isignal .^ 2, hc / CentreSize ^ 2, 'same') - MeanCentre .^ 2);

hs = fspecial('average', SurroundSize);
MeanSurround = conv2(isignal, hs / SurroundSize ^ 2, 'same');
SigmaSurround = sqrt(conv2(isignal .^ 2, hs / SurroundSize ^ 2, 'same') - MeanSurround .^ 2);

% EQUATION: eq-4 Otazu et al. 2007, "Multiresolution wavelet framework
% models brightness induction effect"
r    = SigmaCentre ./ (SigmaSurround + 1.e-6);
zctr = r .^ 2 ./ (1 + r .^ 2);

% nContrastLevels = 8;
% levels = multithresh(zctr, nContrastLevels - 1);
nContrastLevels = 4;
LevelGap = 1 / nContrastLevels;
levels = 0:LevelGap:1;
ContrastLevels = imquantize(zctr, levels(2:end-1));
SigmaIncrease = 1 / (nContrastLevels - 1);

rfresponse = zeros(size(zctr));
for i = nContrastLevels:-1:1
  lambdax = lambda * ((nContrastLevels - i) * SigmaIncrease + 1);
  lambday = lambda * 1.05 * ((nContrastLevels - i) * SigmaIncrease + 1);
  rfi = GaussianFilter2(lambdax, lambday, 0, 0);
  rfresponsei = imfilter(isignal, rfi);
  rfresponse(ContrastLevels == i) = rfresponsei(ContrastLevels == i);
end

% rf = GaussianFilter2(lambda, lambda + 1, 0, 0);
% rfresponse = imfilter(isignal, rf);

end

function  rfresponse = DoubleOpponent(ab, ba, k)

if nargin < 3
  k = 0.5;
end

rfresponse = ab + k .* ba;

end

function rgim = PlottableRgOpponency(rch, gch)

rgim(:, :, 1) =  rch - gch;
rgim(:, :, 2) = -rch + gch;
rgim(:, :, 3) = 0;
rgim = NormaliseChannel(rgim, [], [], [], []);

end

function ybim = PlottableYbOpponency(rch, gch, bch)

ybim(:, :, 1) =  rch + gch - bch;
ybim(:, :, 2) =  rch + gch - bch;
ybim(:, :, 3) = -rch - gch + bch;
ybim = NormaliseChannel(ybim, [], [], [], []);

end
