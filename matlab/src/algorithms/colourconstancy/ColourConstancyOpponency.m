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
rgb2do = 1;
do2rgb = rgb2do';

opponent = rgb2do * reshape(InputImageDouble, rows * cols, chns)';
opponent = reshape(opponent', rows, cols, chns);

opponent = opponent ./ max(abs(opponent(:)));
% cone opoonent retinal ganglion cells
rg = opponent(:, :, 1);
yb = opponent(:, :, 2);
wb = opponent(:, :, 3);

if plotme
  PlotLmsOpponency(InputImage);
end

sorg = SingleOpponent(rg, 1);
soyb = SingleOpponent(yb, 1);
sowb = SingleOpponent(wb, 1);

EnlargeFactor = 2;
sogr = SingleOpponent(-rg, EnlargeFactor);
soby = SingleOpponent(-yb, EnlargeFactor);
sobw = SingleOpponent(-wb, EnlargeFactor);

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

function rfresponse = SingleOpponent(isignal, EnlargeFactor)

[rows, cols, ~] = size(isignal);

StartingSigma = 2.5;
lambdax = StartingSigma * EnlargeFactor;
lambday = StartingSigma * EnlargeFactor;

nContrastLevels = 1;
% LevelGap = 1 / nContrastLevels;
% levels = 0:LevelGap:1;
if nContrastLevels > 1
  % zctr = RelativeContrast(isignal);
  zctr = WeberContrast(isignal);

  levels = multithresh(zctr, nContrastLevels - 1);
%   MeanContrast = max(zctr(:));
%   for i = 1:nContrastLevels - 1
%     levels(i) = (i / nContrastLevels) * MeanContrast;
%   end

  ContrastLevels = imquantize(zctr, levels);
  SigmaIncrease = 1 / (nContrastLevels - 1);
  if isinf(SigmaIncrease)
    SigmaIncrease = 0;
  end
else
  ContrastLevels = ones(rows, cols);
  SigmaIncrease = 1;
end

rfresponse = zeros(rows, cols);
for i = nContrastLevels:-1:1
  lambdaxi = lambdax * ((nContrastLevels - i) * SigmaIncrease + 1);
  lambdayi = lambday * ((nContrastLevels - i) * SigmaIncrease + 1);
  rfi = GaussianFilter2(lambdaxi, lambdayi, 0, 0);
  rfresponsei = imfilter(isignal, rfi);
  rfresponse(ContrastLevels == i) = rfresponsei(ContrastLevels == i);
end

% rf = GaussianFilter2(lambdax, lambday);
% rfresponse = imfilter(isignal, rf);

end

function rfresponse = DoubleOpponent(ab, ba, k)

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
