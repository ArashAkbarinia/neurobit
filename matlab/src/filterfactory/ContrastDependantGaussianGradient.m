function rfresponse = ContrastDependantGaussianGradient(InputImage, StartingSigma, ContrastEnlarge, nContrastLevels, order, thetas, map)
%ContrastDependantGaussian Summary of this function goes here
%   Detailed explanation goes here

rfresponse = xytogether(InputImage, StartingSigma, ContrastEnlarge, nContrastLevels, order, thetas, map);
% rfresponse = xyseparately(InputImage, StartingSigma, ContrastEnlarge, nContrastLevels, order, thetas, map);

end

function rfresponse = xytogether(InputImage, StartingSigma, ContrastEnlarge, nContrastLevels, order, thetas, map)

[rows, cols, ~] = size(InputImage);

if nargin < 3
  ContrastEnlarge = 2;
end
if nargin < 4
  nContrastLevels = 4;
end
if nargin < 5
  order = 0;
end
if nargin < 6
  thetas = [0, pi / 2, pi, 3 * pi / 2];
end

cs = 5;
CentreSize = [cs, cs];
ContrastImage = GetContrastImage(InputImage, 5 .* CentreSize, CentreSize);

FinishingSigma = StartingSigma * ContrastEnlarge;
sigmas = linspace(StartingSigma, FinishingSigma, nContrastLevels);

ContrastLevelsAll = GetContrastLevels(ContrastImage, nContrastLevels);

nContrastLevelsAll = unique(ContrastLevelsAll(:));
nContrastLevelsAll = nContrastLevelsAll';

nThetas = length(thetas);
rfresponse = zeros(rows, cols, nThetas);
for i = nContrastLevelsAll
  lambdaxi = sigmas(i);
  lambdayi = lambdaxi;
  rfi = GaussianFilter2(lambdaxi, lambdayi, 0, 0);
  for t = 1:nThetas
    theta = thetas(t);
    rfresponset = rfresponse(:, :, t);
    if order == 1
      rft = GaussianGradient1(rfi, theta);
    elseif order == 2
      rft = GaussianGradient2(rfi, theta);
    end
    rfresponsei = imfilter(InputImage, rft, 'symmetric');
    rfresponset(ContrastLevelsAll == i) = rfresponsei(ContrastLevelsAll == i);
    rfresponse(:, :, t) = rfresponset;
  end
end

end

function rfresponse = xyseparately(InputImage, StartingSigma, ContrastEnlarge, nContrastLevels, order, thetas, map)

[rows, cols, ~] = size(InputImage);

if nargin < 3
  ContrastEnlarge = 2;
end
if nargin < 4
  nContrastLevels = 4;
end
if nargin < 5
  order = 0;
end
if nargin < 6
  thetas = [0, pi / 2, pi, 3 * pi / 2];
end

ContrastImx = GetContrastImage(InputImage, [17, 1]);
ContrastImy = GetContrastImage(InputImage, [1, 17]);

FinishingSigma = StartingSigma * ContrastEnlarge;
sigmas = linspace(StartingSigma, FinishingSigma, nContrastLevels);

ContrastLevelsX = GetContrastLevels(ContrastImx, nContrastLevels);
ContrastLevelsY = GetContrastLevels(ContrastImy, nContrastLevels);

nContrastLevelsX = unique(ContrastLevelsX(:));
nContrastLevelsX = nContrastLevelsX';

nContrastLevelsY = unique(ContrastLevelsY(:));
nContrastLevelsY = nContrastLevelsY';

nThetas = length(thetas);
rfresponse = zeros(rows, cols, nThetas);
for i = nContrastLevelsX
  lambdaxi = sigmas(i);
  for j = nContrastLevelsY
    lambdayi = sigmas(j);
    rfi = GaussianFilter2(lambdaxi, lambdayi, 0, 0);
    for t = 1:nThetas
      theta = thetas(t);
      rfresponset = rfresponse(:, :, t);
      if order == 1
        rft = GaussianGradient1(rfi, theta);
      elseif order == 2
        rft = GaussianGradient2(rfi, theta);
      end
      rfresponsei = imfilter(InputImage, rft, 'symmetric');
      rfresponset(ContrastLevelsX == i & ContrastLevelsY == j) = rfresponsei(ContrastLevelsX == i & ContrastLevelsY == j);
      rfresponse(:, :, t) = rfresponset;
    end
  end
end

end

function ContrastImage = GetContrastImage(isignal, SurroundSize, CentreSize)

if nargin < 2
  SurroundSize = [3, 3];
end
if nargin < 3
  CentreSize = [0, 0];
end
contraststd = LocalStdContrast(isignal, SurroundSize, CentreSize);

ContrastImage = 1 - contraststd;

end

function ContrastLevels = GetContrastLevels(ContrastIm, nContrastLevels)

MinPix = min(ContrastIm(:));
MaxPix = max(ContrastIm(:));
step = ((MaxPix - MinPix) / nContrastLevels);
levels = MinPix:step:MaxPix;
levels = levels(2:end-1);
ContrastLevels = imquantize(ContrastIm, levels);

end
