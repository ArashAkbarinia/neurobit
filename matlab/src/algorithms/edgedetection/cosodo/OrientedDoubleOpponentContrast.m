function dor = OrientedDoubleOpponentContrast(isignal, CentreSigma, nangles, DebugImagePath, c, weights1)

if nargin < 3
  nangles = 8;
end

CentreContrastEnlarge = 2;
CentreContrastLevels = 8;

% compute responses of single-opponent cells
% sor = SingleOpponentContrast(isignal, CentreSigma, CentreContrastEnlarge, CentreContrastLevels);

% construct RF of the oriented double-opponent
SurroundSigma = 2 * 1.1;%2 * CentreSigma;
% dor = zeros(size(isignal,1),size(isignal,2),nangles);

% Obtain the response with the filters in degree of [0 pi],
% and then taking the absolute value, which is same as rotating the  filters
% in [0 2*pi]
thetas = zeros(1, nangles);
for i = 1:nangles
  thetas(i) = (i - 1) * pi / nangles;
  
  %   dgau2D = GaussianGradient1(GaussianFilter2(SurroundSigma), thetas(i));
  %   t1 = conByfft(sor, dgau2D);
  %
  %   dor(:,:,i) = abs(t1);
end

SurroundContrastEnlarge = 2;
SurroundContrastLevels = 4;
% dor = abs(ContrastDependantGaussianGradient(isignal, SurroundSigma, SurroundContrastEnlarge, SurroundContrastLevels, 1, thetas, map));
% dor = abs(ContrastDependantGaussian(isignal, CentreSigma, CentreContrastEnlarge, CentreContrastLevels, thetas));
dor = SurroundContrast(isignal, CentreSigma, CentreContrastEnlarge, CentreContrastLevels, thetas, DebugImagePath, c, weights1);

end

function sor = SingleOpponentContrast(isignal, CentreSigma, ContrastEnlarge, ContrastLevels)

NearSigma = CentreSigma * 5;
FarSigma = NearSigma * 3;

cr = ContrastDependantGaussian(isignal, CentreSigma, ContrastEnlarge, ContrastLevels);
sr = imfilter(isignal, GaussianFilter2(NearSigma), 'replicate');
fr = imfilter(isignal, GaussianFilter2(FarSigma), 'replicate');

sor = 1.0 .* cr - 0.5 .* sr + 0.2 * fr;

end

function sor = SurroundContrast(isignal, CentreSigma, ContrastEnlarge, ContrastLevels, thetas, DebugImagePath, c, weights1)

if ~DebugImagePath
  NearSigma = CentreSigma * 5;
  FarSigma = NearSigma * 3;
  
  cr = abs(ContrastDependantGaussian(isignal, CentreSigma, ContrastEnlarge, ContrastLevels, thetas));
  nr = abs(ContrastDependantGaussian(isignal, NearSigma, 1, 1, thetas));
  fr = abs(ContrastDependantGaussian(isignal, FarSigma, 1, 1, thetas));
  
  CentreSize = 3;
  [CentreContrast, NearContrast, FarContrast] = ContrastProcesses(isignal, CentreSize);
else
  SlashIndices = strfind(DebugImagePath, '/');
  LastIndex = SlashIndices(end);
  DebugFolderPath = [DebugImagePath(1:LastIndex), 'DebugFolder/'];
  if ~exist(DebugFolderPath, 'dir')
    mkdir(DebugFolderPath);
  end
  DebugPathMat = [DebugFolderPath, DebugImagePath(LastIndex + 1 : length(DebugImagePath) - 4), '-', num2str(c), '.mat'];
  
  if ~exist(DebugPathMat, 'file')
    NearSigma = CentreSigma * 5;
    FarSigma = NearSigma * 3;
    
    cr = abs(ContrastDependantGaussian(isignal, CentreSigma, ContrastEnlarge, ContrastLevels, thetas));
    nr = abs(ContrastDependantGaussian(isignal, NearSigma, 1, 1, thetas));
    fr = abs(ContrastDependantGaussian(isignal, FarSigma, 1, 1, thetas));
    
    CentreSize = 3;
    [CentreContrast, NearContrast, FarContrast] = ContrastProcesses(isignal, CentreSize);
    
    save(DebugPathMat, 'cr', 'nr', 'fr', 'CentreContrast', 'NearContrast', 'FarContrast');
  else
    AlreayStoredData = load(DebugPathMat);
    
    cr = AlreayStoredData.cr;
    nr = AlreayStoredData.nr;
    fr = AlreayStoredData.fr;
    
    CentreContrast = AlreayStoredData.CentreContrast;
    NearContrast = AlreayStoredData.NearContrast;
    FarContrast = AlreayStoredData.FarContrast;
  end
end

% latest results
% weights1 = [0.50, 1.00, -0.75, +0.75, -0.15, 0.15];
contrasts = {CentreContrast, NearContrast, FarContrast};
rfs = {cr, nr, fr};
sor = ContrastSurroundImpact(weights1, contrasts, rfs);


% weights1 = [0.75, 1.00, -0.75, -0.25, 0.00, 0.15];
% contrasts = {CentreContrast, NearContrast, FarContrast};
% rfs = {cr, nr, fr};
% 
% weights2 = [0.75, 1.00, 0.25, 0.75, 0.00, 0.15];
% 
% sor1 = ContrastSurroundImpact(weights1, contrasts, rfs);
% sor2 = OrientationSurroundImpact(weights2, contrasts, rfs);
% 
% sor = sor1 + sor2;

end

function sor = ContrastSurroundImpact(weights, contrasts, rfs)

cl = weights(1);
ch = weights(2);
nl = weights(3);
nh = weights(4);
fl = weights(5);
fh = weights(6);

CentreContrast = contrasts{1};
NearContrast = contrasts{2};
FarContrast = contrasts{3};

CentreWeights = NormaliseChannel(CentreContrast, cl, ch, [], []);
NearWeights = NormaliseChannel(NearContrast, nl, nh, [], []);
FarWeights = NormaliseChannel(FarContrast, fl, fh, [], []);

cr = rfs{1};
nr = rfs{2};
fr = rfs{3};

sor = zeros(size(cr));
for i = 1:size(cr, 3)
  sor(:, :, i) = CentreWeights .* cr(:, :, i) + NearWeights .* nr(:, :, i) + FarWeights .* fr(:, :, i);
end

end

function sor = OrientationSurroundImpact(weights, contrasts, rfs)

cl = weights(1);
ch = weights(2);
nl = weights(3);
nh = weights(4);
fl = weights(5);
fh = weights(6);

CentreContrast = contrasts{1};
NearContrast = contrasts{2};
FarContrast = contrasts{3};

CentreWeights = NormaliseChannel(CentreContrast, cl, ch, [], []);

cr = rfs{1};
nr = rfs{2};
fr = rfs{3};

sor = zeros(size(cr));
for i = 1:size(cr, 3)
  j = i + 4;
  if j > size(cr, 3)
    j = i - 4;
  end
  ndiff = abs(cr(:, :, i) - nr(:, :, j));
  NearWeights = NormaliseChannel(ndiff, nl, nh, [], []);
  
  fdiff = abs(cr(:, :, i) - fr(:, :, j));
  FarWeights = NormaliseChannel(fdiff, fl, fh, [], []);
  sor(:, :, i) = CentreWeights .* cr(:, :, i) + NearWeights .* nr(:, :, j) + FarWeights .* fr(:, :, j);
end

end

function [CentreContrast, SurroundContrast, FarContrast] = ContrastProcesses(isignal, CentreSize)

SurroundEnlarge = 5;
FarEnlarge = 3 * SurroundEnlarge;

CentreContrast = GetContrastImage(isignal, CentreSize);
SurroundContrast = GetContrastImage(isignal, SurroundEnlarge * CentreSize, CentreSize);
FarContrast = GetContrastImage(isignal, FarEnlarge * CentreSize, SurroundEnlarge * CentreSize);

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