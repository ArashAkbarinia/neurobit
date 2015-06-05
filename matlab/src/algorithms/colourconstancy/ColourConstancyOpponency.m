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

if plotme
  PlotLmsOpponency(InputImage);
end

% cone opoonent retinal ganglion cells
rg = opponent(:, :, 1);
yb = opponent(:, :, 2);
wb = opponent(:, :, 3);

[dorg, doyb, dowb] = ApplyGaussian(rg, yb, wb);
% [dorg, doyb, dowb] = ApplyUnbalancedDog(rg, yb, wb);
% [dorg, doyb, dowb] = ApplyDog(rg, yb, wb);
% [dorg, doyb, dowb] = ApplyGaussianGradient(rg, yb, wb);

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

function [dorg, doyb, dowb] = ApplyGaussianGradient(rg, yb, wb)

dorg = SingleOpponentGradientGaussian(rg, 1);
doyb = SingleOpponentGradientGaussian(yb, 1);
dowb = SingleOpponentGradientGaussian(wb, 1);

end

function rfresponse = SingleOpponentGradientGaussian(isignal, EnlargeFactor)

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
  rfi = GaussianGradient1(rf, angles(i));
%   rfi = GaussianGradient2(rf, angles(i));
  rfresponsei = imfilter(isignal, rfi, 'replicate');
  rfresponse(:, :, i) = (rfresponsei .^ 2) * weights(i);
end

rfresponse = sqrt(rfresponse);
rfresponse = sum(rfresponse, 3);

end

function [dorg, doyb, dowb] = ApplyGaussian(rg, yb, wb)

% fun = @(bs) imfilter(bs.data, GaussianFilter2(std2(bs.data)), 'replicate');
% 
% dorg = blockproc(rg, [64, 64], fun);
% doyb = blockproc(yb, [64, 64], fun);
% dowb = blockproc(wb, [64, 64], fun);

% dorg = SingleOpponentGaussian(rg, 1);
% doyb = SingleOpponentGaussian(yb, 1);
% dowb = SingleOpponentGaussian(wb, 1);

dorg = SingleOpponentContrast(rg, 1);
doyb = SingleOpponentContrast(yb, 1);
dowb = SingleOpponentContrast(wb, 1);

end

function [dorg, doyb, dowb] = ApplyDog(rg, yb, wb)

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

function [dorg, doyb, dowb] = ApplyUnbalancedDog(rg, yb, wb)

sorg = SingleOpponent(rg, 1);
soyb = SingleOpponent(yb, 1);
sowb = SingleOpponent(wb, 1);

EnlargeFactor = 2;
sogr = SingleOpponent(-rg, EnlargeFactor);
soby = SingleOpponent(-yb, EnlargeFactor);
sobw = SingleOpponent(-wb, EnlargeFactor);

k = 0.7;
dorg = DoubleOpponent(sorg, sogr, k);
doyb = DoubleOpponent(soyb, soby, k);
dowb = DoubleOpponent(sowb, sobw, k);

end

function rfresponse = SingleOpponent(isignal, EnlargeFactor)

rfresponse = SingleOpponentGaussian(isignal, EnlargeFactor);
% rfresponse = SingleOpponentContrast(isignal, EnlargeFactor);

end

function rfresponse = SingleOpponentContrast(isignal, EnlargeFactor)

[rows, cols, ~] = size(isignal);

nContrastLevels = 6;
% StartingSigma = sqrt(nContrastLevels) / 2;
StartingSigma = 1.25 * EnlargeFactor;
% FinishingSigma = nContrastLevels * 2.2;
FinishingSigma = 17.6 * EnlargeFactor;
sigmas = linspace(StartingSigma, FinishingSigma, nContrastLevels);

% zctr = RelativeContrast(isignal);
contrastweb = WeberContrast(isignal);
% contrastweb = NormaliseChannel(contrastweb);
contraststd = stdfilt(isignal);
% contraststd = NormaliseChannel(contraststd);
zctr = (contraststd + contrastweb) ./ 2;

levels = linspace(0.001, 0.8, nContrastLevels - 1);
ContrastLevels = imquantize(zctr, levels);

nContrastLevels = max(ContrastLevels(:));

rfresponse = zeros(rows, cols);
for i = nContrastLevels:-1:1
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
