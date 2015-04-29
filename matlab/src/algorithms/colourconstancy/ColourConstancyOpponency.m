function ColourConstantImage = ColourConstancyOpponency(InputImage, plotme)
%ColourConstancyOpponency Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
  plotme = 0;
end

if plotme
  PlotRgb(InputImage);
end

[rows, cols, chns] = size(InputImage);
InputImage = im2double(InputImage);

rch = InputImage(:, :, 1);
gch = InputImage(:, :, 2);
bch = InputImage(:, :, 3);
ych = (rch + gch) ./ 2;
lch = rch + gch + bch;

rgb2do = ...
  [
  1 / sqrt(2), -1 / sqrt(2),  0;
  1 / sqrt(6),  1 / sqrt(6), -2 / sqrt(6);
  1 / sqrt(3),  1 / sqrt(3),  1 / sqrt(3);
  ];
% do2rgb = inv(rgb2do);
opponent = rgb2do * reshape(InputImage, rows * cols, chns)';
opponent = reshape(opponent', rows, cols, chns);

rg = opponent(:, :, 1);
yb = opponent(:, :, 2);
wb = opponent(:, :, 3);

% rg = (rch - gch) ./ sqrt(2);
% yb = (ych - 2 * bch) ./ sqrt(6);
% wb = lch ./ sqrt(3);

if plotme
  PlotLmsOpponency(InputImage);
end

sorg = SingleOpponent(rg, 1);
soyb = SingleOpponent(yb, 1);
sowb = SingleOpponent(wb, 1);

lambda = 3;
sogr = SingleOpponent(-rg, lambda);
soby = SingleOpponent(-yb, lambda);
sobw = SingleOpponent(-wb, lambda);

k = 0.5;
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
dtmap = (rgb2do \ doresponse')';
dtmap = reshape(dtmap, rows, cols, chns);

figure;
subplot(1, 2 , 1);
imshow(InputImage); title('original');
subplot(1, 2 , 2);
imshow(NormaliseChannel(dtmap, [], [], [], [])); title('dt map');
% figure;imshow(NormaliseChannel(dtmap-InputImage, [], [], [], []))

MaxVals = max(max(dtmap));
k = 1 / MaxVals;
ColourConstantImage = MatChansMulK(dtmap, k);

% MaxVals = sum(sum(max(dtmap, [], 3)));
% ColourConstantImage = InputImage ./ MaxVals;

ColourConstantImage = NormaliseChannel(ColourConstantImage, [], [], [],[]);

ColourConstantImage = uint8(ColourConstantImage .* 255);
figure;
subplot(1, 2 , 1);
imshow(InputImage); title('original');
subplot(1, 2 , 2);
imshow(ColourConstantImage); title('Colour constant');

end

function rfresponse = SingleOpponent(isignal, lambda)

if nargin < 2
  lambda = 3;
end

rf = fspecial('gaussian', [3, 3], 0.5 * lambda);

rfresponse = imfilter(isignal, rf);

end

function  rfresponse = DoubleOpponent(ab, ba, k)

if nargin < 3
  k = 0.5;
end

MidaMin = 4;
nplans = floor(log(max(size(ab) - 1) / MidaMin) / log(2)) + 1;
[wab, cab] = DWT(ab, nplans);
[wba, cba] = DWT(ba, nplans);

wp = cell(nplans, 1);
wc = cell(nplans, 1);
for s = 1:nplans
  % for horizontal, vertical and diagonal orientations:
  for orientation = 1:3
    wsab = wab{s, 1}(:, :, orientation);
    wsba = wba{s, 1}(:, :, orientation);
    wp{s, 1}(:, :, orientation) = wsab + k * wsba;
  end
  csab = cab{s, 1};
  csba = cba{s, 1};
  wc{s, 1} = csab + k * csba;
end

[rows, cols] = size(ab);
rfresponse = IDWT(wp, wc, cols, rows);

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
