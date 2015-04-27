function ColourConstantImage = ColourConstancyOpponency(InputImage, plotme)
%ColourConstancyOpponency Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
  plotme = 0;
end

[rows, cols, chns] = size(InputImage);
InputImage = im2double(InputImage);

rch = InputImage(:, :, 1);
gch = InputImage(:, :, 2);
bch = InputImage(:, :, 3);
ych = (rch + gch) ./ 2;
lch = rch + gch + bch;

if plotme
  figure;
  FigRow = 3;
  FigCol = 2;
  subplot(FigRow, FigCol, 1); imshow(rch, [0, 1]); title('Red');
  subplot(FigRow, FigCol, 2); imshow(gch, [0, 1]); title('Green');
  subplot(FigRow, FigCol, 3); imshow(bch, [0, 1]); title('Blue');
  subplot(FigRow, FigCol, 4); imshow(ych, [0, 1]); title('Yellow');
  subplot(FigRow, FigCol, 5:6); imshow(lch / 3, [0, 1]); title('Luminance');
end

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
  figure;
  FigRow = 3;
  FigCol = 2;
  subplot(FigRow, FigCol, 1); imshow(rg, []); title('R-G');
  subplot(FigRow, FigCol, 2); imshow(-rg, []); title('G-R');
  subplot(FigRow, FigCol, 3); imshow(yb, []); title('Y-B');
  subplot(FigRow, FigCol, 4); imshow(-yb, []); title('B-Y');
  subplot(FigRow, FigCol, 5:6); imshow(wb, []); title('Luminance');
end

sorg = SingleOpponent(rg, 1);
soyb = SingleOpponent(yb, 1);
sowb = SingleOpponent(wb, 1);

lambda = 3;
sogr = SingleOpponent(-rg, lambda);
soby = SingleOpponent(-yb, lambda);
sobw = SingleOpponent(-wb, lambda);

k = 0.5;
dorg = sorg + k * sogr;
doyb = soyb + k * soby;
dowb = sowb + k * sobw;

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
ColourConstantImage = MatChansMulK(InputImage, k);

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
  lambda = 1;
end

rf = fspecial('gaussian', [3, 3], 0.5 * lambda);

rfresponse = imfilter(isignal, rf);

end
