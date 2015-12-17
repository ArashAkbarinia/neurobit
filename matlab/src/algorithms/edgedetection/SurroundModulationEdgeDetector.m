function EdgeImageResponse = SurroundModulationEdgeDetector(InputImage, ImagePath)

if nargin < 2
  ImagePath = false;
end
if ImagePath
  DebugPath = ImagePath(1:end - 4);
end

% input image is from retina

% size of RF in LGN
LgnSigma = 0.5;
InputImage = imfilter(InputImage, GaussianFilter2(LgnSigma), 'replicate');

% convert to opponent image this happens in LGN
if size(InputImage, 3) == 3
  OpponentImage = double(applycform(uint8(InputImage .* 255), makecform('srgb2lab'))) ./ 255;
  OpponentImage(:, :, 4) = LocalStdContrast(rgb2gray(InputImage));
  OpponentImage(:, :, 5) = InputImage(:, :, 1) - 0.7 .* InputImage(:, :, 2);
  OpponentImage(:, :, 6) = InputImage(:, :, 3) - 0.7 .* mean(InputImage(:, :, 2:3), 3);
else
  OpponentImage = InputImage;
end

nlevels = 4;
nangles = 6;

% calculate the Gaussian gradients
if ImagePath
  if exist([DebugPath, '-v1.mat'], 'file')
    v1mat = load([DebugPath, '-v1.mat']);
    EdgeImageResponse = v1mat.EdgeImageResponse;
  else
    EdgeImageResponse = DoV1(OpponentImage, nangles, nlevels, LgnSigma);
    save([DebugPath, '-v1.mat'], 'EdgeImageResponse');
  end
else
  EdgeImageResponse = DoV1(OpponentImage, nangles, nlevels, LgnSigma);
end

ExtraDimensions = [4, 5, 3];
FinalOrientations = [];

for i = 1:numel(ExtraDimensions)
  CurrentDimension = ExtraDimensions(i);
  
  switch CurrentDimension
    case 3
      [EdgeImageResponse, FinalOrientations] = CollapseChannels(EdgeImageResponse, FinalOrientations);
    case 4
      [EdgeImageResponse, FinalOrientations] = CollapsePlanes(EdgeImageResponse, FinalOrientations);
    case 5
      if ImagePath
        if exist([DebugPath, '-v2.mat'], 'file')
          v2mat = load([DebugPath, '-v2.mat']);
          EdgeImageResponse = v2mat.EdgeImageResponse;
          FinalOrientations = v2mat.FinalOrientations;
        else
          [EdgeImageResponse, FinalOrientations] = CollapseOrientations(EdgeImageResponse, FinalOrientations);
          save([DebugPath, '-v2.mat'], 'EdgeImageResponse', 'FinalOrientations');
        end
      else
        [EdgeImageResponse, FinalOrientations] = CollapseOrientations(EdgeImageResponse, FinalOrientations);
      end
  end
  
end

UseSparity = false;
UseNonMax = true;

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

function EdgeImageResponse = DoV1(OpponentImage, nangles, nlevels, LgnSigma)

[rows, cols, chns] = size(OpponentImage);
EdgeImageResponse = zeros(rows, cols, chns, nlevels, nangles);

% how many times the neurons in V1 are larger than LGN?
lgn2v1 = 2.7;
wbSigma = LgnSigma * lgn2v1;
rgSigma = LgnSigma * lgn2v1;
ybSigma = LgnSigma * lgn2v1;
params(1, :) = wbSigma;
params(2, :) = rgSigma;
params(3, :) = ybSigma;
params(4, :) = LgnSigma * lgn2v1;
params(5, :) = LgnSigma * lgn2v1;
for i = 6:chns
  params(i, :) = params(3, :);
end

for i = 1:nlevels
  iiedge = GaussianGradientEdges(OpponentImage, params, nangles, i);
  EdgeImageResponse(:, :, :, i, :) = iiedge;
end

end

function [EdgeImageResponse, FinalOrientations] = CollapseChannels(EdgeImageResponse, SelectedOrientations)

CurrentDimension = 3;

[rows, cols, ~] = size(EdgeImageResponse);
FinalOrientations = zeros(rows, cols);

% V4 area sum of 4 pie-wedge shape
% nThetas = 2;
% for c = 1:size(EdgeImageResponse, CurrentDimension)
%   CurrentChannel = EdgeImageResponse(:, :, c);
%   for t = 1:nThetas
%     theta = (t - 1) * pi / nThetas;
%     xsigma = 0.5 * 2.7 * 2.7 * 2.7;
%     ysigma = xsigma / 3;
%
%     v2responsec = imfilter(EdgeImageResponse(:, :, c), GaussianFilter2(xsigma, ysigma, 0, 0, theta), 'symmetric');
%     v2responses = imfilter(EdgeImageResponse(:, :, c), GaussianFilter2(xsigma * 3, ysigma * 3, 0, 0, theta), 'symmetric');
%     v2response = abs(v2responsec - v2responses);
%     CurrentChannel = CurrentChannel + v2response;
%   end
%   EdgeImageResponse(:, :, c) = CurrentChannel;
% end

% lsnr = ExtraDimensionsSnr(EdgeImageResponse, CurrentDimension);
SumEdgeResponse = sum(EdgeImageResponse, CurrentDimension);

[~, MaxInds] = max(EdgeImageResponse, [], CurrentDimension);

% EdgeImageResponse = SelectMaxOrSum(EdgeImageResponse, SumEdgeResponse, lsnr);
EdgeImageResponse = SumEdgeResponse;

if ~isempty(SelectedOrientations)
  for c = 1:max(MaxInds(:))
    corien = SelectedOrientations(:, :, c);
    FinalOrientations(MaxInds == c) = corien(MaxInds == c);
  end
end

end

function [EdgeImageResponse, FinalOrientations] = CollapsePlanes(EdgeImageResponse, SelectedOrientations)

CurrentDimension = 4;

EdgeImageResponse = sum(EdgeImageResponse, CurrentDimension);
FinalOrientations = [];

end

function [EdgeImageResponse, FinalOrientations] = CollapseOrientations(EdgeImageResponse, SelectedOrientations)

CurrentDimension = 5;
nThetas = size(EdgeImageResponse, CurrentDimension);

StdImg = std(EdgeImageResponse, [], CurrentDimension);

[EdgeImageResponse, FinalOrientations] = max(EdgeImageResponse, [], CurrentDimension);

v1sigma = 0.5 * 2.7;
v1v2 = 2.7;

% V2 area pie-wedge shape
for c = 1:size(EdgeImageResponse, 3)
  CurrentChannel = EdgeImageResponse(:, :, c);
  CurrentOrientation = FinalOrientations(:, :, c);
  
  % consider calculating the contrast with a larger window size
  % approperiate for V2.
  si = LocalStdContrast(CurrentChannel);
  si = si ./ max(si(:));
  si = max(si(:)) - si;
  si = NormaliseChannel(si, 0.7, 1.0, [], []);
  
  for t = 1:nThetas
    theta = (t - 1) * pi / nThetas;
    theta = theta + (pi / 2);
    
    xsigma = v1sigma * v1v2;
    % consider make this a parameter based on number of thetas
    ysigma = xsigma / 8;
    
    v2responsec = imfilter(EdgeImageResponse(:, :, c), GaussianFilter2(xsigma, ysigma, 0, 0, theta), 'symmetric');
    v2responses = imfilter(EdgeImageResponse(:, :, c), GaussianFilter2(xsigma * 5, ysigma * 5, 0, 0, theta), 'symmetric');
    
    v2response = max(v2responsec - si .* v2responses, 0);
    CurrentChannel(CurrentOrientation == t) = v2response(CurrentOrientation == t);
  end
  EdgeImageResponse(:, :, c) = CurrentChannel;
end

% STD before V2 is not good
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
      CurrentChannel(isinf(CurrentChannel)) = max(CurrentChannel(~isinf(CurrentChannel)));
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

OutEdges = gedges(isignal, params(1), thetas, colch, clevel);

end

function rfresponse = gedges(InputImage, sigma, thetas, colch, clevel)

[rows1, cols1, ~] = size(InputImage);

gresize = GaussianFilter2(0.3 * (clevel - 1));

% consider two points here
% 1. the Gaussian should happen before or after the resizing?
% 2. should we apply the contrast dependant smoothing?
InputImage = imfilter(InputImage, gresize, 'replicate');
InputImage = imresize(InputImage, 1 / (2.0 ^ (clevel - 1)));

% consider to calculate the local SNR here according to Zhaoping
% lsnr = LocalSnr(InputImage);
if colch ~= 1
  lsnr = 1;
else
  lsnr = 1;
end

ElongatedFactor = 0.5;

[rows2, cols2, ~] = size(InputImage);

nThetas = length(thetas);
rfresponse = zeros(rows2, cols2, nThetas);

% in the same orientation, orthogonality suppresses and parallelism
% facilitates.
for t = 1:nThetas
  theta1 = thetas(t);
  
  dorf = DivGauss2D(sigma, theta1, ElongatedFactor);
  doresponse = abs(imfilter(InputImage, dorf, 'symmetric') .* lsnr);
  
  rfresponse(:, :, t) = doresponse;
end

CentreSize = size(dorf, 1);
rfresponse = SurroundOrientation(InputImage, CentreSize, rfresponse, sigma);

% consider two points here
% 1. the Gaussian should happen before or after the resizing?
% 2. should we apply the contrast dependant smoothing?
rfresponse = imresize(rfresponse, [rows1, cols1]);
rfresponse = imfilter(rfresponse, gresize, 'replicate');

% consider two different options:
% normalise based on all orientations
rfresponse = rfresponse ./ max(rfresponse(:));
% normalise each orientation separately
% rfresponse = MatChansMulK(rfresponse, 1 ./ max(max(rfresponse)));

end

function rfresponse = SurroundOrientation(InputImage, CentreSize, rfresponse, sigma)

rfresponse = rfresponse ./ max(rfresponse(:));

if ~isempty(InputImage)
  CentreContrast = LocalStdContrast(InputImage, CentreSize);
  CentreContrast = CentreContrast ./ max(CentreContrast(:));
  
  sps = max(CentreContrast(:)) - CentreContrast;
  sps = sps .* 0.66;
  sns = CentreContrast;
  sns = sns .* 0.66;
  
  ops = max(CentreContrast(:)) - CentreContrast;
  ops = ops .* 0.5;
  ons = CentreContrast;
  ons = ons .* 0.5;
else
  sps = CentreSize;
  sns = CentreSize;
  
  ops = CentreSize;
  ons = CentreSize;
end

ysigma = 0.1;

% in the oppositie orientation, orthogonality facilitates and parallelism
% suppresses.
nThetas = size(rfresponse, 3);
for t = 1:nThetas
  theta1 = (t - 1) * pi / nThetas;
  theta2 = theta1 + (pi / 2);
  
  o = t + (nThetas / 2);
  if o > nThetas
    o = t - (nThetas / 2);
  end
  
  xsigma = 3 * sigma;
  if t == 1 || t == ((nThetas / 2) + 1)
    xsigma = xsigma * 2;
  end
  
  oppresponse = rfresponse(:, :, o);
  doresponse = rfresponse(:, :, t);
  
  PositiveSameOrientationGaussian = CentreZero(GaussianFilter2(xsigma, ysigma, 0, 0, theta1), [1, 1]);
  PositiveSameOrientation = imfilter(doresponse, PositiveSameOrientationGaussian, 'symmetric');
  NegativeOrthogonalOrientationGaussian = CentreZero(GaussianFilter2(xsigma / 4, ysigma, 0, 0, theta2), [1, 1]);
  NegativeOrthogonalOrientation = imfilter(doresponse, NegativeOrthogonalOrientationGaussian, 'symmetric');
  
  NegativeSameOrientationGaussian = CentreZero(GaussianFilter2(xsigma, ysigma, 0, 0, theta1), [1, 1]);
  NegativeSameOrientation = imfilter(oppresponse, NegativeSameOrientationGaussian, 'symmetric');
  PositiveOrthogonalOrientationGaussian = CentreZero(GaussianFilter2(xsigma / 4, ysigma, 0, 0, theta2), [1, 1]);
  PositiveOrthogonalOrientation = imfilter(oppresponse, PositiveOrthogonalOrientationGaussian, 'symmetric');
  
  doresponse = doresponse + sps .* PositiveSameOrientation - sns .* NegativeOrthogonalOrientation;
  doresponse = doresponse - ons .* NegativeSameOrientation + ops .* PositiveOrthogonalOrientation;
  rfresponse(:, :, t) = doresponse;
end

% consider max or abs
rfresponse = abs(rfresponse);

rfresponse = rfresponse ./ max(rfresponse(:));

end
