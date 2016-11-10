function MetamerMat = MetamerTestUfeSpectra()

FunctionPath = mfilename('fullpath');
FunctionRelativePath = 'src/algorithms/colouranalysis/MetamerTestUfeSpectra';

IlluminantstPath = strrep(FunctionPath, FunctionRelativePath, 'data/mats/hsi/illuminants.mat');
illuminants = load(IlluminantstPath);

FundamentalsPath = strrep(FunctionPath, FunctionRelativePath, 'data/mats/hsi/');
ColourReceptorsMat = load([FundamentalsPath, 'Xyz1931SpectralSensitivity.mat']);

IlluminantNames = {'d65', 'a', 'c'};
plotme = false;
AllSpectra = GetSpectra();

for i = 1:numel(IlluminantNames)
  disp(['Illuminant ', IlluminantNames{i}]);
  wp = whitepoint(IlluminantNames{i});
  illuminants.spectra = illuminants.(IlluminantNames{i});
  MetamerDiffs.(IlluminantNames{i}) = MetamerTestIlluminant(AllSpectra, illuminants, ColourReceptorsMat, wp, plotme);
end

MetamerMat = MetamerDiffs.(IlluminantNames{1});
SignalNames = fieldnames(MetamerMat);
nSignals = numel(SignalNames);
MetaInfoNames = fieldnames(MetamerMat.(SignalNames{1}));
nMetaInfo = numel(MetaInfoNames);
for i = 2:numel(IlluminantNames)
  for j = 1:nSignals
    for k = 1:nMetaInfo
      CatMetamers = MetamerMat.(SignalNames{j}).(MetaInfoNames{k});
      CatMetamers(:, :, end + 1) = MetamerDiffs.(IlluminantNames{i}).(SignalNames{j}).(MetaInfoNames{k}); %#ok
      MetamerMat.(SignalNames{j}).(MetaInfoNames{k}) = CatMetamers;
    end
  end
end

end

function AllSpectra = GetSpectra()

FunctionPath = mfilename('fullpath');
UefDataSetFolder = 'data/dataset/hsi/uef/';
OthersDataSetFolder = 'data/dataset/hsi/others/';
FunctionRelativePath = 'src/algorithms/colouranalysis/MetamerTestUfeSpectra';
UefDataSetPath = strrep(FunctionPath, ['matlab/', FunctionRelativePath], UefDataSetFolder);
OthersDataSetPath = strrep(FunctionPath, ['matlab/', FunctionRelativePath], OthersDataSetFolder);

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
[originals.barnard, wavelengths.barnard] = BarnardSpectra(OthersDataSetPath);
[originals.matsumoto, wavelengths.matsumoto] = MatsumotoSpectra(OthersDataSetPath);
[originals.westland, wavelengths.westland] = WestlandSpectra(OthersDataSetPath);

AllSpectra.originals = originals;
AllSpectra.wavelengths = wavelengths;

end

function MetamerDiffs = MetamerTestIlluminant(AllSpectra, illuminants, ColourReceptors, wp, plotmeall)

originals = AllSpectra.originals;
wavelengths = AllSpectra.wavelengths;

plotme.munsell = plotmeall;
plotme.candy = plotmeall;
plotme.agfa = plotmeall;
plotme.natural = plotmeall;
plotme.forest = plotmeall;
plotme.lumber = plotmeall;
plotme.paper = plotmeall;
plotme.cambridge = plotmeall;
plotme.fred400 = plotmeall;
plotme.fred401 = plotmeall;
plotme.barnard = plotmeall;
plotme.matsumoto = plotmeall;
plotme.westland = plotmeall;

SignalNames = fieldnames(originals);
nSignals = numel(SignalNames);

lab = [];
for i = 1:nSignals
  disp(['  Processing ', SignalNames{i}]);
  LabVals.(SignalNames{i}) = ComputeLab(originals.(SignalNames{i}), wavelengths.(SignalNames{i}), ...
    illuminants.spectra, illuminants.wavelength, ...
    ColourReceptors.Xyz1931SpectralSensitivity, ColourReceptors.wavelength, ...
    wp);
  lab = cat(1, lab, LabVals.(SignalNames{i}));
  MetamerDiffs.(SignalNames{i}) = MetamerAnalysisColourDifferences(LabVals.(SignalNames{i}));
end

disp('  Processing all');
MetamerDiffs.nfall = MetamerAnalysisColourDifferences(lab);

for i = 1:nSignals
  if plotme.(SignalNames{i})
    PlotElementSignals(originals.(SignalNames{i}), MetamerDiffs.(SignalNames{i}), wavelengths.(SignalNames{i}), LabVals.(SignalNames{i}));
  end
end

end

function lab = ComputeLab(ev, ew, iv, iw, cv, cw, wp)

[~, ia1, ib] = intersect(ew, iw);
% TODO: it's more accurate to find the intersection of all 3 vectors.
% I assumed the colour receptor and illuminants are similar size.
[~, ia2, ic] = intersect(ew, cw);

lab = hsi2lab(ev(:, :, ia1), iv(ib'), cv(ic', :), wp);

end

function [] = PlotElementSignals(element, MetamerPlot, wavelength, lab)

SignalLength = size(element, 3);
MetamerPlot.SgnlDiffs = 1 ./ MetamerPlot.CompMat2000;
nSignals = size(element, 1);
PlotTopMetamers(MetamerPlot, reshape(element, nSignals, SignalLength)', 25, wavelength, lab);

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

function [barnard, wavelength] = BarnardSpectra(DataSetPath)

BarnardPath = [DataSetPath, 'BarnardNoMunsellNoMacbeth.mat'];
BarnardMat = load(BarnardPath);

WavelengthSize = size(BarnardMat.spectra, 1);
barnard = BarnardMat.spectra';
barnard = reshape(barnard, size(barnard, 1), 1, WavelengthSize);

wavelength = BarnardMat.wavelength;

end

function [matsumoto, wavelength] = MatsumotoSpectra(DataSetPath)

MatsumotoPath = [DataSetPath, 'matsumoto.mat'];
[matsumoto, wavelength] = LoadSignal(MatsumotoPath);

end

function [westland, wavelength] = WestlandSpectra(DataSetPath)

WestlandPath = [DataSetPath, 'westland.mat'];
WestlandMat = load(WestlandPath);

WavelengthSize = size(WestlandMat.spectra, 1);
westland = WestlandMat.spectra';
westland = reshape(westland, size(westland, 1), 1, WavelengthSize);

wavelength = WestlandMat.wavelength;

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
