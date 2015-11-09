function EdgeImageResponse = SurroundModulationEdgeDetector(InputImage)

[rows, cols, chns] = size(InputImage);

% convert to opponent image
if chns == 3
  rgb2do = ...
    [
    0.2990,  0.5870,  0.1140;
    0.5000,  0.5000, -1.0000;
    0.8660, -0.8660,  0.0000;
    ];
  OpponentImage = rgb2do * reshape(InputImage, rows * cols, chns)';
  OpponentImage = reshape(OpponentImage', rows, cols, chns);
else
  OpponentImage = InputImage;
end

nlevels = 4;
nangles = 8;
EdgeImageResponse = zeros(rows, cols, chns, nlevels, nangles);

LevelEdge = ones(rows, cols, chns, nangles);
for i = nlevels:-1:1
  iimage = imresize(OpponentImage, 1 / i, 'bicubic');
  iiedge = GaussianGradientEdges(iimage, 1.1, LevelEdge);
  LevelEdge = abs(iiedge);
  EdgeImageResponse(:, :, :, i, :) = LevelEdge;
end

ExtraDimensions = [3, 4, 5];
ExtraPoolings = {'max', 'max', 'max'};
for i = 1:length(ExtraDimensions)
  CurrentDimension = ExtraDimensions(i);
  if strcmpi(ExtraPoolings{i}, 'sum')
    EdgeImageResponse = sum(EdgeImageResponse, CurrentDimension);
  elseif strcmpi(ExtraPoolings{i}, 'max')
    EdgeImageResponse = max(EdgeImageResponse, [], CurrentDimension);
  end
end

EdgeImageResponse = EdgeImageResponse ./ max(EdgeImageResponse(:));

% [~, orientation] = imgradient(EdgeImageResponse);
% orientation = deg2rad(orientation);
% orientation(orientation < 0) = orientation(orientation < 0) + pi;
% EdgeImageResponse = NonMaxChannel(EdgeImageResponse, orientation);

% mask out 1-pixel border where nonmax suppression fails
EdgeImageResponse([1, end], :) = 0;
EdgeImageResponse(:, [1, end]) = 0;

end

function d = NonMaxChannel(d, t)

for i = 1:size(d, 3)
  d(:, :, i) = d(:, :, i) ./ max(max(d(:, :, i)));
  d(:, :, i) = nonmax(d(:, :, i), t);
  d(:, :, i) = max(0, min(1, d(:, :, i)));
end

end

function OutEdges = GaussianGradientEdges(InputImage, CentreSigma, LevelEdge)

[w, h, d, nangles] = size(LevelEdge);

OutEdges = zeros(w, h, d, nangles);
for i = 1:d
  OutEdges(:, :, i, :) = GaussianGradientChannel(InputImage(:, :, i), CentreSigma, LevelEdge(:, :, i, :));
end

end

function OutEdges = GaussianGradientChannel(isignal, CentreSigma, LevelEdge)

[rows, cols, ~, nangles] = size(LevelEdge);
thetas = zeros(1, nangles);
for i = 1:nangles
  thetas(i) = (i - 1) * pi / nangles;
end

LevelEdge = reshape(LevelEdge, rows, cols, nangles);
OutEdges = abs(ContrastDependantGaussianGradient(isignal, CentreSigma, 2, 4, thetas, LevelEdge));

end
