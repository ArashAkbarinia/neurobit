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

% EdgeImageResponse = log2(EdgeImageResponse);
% EdgeImageResponse = sqrt(EdgeImageResponse);
% EdgeImageResponse = imfilter(EdgeImageResponse, GaussianFilter2(3.0), 'replicate');
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

[rows, cols, ~] = size(EdgeImageResponse);

DimChn = {3, 'max'};
DimLev = {4, 'sum'};
DimAng = {5, 'max'};
ExtraDimensions = {DimLev, DimAng, DimChn};
SelectedOrientations = [];
FinalOrientations = zeros(rows, cols);
for i = 1:numel(ExtraDimensions)
  CurrentDimension = ExtraDimensions{i}{1};
  
  if strcmpi(ExtraDimensions{i}{2}, 'sum')
    EdgeImageResponse = sum(EdgeImageResponse, CurrentDimension);
    
  elseif strcmpi(ExtraDimensions{i}{2}, 'max')
    StdImg = std(EdgeImageResponse, [], CurrentDimension);
    
    if CurrentDimension == 3
      %       EdgeImageResponse = SparsityChannel(EdgeImageResponse, 5);
      %       SumAllChennels = sum(EdgeImageResponse, CurrentDimension);
    end
    
    [EdgeImageResponse, MaxInds] = max(EdgeImageResponse, [], CurrentDimension);
    
    if CurrentDimension == 3
      %       EdgeImageResponse = EdgeImageResponse + SumAllChennels;
    end
    
    if CurrentDimension == 5
      EdgeImageResponse = EdgeImageResponse .* StdImg;
      SelectedOrientations = MaxInds;
    elseif ~isempty(SelectedOrientations)
      for c = 1:max(MaxInds(:))
        corien = SelectedOrientations(:, :, c);
        FinalOrientations(MaxInds == c) = corien(MaxInds == c);
      end
    end
  end
end

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

function rfresponse = gedges(InputImage, StartingSigma, thetas, colch, clevel)

[rows1, cols1, ~] = size(InputImage);

% consider two points here
% 1. the Gaussian should happen before or after the resizing?
% 2. should we apply the contrast dependant smoothing?
InputImage = imfilter(InputImage, GaussianFilter2(0.5 * clevel), 'replicate');
InputImage = imresize(InputImage, 1 / (2.0 ^ (clevel - 1)));

[rows2, cols2, ~] = size(InputImage);

sigmas = StartingSigma;

nThetas = length(thetas);
rfresponse = zeros(rows2, cols2, nThetas);
lambdaxi = sigmas;
lambdayi = sigmas;
for t = 1:nThetas
  theta = thetas(t);
  
  if colch ~= 1
    sorf = GaussianFilter2(lambdaxi, lambdayi, 0, 0, theta);
    soresponse = imfilter(InputImage, sorf, 'replicate');
    dorf = Gaussian2Gradient1(sorf, theta);
  else
    sorf = GaussianFilter2(lambdaxi, lambdayi, 0, 0, theta);
    soresponse = imfilter(InputImage, sorf, 'replicate');
    dorf = Gaussian2Gradient1(sorf, theta);
  end
  
  doresponse = imfilter(soresponse, dorf, 'symmetric');
  rfresponse(:, :, t) = doresponse;
end

% consider two points here
% 1. the Gaussian should happen before or after the resizing?
% 2. should we apply the contrast dependant smoothing?
rfresponse = abs(imresize(rfresponse, [rows1, cols1]));
rfresponse = imfilter(rfresponse, GaussianFilter2(0.5 * clevel), 'replicate');

rfresponse = rfresponse ./ max(rfresponse(:));

end
