function MetamerDiffs = MetamerTestUfeSpectra()

FunctionPath = mfilename('fullpath');
DataSetFolder = 'data/dataset/hsi/uef/';
FunctionRelativePath = 'src/algorithms/colouranalysis/MetamerTestUfeSpectra';
DataSetPath = strrep(FunctionPath, ['matlab/', FunctionRelativePath], DataSetFolder);

IlluminantstPath = strrep(FunctionPath, FunctionRelativePath, 'data/mats/hsi/illuminants.mat');
illuminants = load(IlluminantstPath);

[natural, NaturalWavelength] = NaturalSpectra(DataSetPath);
[forest, ForestWavelength] = ForestSpectra(DataSetPath);

FundamentalsPath = strrep(FunctionPath, FunctionRelativePath, 'data/mats/hsi/');
ColourReceptorsMat = load([FundamentalsPath, 'Xyz1931SpectralSensitivity.mat']);
% spectral sensitivities of 1931 observers
ColourReceptors = ColourReceptorsMat.Xyz1931SpectralSensitivity;

IlluminantsMat = load([FundamentalsPath, 'illuminants.mat']);
illuminant = IlluminantsMat.d65;

wp = whitepoint('d65');
plotmenatural = true;
plotmeforest = true;

NaturalInds = find(illuminants.wavelength == NaturalWavelength(1)):5:find(illuminants.wavelength == NaturalWavelength(end));
NaturalColourReceptorsInds = find(ColourReceptorsMat.wavelength == NaturalWavelength(1)):find(ColourReceptorsMat.wavelength == NaturalWavelength(end));

ForestInds = find(illuminants.wavelength == ForestWavelength(1)):5:391;
ForestColourReceptorsInds = find(ColourReceptorsMat.wavelength == ForestWavelength(1)):81;

NaturalLab = hsi2lab(natural, illuminant(NaturalInds'), ColourReceptors(NaturalColourReceptorsInds', :), wp);
ForestLab = hsi2lab(forest(:, :, 1:79), illuminant(ForestInds'), ColourReceptors(ForestColourReceptorsInds', :), wp);
lab = cat(1, NaturalLab, ForestLab);
MetamerDiffs.natural = MetamerAnalysisColourDifferences(NaturalLab);
MetamerDiffs.forest = MetamerAnalysisColourDifferences(ForestLab);
MetamerDiffs.nfall = MetamerAnalysisColourDifferences(lab);

if plotmenatural
  SignalLength = size(natural, 3);
  MetamerPlot = MetamerDiffs.natural;
  MetamerPlot.SgnlDiffs = 1 ./ MetamerPlot.CompMat2000;
  nSignals = size(natural, 1);
  PlotTopMetamers(MetamerPlot, reshape(natural, nSignals, SignalLength)', 25);
end

if plotmeforest
  SignalLength = size(forest, 3);
  MetamerPlot = MetamerDiffs.forest;
  MetamerPlot.SgnlDiffs = 1 ./ MetamerPlot.CompMat2000;
  nSignals = size(forest, 1);
  PlotTopMetamers(MetamerPlot, reshape(forest, nSignals, SignalLength)', 25);
end

end

function [natural, wavelength] = NaturalSpectra(DataSetPath)

NaturalPath = [DataSetPath, 'natural400_700_5/natural400_700_5.mat'];
NaturalMat = load(NaturalPath);

spectra = NaturalMat.spectra;
SignalNames = fieldnames(spectra);
nSignals = numel(SignalNames);

WavelengthSize = size(NaturalMat.wavelength, 1);
natural = zeros(nSignals, 1, WavelengthSize);
for i = 1:nSignals
  natural(i, :, :) = reshape(spectra.(SignalNames{i}), 1, 1, WavelengthSize);
end

wavelength = NaturalMat.wavelength;

end

function [forest, wavelength] = ForestSpectra(DataSetPath)

ForestPath = [DataSetPath, 'forest_matlab/forest_matlab.mat'];
ForestMat = load(ForestPath);

WavelengthSize = size(ForestMat.birch, 1);
birch = ForestMat.birch';
birch = reshape(birch, size(birch, 1), 1, WavelengthSize);
pine = ForestMat.pine';
pine = reshape(pine, size(pine, 1), 1, WavelengthSize);
spruce = ForestMat.spruce';
spruce = reshape(spruce, size(spruce, 1), 1, WavelengthSize);

forest = cat(1, birch, pine, spruce);
wavelength = ForestMat.wavelength;

end
