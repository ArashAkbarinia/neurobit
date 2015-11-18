function EdgeImageResponse = SurroundModulationEdgeDetector(InputImage, UseSparity, UseNonMax)

% convert to opponent image
if size(InputImage, 3) == 3
  OpponentImage = double(applycform(uint8(InputImage .* 255), makecform('srgb2lab'))) ./ 255;
  
  %   OpponentImage(:, :, 1) = rgb2gray(InputImage);
  %   OpponentImage(:, :, 1) = +1.0 .* InputImage(:, :, 1) - 0.7 .* InputImage(:, :, 2);
  %   OpponentImage(:, :, 2) = -0.7 .* InputImage(:, :, 1) + 1.0 .* InputImage(:, :, 2);
  %   OpponentImage(:, :, 3) = +1.0 .* InputImage(:, :, 3) - 0.7 .* mean(InputImage(:, :, 1:2), 3);
  %   OpponentImage(:, :, 4) = -0.7 .* InputImage(:, :, 3) + 1.0 .* mean(InputImage(:, :, 1:2), 3);
  
  %   OpponentImage(:, :, 1) = sum(InputImage, 3);
  %   OpponentImage(:, :, 2:4) = InputImage;
  %   OpponentImage(:, :, 5) = +1.0 .* InputImage(:, :, 1) - 1.0 .* InputImage(:, :, 2);
  %   OpponentImage(:, :, 6) = +1.0 .* InputImage(:, :, 1) - 0.7 .* InputImage(:, :, 2);
  %   OpponentImage(:, :, 7) = +1.0 .* InputImage(:, :, 3) - 1.0 .* mean(InputImage(:, :, 1:2), 3);
  %   OpponentImage(:, :, 8) = +1.0 .* InputImage(:, :, 3) - 0.7 .* mean(InputImage(:, :, 1:2), 3);
  
  OpponentChannels = OpponentImage;
else
  OpponentChannels = InputImage;
end

[rows, cols, chns] = size(OpponentChannels);

nlevels = 4;
nangles = 8;
EdgeImageResponse = zeros(rows, cols, chns, nlevels, nangles);

wbSigma = 1.5;
rgSigma = 1.5;
ybSigma = 1.5;
params(1, :) = wbSigma;
params(2, :) = rgSigma;
params(3, :) = ybSigma;
for i = 4:chns
  params(i, :) = params(3, :);
end

for i = 1:nlevels
  iiedge = GaussianGradientEdges(OpponentImage, params, nangles, i);
  EdgeImageResponse(:, :, :, i, :) = abs(iiedge);
end

[EdgeImageResponse, FinalOrientations] = CombineAll(EdgeImageResponse);

if nargin < 2
  UseSparity = false;
end
if nargin < 3
  UseNonMax = true;
end

EdgeImageResponse = EdgeImageResponse ./ max(EdgeImageResponse(:));

if UseSparity
  EdgeImageResponse = SparsityChannel(EdgeImageResponse, 5);
end

if UseNonMax
  FinalOrientations = (FinalOrientations - 1) * pi / nangles;
  FinalOrientations = mod(FinalOrientations + pi / 2, pi);
  EdgeImageResponse = NonMaxChannel(EdgeImageResponse, FinalOrientations);
  EdgeImageResponse([1, end], :) = 0;
  EdgeImageResponse(:, [1, end]) = 0;
  EdgeImageResponse = EdgeImageResponse ./ max(EdgeImageResponse(:));
end

end

function [EdgeImageResponse, FinalOrientations] = CombineAll(EdgeImageResponse)

DimChn = {3, 'max'};
DimLev = {4, 'sum'};
DimAng = {5, 'max'};
ExtraDimensions = {DimLev, DimAng, DimChn};
FinalOrientations = [];

for i = 1:numel(ExtraDimensions)
  CurrentDimension = ExtraDimensions{i}{1};
  
  switch CurrentDimension
    case 3
      [EdgeImageResponse, FinalOrientations] = CollapseChannels(EdgeImageResponse, FinalOrientations);
    case 4
      [EdgeImageResponse, FinalOrientations] = CollapsePlanes(EdgeImageResponse, FinalOrientations);
    case 5
      [EdgeImageResponse, FinalOrientations] = CollapseOrientations(EdgeImageResponse, FinalOrientations);
  end
  
end

end

function [EdgeImageResponse, FinalOrientations] = CollapseChannels(EdgeImageResponse, SelectedOrientations)

CurrentDimension = 3;

[rows, cols, ~] = size(EdgeImageResponse);
FinalOrientations = zeros(rows, cols);

%       EdgeImageResponse = SparsityChannel(EdgeImageResponse, 5);
lsnr = ExtraDimensionsSnr(EdgeImageResponse, CurrentDimension);
SumEdgeResponse = sum(EdgeImageResponse, CurrentDimension);

[EdgeImageResponse, MaxInds] = max(EdgeImageResponse, [], CurrentDimension);

EdgeImageResponse = SelectMaxOrSum(EdgeImageResponse, SumEdgeResponse, lsnr);

for c = 1:max(MaxInds(:))
  corien = SelectedOrientations(:, :, c);
  FinalOrientations(MaxInds == c) = corien(MaxInds == c);
end

end

function [EdgeImageResponse, FinalOrientations] = CollapsePlanes(EdgeImageResponse, SelectedOrientations)

CurrentDimension = 4;

EdgeImageResponse = sum(EdgeImageResponse, CurrentDimension);
FinalOrientations = [];

end

function [EdgeImageResponse, FinalOrientations] = CollapseOrientations(EdgeImageResponse, SelectedOrientations)

CurrentDimension = 5;

StdImg = std(EdgeImageResponse, [], CurrentDimension);

[EdgeImageResponse, FinalOrientations] = max(EdgeImageResponse, [], CurrentDimension);

EdgeImageResponse = EdgeImageResponse .* StdImg;

end

function EdgeImageResponse = SelectMaxOrSum(MaxEdgeResponse, SumEdgeResponse, lsnr)

EdgeImageResponse = MaxEdgeResponse;
thr = mean(lsnr(:)) + -2 .* std(lsnr(:));

EdgeImageResponse(lsnr > thr) = SumEdgeResponse(lsnr > thr);

end

function lsnr = ExtraDimensionsSnr(EdgeImageResponse, CurrentDimension)

StdImg = std(EdgeImageResponse, [], CurrentDimension);
MeanImg = mean(EdgeImageResponse, CurrentDimension);
lsnr = 1 .* log10(MeanImg ./ StdImg);
for c = 1:size(lsnr, 3)
  for l = 1:size(lsnr, 4)
    for o = 1:size(lsnr, 5)
      CurrentChannel = lsnr(:, :, c, l, o);
      CurrentChannel(StdImg(:, :, c, l, o) < 1e-4) = max(~isinf(CurrentChannel(:)));
      lsnr(:, :, c, l, o) = CurrentChannel;
    end
  end
end
lsnr = max(lsnr, 0);

end

function d = SparsityChannel(d, t)

for i = 1:size(d, 3)
  SPrg = SparIndex(d(:, :, i), t);
  d(:, :, i) = d(:, :, i) .* SPrg;
  d(:, :, i) = d(:, :, i) ./ max(max(d(:, :, i)));
end

end

function d = NonMaxChannel(d, t)

for i = 1:size(d, 3)
  d(:, :, i) = d(:, :, i) ./ max(max(d(:, :, i)));
  d(:, :, i) = nonmax(d(:, :, i), t(:, :, i));
  d(:, :, i) = max(0, min(1, d(:, :, i)));
end

end

function OutEdges = GaussianGradientEdges(InputImage, params, nangles, clevel)

[w, h, d] = size(InputImage);

OutEdges = zeros(w, h, d, nangles);
for c = 1:d
  OutEdges(:, :, c, :) = GaussianGradientChannel(InputImage(:, :, c), params(c, :), nangles, c, clevel);
end

end

function OutEdges = GaussianGradientChannel(isignal, params, nangles, colch, clevel)

thetas = zeros(1, nangles);
for i = 1:nangles
  thetas(i) = (i - 1) * pi / nangles;
end

OutEdges = abs(gedges(isignal, params(1), thetas, colch, clevel));

end

function rfresponse = gedges(InputImage, sigma, thetas, colch, clevel)

[rows1, cols1, ~] = size(InputImage);

gresize = GaussianFilter2(0.3 * clevel);

% consider two points here
% 1. the Gaussian should happen before or after the resizing?
% 2. should we apply the contrast dependant smoothing?
InputImage = imfilter(InputImage, gresize, 'replicate');
InputImage = imresize(InputImage, 1 / (2.0 ^ (clevel - 1)));

if colch ~= 1
  lsnr = LocalSnr(InputImage);
else
  lsnr = 1;
end

[rows2, cols2, ~] = size(InputImage);

nThetas = length(thetas);
rfresponse = zeros(rows2, cols2, nThetas);
lambdaxi = sigma;
lambdayi = sigma;
for t = 1:nThetas
  theta = thetas(t);
  
  if colch ~= 1
    sorf = GaussianFilter2(lambdaxi, lambdayi, 0, 0, theta);
    soresponse = imfilter(InputImage, sorf, 'replicate');
    dorf = Gaussian2Gradient1(sorf, theta);
    doresponse = imfilter(soresponse, dorf, 'symmetric');
  else
    sorf = GaussianFilter2(lambdaxi, lambdayi, 0, 0, theta);
    soresponse = imfilter(InputImage, sorf, 'replicate');
    dorf = Gaussian2Gradient1(sorf, theta);
    doresponse = imfilter(soresponse, dorf, 'symmetric');
  end
  
  rfresponse(:, :, t) = doresponse .* lsnr;
end

% consider two points here
% 1. the Gaussian should happen before or after the resizing?
% 2. should we apply the contrast dependant smoothing?
rfresponse = abs(imresize(rfresponse, [rows1, cols1]));
rfresponse = imfilter(rfresponse, gresize, 'replicate');

rfresponse = rfresponse ./ max(rfresponse(:));

end
