function MetamerReport = MetamerAnalysisColourDifferences(InputSignal, ColourReceptors, illuminant)
%MetamerAnalysisColourDifferences Summary of this function goes here
%   Detailed explanation goes here

FunctionPath = mfilename('fullpath');
FolderPath = strrep(FunctionPath, 'matlab/src/algorithms/colouranalysis/MetamerAnalysisColourDifferences', 'matlab/data/mats/hsi/');

if nargin < 2 || isempty(ColourReceptors)
  ColourReceptorsMat = load([FolderPath, 'Xyz1931SpectralSensitivity.mat']);
  % spectral sensitivities of 1931 observers
  ColourReceptors = ColourReceptorsMat.Xyz1931SpectralSensitivity;
  
  IlluminantsMat = load([FolderPath, 'illuminants.mat']);
  illuminant = IlluminantsMat.d65;
  % TODO: fix the hard coded values
  illuminant = illuminant(11:10:311);
  
  wp = whitepoint('d65');
end

lab = hsi2lab(InputSignal, illuminant, ColourReceptors, wp);

nSignals = size(lab, 1);
lab = reshape(lab, nSignals, 3);
CompMat1976 = zeros(nSignals, nSignals);
CompMat1994 = zeros(nSignals, nSignals);
CompMat2000 = zeros(nSignals, nSignals);
for i = 1:nSignals
  RowI = repmat(lab(i, :), [nSignals, 1]);
  CompMat1976(i, :) = deltae1976(RowI, lab);
  CompMat1994(i, :) = deltae1994(RowI, lab);
  CompMat2000(i, :) = deltae2000(RowI, lab);
end

MetamerReport.CompMat1976 = CompMat1976;
MetamerReport.CompMat1994 = CompMat1994;
MetamerReport.CompMat2000 = CompMat2000;

MetamerReport.metamers = CompMat1976 < 0.5 & CompMat1994 < 0.5 & CompMat2000 < 0.5;

nAll = (sum(MetamerReport.metamers(:)) - nSignals) / 2;
disp(['Metamer percentage: ', num2str(nAll / ((nSignals * (nSignals - 1)) / 2))]);

SignalLength = size(InputSignal, 3);
MetamerReport.SgnlDiffs = 1 ./ MetamerReport.CompMat2000;
PlotTopMetamers(MetamerReport, reshape(InputSignal, nSignals, SignalLength)', 25);

end
