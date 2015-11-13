function EdgeImageResponse = SurroundModulationEdgeDetector(InputImage)

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
params(1, :) = [wbSigma];
params(2, :) = [rgSigma];
params(3, :) = [ybSigma];
for i = 4:chns
  params(i, :) = params(3, :);
end

LevelEdge = ones(rows, cols, chns, nangles);
for i = 1:nlevels
  iimage = imresize(OpponentChannels, 1 / (1.6 ^ (i - 1)), 'bicubic');
  iiedge = GaussianGradientEdges(iimage, params, LevelEdge);
  EdgeImageResponse(:, :, :, i, :) = abs(iiedge);
end

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
    end
    
    [EdgeImageResponse, MaxInds] = max(EdgeImageResponse, [], CurrentDimension);
    
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

UseSparsity = false;
UseNonMax = true;

% EdgeImageResponse = log2(EdgeImageResponse);
% EdgeImageResponse = sqrt(EdgeImageResponse);
EdgeImageResponse = EdgeImageResponse ./ max(EdgeImageResponse(:));

if UseSparsity
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

function OutEdges = GaussianGradientEdges(InputImage, params, LevelEdge)

[w, h, d, nangles] = size(LevelEdge);

OutEdges = zeros(w, h, d, nangles);
for i = 1:d
  OutEdges(:, :, i, :) = GaussianGradientChannel(InputImage(:, :, i), params(i, :), LevelEdge(:, :, i, :), i);
end

end

function OutEdges = GaussianGradientChannel(isignal, params, LevelEdge, colch)

[rows, cols, ~, nangles] = size(LevelEdge);
thetas = zeros(1, nangles);
for i = 1:nangles
  thetas(i) = (i - 1) * pi / nangles;
end

LevelEdge = reshape(LevelEdge, rows, cols, nangles);
OutEdges = abs(gedges(isignal, params(1), thetas, LevelEdge, colch));

end

function rfresponse = gedges(InputImage, StartingSigma, thetas, LevelEdge, colch)

[rows1, cols1, ~] = size(InputImage);
[rows2, cols2, ~] = size(LevelEdge);

sigmas = StartingSigma;

nThetas = length(thetas);
rfresponse = zeros(rows1, cols1, nThetas);
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

rfresponse = abs(imresize(rfresponse, [rows2, cols2]));

rfresponse = rfresponse ./ max(rfresponse(:));

end
