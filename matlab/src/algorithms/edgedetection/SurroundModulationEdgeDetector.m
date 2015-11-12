function EdgeImageResponse = SurroundModulationEdgeDetector(InputImage)

[rows, cols, chns] = size(InputImage);

% convert to opponent image
if chns == 3
  OpponentImage = double(applycform(uint8(InputImage .* 255), makecform('srgb2lab'))) ./ 255;
else
  OpponentImage = InputImage;
end

nlevels = 3;
nangles = 8;
EdgeImageResponse = zeros(rows, cols, chns, nlevels, nangles);

wbContrastEnlarge = 1;
wbContrastLevels = 1;
ContrastEnlarge = 1;
ContrastLevels = 1;
wbSigma = 1.1;
rgSigma = 1.6;
ybSigma = 1.6;
params(1, :) = [wbSigma, wbContrastEnlarge, wbContrastLevels];
params(2, :) = [rgSigma, ContrastEnlarge, ContrastLevels];
params(3, :) = [ybSigma, ContrastEnlarge, ContrastLevels];

LevelEdge = ones(rows, cols, chns, nangles);
for i = nlevels:-1:1
  iimage = imresize(OpponentImage, 1 / (1.6 ^ i), 'bicubic');
  iiedge = GaussianGradientEdges(iimage, params, LevelEdge);
  LevelEdge = abs(iiedge);
  EdgeImageResponse(:, :, :, i, :) = LevelEdge;
end

lsnr = LocalSnr(InputImage);

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
    [EdgeImageResponse, MaxInds] = max(EdgeImageResponse, [], CurrentDimension);
    if CurrentDimension == 5
      SelectedOrientations = MaxInds;
    elseif ~isempty(SelectedOrientations)
      for c = 1:max(MaxInds(:))
        corien = SelectedOrientations(:, :, c);
        FinalOrientations(MaxInds == c) = corien(MaxInds == c);
      end
    end
  elseif strcmpi(ExtraDimensions{i}{2}, 'both')
    EdgeImageResponseSum = sum(EdgeImageResponse, CurrentDimension);
    EdgeImageResponseMax = max(EdgeImageResponse, [], CurrentDimension);
    EdgeImageResponse = EdgeImageResponseSum;
    UseMaxPixels = true(size(EdgeImageResponse));
    for c = 1:size(EdgeImageResponse, 3)
      for l = 1:size(EdgeImageResponse, 4)
        for a = 1:size(EdgeImageResponse, 5)
          UseMaxPixels(:, :, c, l, a) = reshape(lsnr(:, :, c) < mean2(lsnr(:, :, c)), rows, cols, 1, 1, 1);
        end
      end
    end
    EdgeImageResponse(UseMaxPixels) = EdgeImageResponseMax(UseMaxPixels);
  end
end

UseSparsity = false;
UseNonMax = true;

% EdgeImageResponse = log2(EdgeImageResponse);
EdgeImageResponse = EdgeImageResponse ./ max(EdgeImageResponse(:));

if UseSparsity
  SPrg = SparIndex(EdgeImageResponse, 5);
  EdgeImageResponse = EdgeImageResponse .* SPrg;
  EdgeImageResponse = EdgeImageResponse ./ max(EdgeImageResponse(:));
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

function d = NonMaxChannel(d, t)

for i = 1:size(d, 3)
  d(:, :, i) = d(:, :, i) ./ max(max(d(:, :, i)));
  d(:, :, i) = nonmax(d(:, :, i), t);
  d(:, :, i) = max(0, min(1, d(:, :, i)));
end

end

function OutEdges = GaussianGradientEdges(InputImage, params, LevelEdge)

[w, h, d, nangles] = size(LevelEdge);

OutEdges = zeros(w, h, d, nangles);
for i = 1:d
  OutEdges(:, :, i, :) = GaussianGradientChannel(InputImage(:, :, i), params(i, :), LevelEdge(:, :, i, :), i);
end

% arash = OutEdges(:, :, 1, :) - OutEdges(:, :, 2, :);
% for i = 2:3
%   OutEdges(:, :, i, :) = OutEdges(:, :, i, :) + OutEdges(:, :, 1, :);
% %   OutEdges(:, :, i, :) = OutEdges(:, :, i, :) ./ max(max(max(OutEdges(:, :, i, :))));
% end
% 
% OutEdges(:, :, 1, :) = max(arash, 0);

end

function OutEdges = GaussianGradientChannel(isignal, params, LevelEdge, colch)

[rows, cols, ~, nangles] = size(LevelEdge);
thetas = zeros(1, nangles);
for i = 1:nangles
  thetas(i) = (i - 1) * pi / nangles;
end

LevelEdge = reshape(LevelEdge, rows, cols, nangles);
OutEdges = abs(ContrastDependantGaussianGradient(isignal, params(1), params(2), params(3), thetas, LevelEdge, colch));

end
