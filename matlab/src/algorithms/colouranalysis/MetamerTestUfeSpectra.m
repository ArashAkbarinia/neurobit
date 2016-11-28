function [MetamerMats, UniqueMetaners] = MetamerTestUfeSpectra(ColourReceptors, IlluminantNames)

FunctionPath = mfilename('fullpath');
FunctionRelativePath = 'src/algorithms/colouranalysis/MetamerTestUfeSpectra';

IlluminantstPath = strrep(FunctionPath, FunctionRelativePath, 'data/mats/hsi/illuminants.mat');
illuminants = load(IlluminantstPath);

FundamentalsPath = strrep(FunctionPath, FunctionRelativePath, 'data/mats/hsi/');

if nargin < 1 || isempty(ColourReceptors)
  ColourReceptorsMat = load([FundamentalsPath, 'XyzSpectralSensitivity.mat']);
  ColourReceptors.spectra = ColourReceptorsMat.Xyz1931SpectralSensitivity;
  ColourReceptors.wavelength = ColourReceptorsMat.wavelength;
end

if nargin < 2 || isempty(IlluminantNames)
  IlluminantNames = {'d65'};
end
plotme = false;
plotmeunique = true;
AllSpectra = GetSpectra();

for i = 1:numel(IlluminantNames)
  disp(['Illuminant ', IlluminantNames{i}]);
  wp = whitepoint(IlluminantNames{i});
  illuminants.spectra = illuminants.(IlluminantNames{i});
  MetamerDiffs.(IlluminantNames{i}) = MetamerTestIlluminantAll(AllSpectra, illuminants, ColourReceptors, wp);
end

MetamerMats = MetamerDiffs;
UniqueMetaners = [];
return;

MetamerMats = MetamerDiffs.(IlluminantNames{1});
SignalNames = fieldnames(MetamerMats);
nSignals = numel(SignalNames);
ColourDifferenceMeasures = fieldnames(MetamerMats.(SignalNames{1}));
nColourDifferences = numel(ColourDifferenceMeasures);
MetaInfos = fieldnames(MetamerMats.(SignalNames{1}).(ColourDifferenceMeasures{1}));
nMetaInfos = numel(MetaInfos);

% set the illuminants as channels
for i = 2:numel(IlluminantNames)
  for j = 1:nSignals
    for k = 1:nColourDifferences
      for l = 1:nMetaInfos
        CatMetamers = MetamerMats.(SignalNames{j}).(ColourDifferenceMeasures{k}).(MetaInfos{l});
        CatMetamers(:, :, end + 1) = MetamerDiffs.(IlluminantNames{i}).(SignalNames{j}).(ColourDifferenceMeasures{k}).(MetaInfos{l}); %#ok
        MetamerMats.(SignalNames{j}).(ColourDifferenceMeasures{k}).(MetaInfos{l}) = CatMetamers;
      end
    end
  end
end

disp('***Unique metamers***');
UniqueMetaners = struct();
for j = 1:nSignals
  disp(SignalNames{j});
  for k = 1:numel(ColourDifferenceMeasures)
    CurrentMetamers = MetamerMats.(SignalNames{j}).(ColourDifferenceMeasures{k}).metamers;
    AnyMetamers = any(CurrentMetamers, 3);
    AllMetamers = all(CurrentMetamers, 3);
    AnyMetamers(AllMetamers) = false;
    
    CurrentCompMat = mean(MetamerMats.(SignalNames{j}).(ColourDifferenceMeasures{k}).CompMat, 3);
    
    UniqueMetaners.(SignalNames{j}).(ColourDifferenceMeasures{k}).metamers = AnyMetamers;
    UniqueMetaners.(SignalNames{j}).(ColourDifferenceMeasures{k}).CompMat = CurrentCompMat;
  end
  PrintMetamer = UniqueMetaners.(SignalNames{j});
  printinfo(PrintMetamer);
  
  if plotmeunique && ~strcmpi(SignalNames{j}, 'nfall')
    % LabVals.(SignalNames{j})
    PlotElementSignals(AllSpectra.originals.(SignalNames{j}), UniqueMetaners.(SignalNames{j}), AllSpectra.wavelengths.(SignalNames{j}), [], SignalNames{i});
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

function MetamerDiffs = MetamerTestIlluminantAll(AllSpectra, illuminants, ColourReceptors, wp)

originals = AllSpectra.originals;
wavelengths = AllSpectra.wavelengths;

SignalNames = fieldnames(originals);
nSignals = numel(SignalNames);

lab = [];
for i = 1:nSignals
  LabVals.(SignalNames{i}) = ComputeLab(originals.(SignalNames{i}), wavelengths.(SignalNames{i}), ...
    illuminants.spectra, illuminants.wavelength, ...
    ColourReceptors.spectra, ColourReceptors.wavelength, ...
    wp);
  lab = cat(1, lab, LabVals.(SignalNames{i}));
end

% TODO: too much memory optimise it
disp('  Processing all');
MetamerDiffs.nfall = MetamerAnalysisColourDifferences(lab, 0.5, false, false, true);
printinfo(MetamerDiffs.nfall, size(lab, 1));

end

function MetamerDiffs = MetamerTestIlluminantSingle(AllSpectra, illuminants, ColourReceptors, wp, plotmeall)

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
    ColourReceptors.spectra, ColourReceptors.wavelength, ...
    wp);
  lab = cat(1, lab, LabVals.(SignalNames{i}));
  MetamerReport = MetamerAnalysisColourDifferences(LabVals.(SignalNames{i}), 0.5, false, false, true);
  MetamerDiffs.(SignalNames{i}) = MetamerReport;
  
  nCurrentSignals = size(lab, 1);
  printinfo(MetamerReport, nCurrentSignals);
  
  if plotme.(SignalNames{i})
    PlotElementSignals(originals.(SignalNames{i}), MetamerDiffs.(SignalNames{i}), wavelengths.(SignalNames{i}), LabVals.(SignalNames{i}), SignalNames{i});
  end
end

end

function printinfo(MetamerReport, nCurrentSignals)

if nargin < 2
  nCurrentSignals = size(MetamerReport.m1976.metamers, 1);
end

% printinfoyear(MetamerReport.m1976.metamers, '    Metamer-1976: ', nCurrentSignals);
% printinfoyear(MetamerReport.m1994.metamers, '    Metamer-1994: ', nCurrentSignals);
printinfoyear(MetamerReport.m2000.metamers, '    Metamer-2000: ', nCurrentSignals);

end

function [] = printinfoyear(MetamerReport, PreText, nCurrentSignals)
nAll = sum(MetamerReport(:)) / 2;
disp([PreText, num2str(nAll / ((nCurrentSignals * (nCurrentSignals - 1)) / 2))]);
end

function lab = ComputeLab(ev, ew, iv, iw, cv, cw, wp)

[~, ia1, ib] = intersect(ew, iw);
% TODO: it's more accurate to find the intersection of all 3 vectors.
% I assumed the colour receptor and illuminants are similar size.
[~, ia2, ic] = intersect(ew, cw);

lab = hsi2lab(ev(:, :, ia1), iv(ib'), cv(ic', :), wp);

end

function [] = PlotElementSignals(element, MetamerPlot, wavelength, lab, name)

% TODO: plot for all rather than just 2000
MetamerPlot = MetamerPlot.m2000;

SignalLength = size(element, 3);
MetamerPlot.SgnlDiffs = 1 ./ MetamerPlot.CompMat;
nSignals = size(element, 1);
PlotTopMetamers(MetamerPlot, reshape(element, nSignals, SignalLength)', 25, wavelength, lab, name);

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
