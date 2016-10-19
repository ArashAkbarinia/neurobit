function MetamerReport = MetamerAnalysis(InputSignal, ColourReceptors, illuminants, settings)
%MetamerAnalysis  analysis the input signal for metamerism
%

FunctionPath = mfilename('fullpath');
FolderPath = strrep(FunctionPath, 'matlab/src/algorithms/algorithms/MetamerAnalysis', 'matlab/data/mats/hsi/');

if nargin < 2 || isempty(ColourReceptors)
  ColourReceptorsMat = load([FolderPath, 'ConeSpectralSensitivity.mat']);
  % spectral sensitivities (Stockman & Sharpe, 2000)
  ColourReceptors = ColourReceptorsMat.ConeSpectralSensitivity;
  % (from 390 to 780 nm, specral resolution = 1nm)
  wavelengths = ColourReceptorsMat.wavelength;
end

[w, t] = size(ColourReceptors);
if t ~= 3
  warning('MetamerAnalysis only handles tristimulus values');
  MetamerReport = [];
  return;
end

% TODO: should we normalise the colour receptors?
ColourReceptors = ColourReceptors ./ repmat(max(ColourReceptors), [w, 1]);

[rows, cols] = size(InputSignal);
nIlluminants = size(illuminants, 2);

ReflectedLights = zeros(rows, cols, nIlluminants);
ConeResponses = zeros(cols, t, nIlluminants);

for j = 1:nIlluminants
  ReflectedLights(:, :, j) = repmat(illuminants(:, j), [1, cols]) .* InputSignal;
  
  ConeResponses(:, :, j) = (ColourReceptors' * ReflectedLights(:, :, j))';
end

% TODO: should we normalise the cone responses and reflected lights? Then
% achromatic ones seem metameric!
ConeResponses = ConeResponses ./ repmat(max(ConeResponses, [], 2), [1, t, 1]);
ReflectedLights = ReflectedLights ./ repmat(max(ReflectedLights, [], 2), [1, cols, 1]);

ConeDiffs = zeros(cols, cols, nIlluminants);
SgnlDiffs = zeros(cols, cols, nIlluminants);

if nargin < 4
  settings.signalcomp = @(x, y) sqrt(sum((x - y) .^ 2));
  settings.signalthr = 1;
  settings.conecomp = settings.signalcomp;
  settings.conethr = 0.01;
end

for j = 1:nIlluminants
  for i = 1:cols
    ConeDiffs(i, :, j) = settings.conecomp(repmat(ConeResponses(i, :, j), [cols, 1, 1])', ConeResponses(:, :, j)');
    SgnlDiffs(i, :, j) = settings.signalcomp(repmat(ReflectedLights(:, i, j), [1, cols, 1]), ReflectedLights(:, :, j));
  end
end

MetamerReport.ConeDiffs = ConeDiffs;
MetamerReport.SgnlDiffs = SgnlDiffs;

MetamerReport.metamers = SgnlDiffs > settings.signalthr & ConeDiffs < settings.conethr;
MetamerReport.MetamerGroups = FindMetamerGroups(ConeResponses, settings.conethr);

end
