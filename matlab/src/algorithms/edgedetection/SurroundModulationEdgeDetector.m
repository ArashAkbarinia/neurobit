function EdgeImageResponse = SurroundModulationEdgeDetector(InputImage)

[rows, cols, chns] = size(InputImage);

% convert to opponent image
if chns == 3
  OpponentImage = double(applycform(uint8(InputImage .* 255), makecform('srgb2lab'))) ./ 255;
else
  OpponentImage = InputImage;
end

nlevels = 1;
nangles = 8;
EdgeImageResponse = zeros(rows, cols, chns, nlevels, nangles);

ContrastEnlarge = 1;
ContrastLevels = 1;
wbsigma = 1.1;
rgsigma = 1.1;
ybsigma = 1.1;
params(1, :) = [wbsigma, ContrastEnlarge, ContrastLevels];
params(2, :) = [rgsigma, ContrastEnlarge, ContrastLevels];
params(3, :) = [ybsigma, ContrastEnlarge, ContrastLevels];

LevelEdge = ones(rows, cols, chns, nangles);
for i = nlevels:-1:1
  iimage = imresize(OpponentImage, 1 / (1.6 ^ i), 'bicubic');
  iiedge = GaussianGradientEdges(iimage, params, LevelEdge);
  LevelEdge = abs(iiedge);
  EdgeImageResponse(:, :, :, i, :) = LevelEdge;
end

lsnr = LocalSnr(OpponentImage(:, :, 1));

DimOri = {3, 'max'};
DimLev = {4, 'max'};
DimAng = {5, 'max'};
ExtraDimensions = {DimOri, DimLev, DimAng};
for i = 1:numel(ExtraDimensions)
  CurrentDimension = ExtraDimensions{i}{1};
  if strcmpi(ExtraDimensions{i}{2}, 'sum')
    EdgeImageResponse = sum(EdgeImageResponse, CurrentDimension);
  elseif strcmpi(ExtraDimensions{i}{2}, 'max')
    EdgeImageResponse = max(EdgeImageResponse, [], CurrentDimension);
  elseif strcmpi(ExtraDimensions{i}{2}, 'both')
    EdgeImageResponseSum = sum(EdgeImageResponse, CurrentDimension);
    EdgeImageResponseMax = max(EdgeImageResponse, [], CurrentDimension);
    EdgeImageResponse = EdgeImageResponseSum;
    UseMaxPixels = true(size(EdgeImageResponse));
    for c = 1:size(EdgeImageResponse, 3)
      for l = 1:size(EdgeImageResponse, 4)
        for a = 1:size(EdgeImageResponse, 5)
          UseMaxPixels(:, :, c, l, a) = reshape(lsnr < 1.0, rows, cols, 1, 1, 1);
        end
      end
    end
    EdgeImageResponse(UseMaxPixels) = EdgeImageResponseMax(UseMaxPixels);
  end
end

EdgeImageResponse = EdgeImageResponse ./ max(EdgeImageResponse(:));

% [~, orientation] = imgradient(EdgeImageResponse);
% orientation = deg2rad(orientation);
% orientation(orientation < 0) = orientation(orientation < 0) + pi;
% EdgeImageResponse = NonMaxChannel(EdgeImageResponse, orientation);

% EdgeImageResponse([1, end], :) = 0;
% EdgeImageResponse(:, [1, end]) = 0;

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
  OutEdges(:, :, i, :) = GaussianGradientChannel(InputImage(:, :, i), params(i, :), LevelEdge(:, :, i, :));
end

end

function OutEdges = GaussianGradientChannel(isignal, params, LevelEdge)

[rows, cols, ~, nangles] = size(LevelEdge);
thetas = zeros(1, nangles);
for i = 1:nangles
  thetas(i) = (i - 1) * pi / nangles;
end

LevelEdge = reshape(LevelEdge, rows, cols, nangles);
OutEdges = abs(ContrastDependantGaussianGradient(isignal, params(1), params(2), params(3), thetas, LevelEdge));

end
