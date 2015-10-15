function rfresponse = ContrastDependantGaussianGradient(InputImage, StartingSigma, ContrastEnlarge, nContrastLevels, order, thetas)
%ContrastDependantGaussian Summary of this function goes here
%   Detailed explanation goes here

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

function ContrastImage = GetContrastImage(isignal, SurroundSize)

if nargin < 2
  SurroundSize = [3, 3];
end
contraststd = LocalStdContrast(isignal, SurroundSize);

% contraststd = stdfilt(isignal);
% rf = dog2(GaussianFilter2(0.5), GaussianFilter2(2.5));
% rf = GaussianGradient2(GaussianFilter2(2.5));
% contraststd = imfilter(isignal, rf, 'replicate');
% contraststd = contraststd + abs(min(contraststd(:)));
% contraststd = contraststd ./ max(contraststd(:));

% [rgc, rgs] = RelativePixelContrast(isignal, 3);
% contraststd = rgc ./ rgs;
% contraststd(isnan(contraststd)) = 0;
% contraststd(isinf(contraststd)) = 1;
% contraststd(contraststd > 1) = 1;

% contraststd = WeberContrast(isignal);
% contraststd = contraststd ./ max(contraststd(:));

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
