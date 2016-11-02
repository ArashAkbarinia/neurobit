function MetamerDiffs = MetamerTestUfeSpectra()

FunctionPath = mfilename('fullpath');
UefDataSetFolder = 'data/dataset/hsi/uef/';
OthersDataSetFolder = 'data/dataset/hsi/others/';
FunctionRelativePath = 'src/algorithms/colouranalysis/MetamerTestUfeSpectra';
UefDataSetPath = strrep(FunctionPath, ['matlab/', FunctionRelativePath], UefDataSetFolder);
OthersDataSetPath = strrep(FunctionPath, ['matlab/', FunctionRelativePath], OthersDataSetFolder);

IlluminantstPath = strrep(FunctionPath, FunctionRelativePath, 'data/mats/hsi/illuminants.mat');
illuminants = load(IlluminantstPath);

[originals.munsell, wavelengths.munsell] = MunsellSpectra(UefDataSetPath);
[originals.candy, wavelengths.candy] = CandySpectra(UefDataSetPath);
[originals.agfa, wavelengths.agfa] = AgfaitSpectra(UefDataSetPath);
[originals.natural, wavelengths.natural] = NaturalSpectra(UefDataSetPath);
[originals.forest, wavelengths.forest] = ForestSpectra(UefDataSetPath);
[originals.lumber, wavelengths.lumber] = LumberSpectra(UefDataSetPath);
[originals.paper, wavelengths.paper] = PaperSpectra(UefDataSetPath);
[originals.cambridge, wavelengths.cambridge] = CambridgeSpectra(OthersDataSetPath);
[originals.fred400, wavelengths.fred400] = Fred400Spectra(OthersDataSetPath);
[originals.fred401, wavelengths.fred401] = Fred401Spectra(OthersDataSetPath);

FundamentalsPath = strrep(FunctionPath, FunctionRelativePath, 'data/mats/hsi/');
ColourReceptorsMat = load([FundamentalsPath, 'Xyz1931SpectralSensitivity.mat']);
% spectral sensitivities of 1931 observers
ColourReceptors = ColourReceptorsMat.Xyz1931SpectralSensitivity;

IlluminantsMat = load([FundamentalsPath, 'illuminants.mat']);
illuminant = IlluminantsMat.d65;

wp = whitepoint('d65');
plotme.munsell = true;
plotme.candy = true;
plotme.agfa = true;
plotme.natural = true;
plotme.forest = true;
plotme.lumber = true;
plotme.paper = true;
plotme.cambridge = true;
plotme.fred400 = true;
plotme.fred401 = true;

SignalNames = fieldnames(originals);
nSignals = numel(SignalNames);

lab = [];
for i = 1:nSignals
  LabVals.(SignalNames{i}) = ComputeLab(originals.(SignalNames{i}), wavelengths.(SignalNames{i}), illuminant, illuminants.wavelength, ColourReceptors, ColourReceptorsMat.wavelength, wp);
  lab = cat(1, lab, LabVals.(SignalNames{i}));
  MetamerDiffs.(SignalNames{i}) = MetamerAnalysisColourDifferences(LabVals.(SignalNames{i}));
end

MetamerDiffs.nfall = MetamerAnalysisColourDifferences(lab);

for i = 1:nSignals
  PlotElementSignals(originals.(SignalNames{i}), MetamerDiffs.(SignalNames{i}));
end

end

function lab = ComputeLab(ev, ew, iv, iw, cv, cw, wp)

[~, ia1, ib] = intersect(ew, iw);
% TODO: it's more accurate to find the intersection of all 3 vectors.
% I assumed the colour receptor and illuminants are similar size.
[~, ia2, ic] = intersect(ew, cw);

lab = hsi2lab(ev(:, :, ia1), iv(ib'), cv(ic', :), wp);

end

function [] = PlotElementSignals(element, MetamerPlot)

SignalLength = size(element, 3);
MetamerPlot.SgnlDiffs = 1 ./ MetamerPlot.CompMat2000;
nSignals = size(element, 1);
PlotTopMetamers(MetamerPlot, reshape(element, nSignals, SignalLength)', 25);

end

function [munsell, wavelength] = MunsellSpectra(DataSetPath)

MunsellPath = [DataSetPath, 'munsell380_780_1_glossy/munsell380_780_1_glossy.mat'];
MunsellMat = load(MunsellPath);

WavelengthSize = size(MunsellMat.glossy, 1);
munsell = MunsellMat.glossy';
munsell = reshape(munsell, size(munsell, 1), 1, WavelengthSize);

wavelength = MunsellMat.wavelength;

end

function [candy, wavelength] = CandySpectra(DataSetPath)

CandyPath = [DataSetPath, 'candy_matlab/candy_matlab.mat'];
CandyMat = load(CandyPath);

WavelengthSize = size(CandyMat.candy, 1);
candy = CandyMat.candy';
candy = reshape(candy, size(candy, 1), 1, WavelengthSize);

wavelength = CandyMat.wavelength;

end

function [agfa, wavelength] = AgfaitSpectra(DataSetPath)

AgfaitPath = [DataSetPath, 'agfait872/agfait872.mat'];
AgfaitMat = load(AgfaitPath);

WavelengthSize = size(AgfaitMat.agfa, 1);
agfa = AgfaitMat.agfa';
agfa = reshape(agfa, size(agfa, 1), 1, WavelengthSize);

wavelength = AgfaitMat.wavelength;

end

function [natural, wavelength] = NaturalSpectra(DataSetPath)

NaturalPath = [DataSetPath, 'natural400_700_5/natural400_700_5.mat'];
[natural, wavelength] = LoadSignal(NaturalPath);

end

function [forest, wavelength] = ForestSpectra(DataSetPath)

ForestPath = [DataSetPath, 'forest_matlab/forest_matlab.mat'];
[forest, wavelength] = LoadSignal(ForestPath);

end

function [lumber, wavelength] = LumberSpectra(DataSetPath)

LumberPath = [DataSetPath, 'lumber_matlab/lumber_matlab.mat'];
[lumber, wavelength] = LoadSignal(LumberPath);

end

function [paper, wavelength] = PaperSpectra(DataSetPath)

PaperPath = [DataSetPath, 'paper_matlab/paper_matlab.mat'];
[paper, wavelength] = LoadSignal(PaperPath);

end

function [cambridge, wavelength] = CambridgeSpectra(DataSetPath)

CambridgePath = [DataSetPath, 'CambridgeAll.mat'];
CambridgeMat = load(CambridgePath);

WavelengthSize = size(CambridgeMat.spectra, 1);
cambridge = CambridgeMat.spectra';
cambridge = reshape(cambridge, size(cambridge, 1), 1, WavelengthSize);

wavelength = CambridgeMat.wavelength;

end

function [fred, wavelength] = Fred400Spectra(DataSetPath)

FredPath = [DataSetPath, 'FReD400.mat'];
[fred, wavelength] = LoadSignal(FredPath);

end

function [fred, wavelength] = Fred401Spectra(DataSetPath)

FredPath = [DataSetPath, 'FReD401.mat'];
[fred, wavelength] = LoadSignal(FredPath);

end

function [LoadedSignal, wavelength] = LoadSignal(SignalPath)

matfile = load(SignalPath);

spectra = matfile.spectra;
SignalNames = fieldnames(spectra);
nSignals = numel(SignalNames);

WavelengthSize = size(matfile.wavelength, 1);
LoadedSignal = [];
for i = 1:nSignals
  CurrentSpectra = spectra.(SignalNames{i})';
  LoadedSignal = [LoadedSignal; reshape(CurrentSpectra, size(CurrentSpectra, 1), 1, WavelengthSize)]; %#ok
end

wavelength = matfile.wavelength;

end
