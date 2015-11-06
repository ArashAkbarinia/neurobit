function rfresponse = ContrastDependantGaussianGradient(InputImage, StartingSigma, ContrastEnlarge, nContrastLevels, thetas)
%ContrastDependantGaussian Summary of this function goes here
%   Detailed explanation goes here

[rows, cols, ~] = size(InputImage);

if nargin < 3
  ContrastEnlarge = 2;
end
if nargin < 4
  nContrastLevels = 4;
end

if nContrastLevels > 1
  ContrastImx = GetContrastImage(InputImage, [1, 17]);
  ContrastImy = GetContrastImage(InputImage, [17, 1]);
  
  FinishingSigma = StartingSigma * ContrastEnlarge;
  sigmas = linspace(StartingSigma, FinishingSigma, nContrastLevels);
  
  ContrastLevelsX = GetContrastLevels(ContrastImx, nContrastLevels);
  ContrastLevelsY = GetContrastLevels(ContrastImy, nContrastLevels);
  
  nContrastLevelsX = unique(ContrastLevelsX(:));
  nContrastLevelsX = nContrastLevelsX';
  
  nContrastLevelsY = unique(ContrastLevelsY(:));
  nContrastLevelsY = nContrastLevelsY';
else
  sigmas = StartingSigma;
  nContrastLevelsX = 1;
  nContrastLevelsY = 1;
  ContrastLevelsX = ones(rows, cols);
  ContrastLevelsY = ones(rows, cols);
end

nThetas = length(thetas);
rfresponse = zeros(rows, cols, nThetas);
for i = nContrastLevelsX
  lambdaxi = sigmas(i);
  for j = nContrastLevelsY
    lambdayi = sigmas(j);
    for t = 1:nThetas
      rfresponset = rfresponse(:, :, t);
      
      theta = thetas(t);
      sorf = GaussianFilter2(lambdaxi, lambdayi, 0, 0, theta);
      soresponse = imfilter(InputImage, sorf, 'replicate');
      
      dorf = Gaussian2Gradient1(sorf, theta);
      doresponse = imfilter(soresponse, dorf, 'symmetric');
      rfresponset(ContrastLevelsX == i & ContrastLevelsY == j) = doresponse(ContrastLevelsX == i & ContrastLevelsY == j);
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
% rf = Gaussian2Gradient2(GaussianFilter2(2.5));
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

MinPix = 0.29;%min(ContrastIm(:));
MaxPix = 1;%max(ContrastIm(:));
step = ((MaxPix - MinPix) / nContrastLevels);
levels = MinPix:step:MaxPix;

% levels = NormaliseChannel(log(1:nContrastLevels + 1), 0.29, 1.00, [], []);

levels = levels(2:end-1);
ContrastLevels = imquantize(ContrastIm, levels);

end
