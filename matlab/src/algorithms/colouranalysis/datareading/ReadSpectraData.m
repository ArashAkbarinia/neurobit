function [AllSpectra, spectra, wavelength] = ReadSpectraData(normalised)
%ReadSpectraData  utility function to reads all spectra data we have

if nargin < 1
  normalised = false;
end

FunctionPath = mfilename('fullpath');
UefDataSetFolder = ['data', filesep, 'dataset', filesep, 'hsi', filesep, 'uef', filesep];
OthersDataSetFolder = ['data', filesep, 'dataset', filesep, 'hsi', filesep, 'others', filesep];
FunctionRelativePath = ['src', filesep, 'algorithms', filesep, 'colouranalysis', filesep, 'datareading', filesep, 'ReadSpectraData'];
UefDataSetPath = strrep(FunctionPath, ['matlab', filesep, FunctionRelativePath], UefDataSetFolder);
OthersDataSetPath = strrep(FunctionPath, ['matlab', filesep, FunctionRelativePath], OthersDataSetFolder);

[originals.munsell, wavelengths.munsell, ranges.munsell] = MunsellSpectra(UefDataSetPath);
[originals.agfa, wavelengths.agfa, ranges.agfa] = AgfaitSpectra(UefDataSetPath);
[originals.natural, wavelengths.natural, ranges.natural] = NaturalSpectra(UefDataSetPath);
[originals.forest, wavelengths.forest, ranges.forest] = ForestSpectra(UefDataSetPath);
[originals.lumber, wavelengths.lumber, ranges.lumber] = LumberSpectra(UefDataSetPath);
[originals.paper, wavelengths.paper, ranges.paper] = PaperSpectra(UefDataSetPath);
[originals.cambridge, wavelengths.cambridge, ranges.cambridge] = CambridgeSpectra(OthersDataSetPath);
[originals.fred400, wavelengths.fred400, ranges.fred400] = Fred400Spectra(OthersDataSetPath);
[originals.fred401, wavelengths.fred401, ranges.fred401] = Fred401Spectra(OthersDataSetPath);
[originals.barnard, wavelengths.barnard, ranges.barnard] = BarnardSpectra(OthersDataSetPath);
[originals.matsumoto, wavelengths.matsumoto, ranges.matsumoto] = MatsumotoSpectra(OthersDataSetPath);
[originals.westland, wavelengths.westland, ranges.westland] = WestlandSpectra(OthersDataSetPath);
[originals.artist, wavelengths.artist, ranges.artist] = ArtistSpectra(OthersDataSetPath);

AllSpectra.originals = originals;
AllSpectra.wavelengths = wavelengths;
AllSpectra.ranges = ranges;

CatNames = fieldnames(AllSpectra.originals);

si = 1;
for i = 1:numel(CatNames)
  name = CatNames{i};
  for j = 1:size(AllSpectra.originals.(name), 1)
    if normalised
      AllSpectra.originals.(name)(j, :, :) = min(AllSpectra.originals.(name)(j, :, :), AllSpectra.ranges.(name)(2));
      AllSpectra.originals.(name)(j, :, :) = max(AllSpectra.originals.(name)(j, :, :), AllSpectra.ranges.(name)(1));
      AllSpectra.originals.(name)(j, :, :) = AllSpectra.originals.(name)(j, :, :) / AllSpectra.ranges.(name)(2);
    end
    spectra{si, 1} = AllSpectra.originals.(name)(j, :, :); %#ok
    wavelength{si, 1} = AllSpectra.wavelengths.(name); %#ok
    si = si + 1;
  end
  AllSpectra.ranges.(name) = [0, 1];
end

end

function [munsell, wavelength, range] = MunsellSpectra(DataSetPath)

MunsellPath = [DataSetPath, 'munsell380_780_1_glossy', filesep, 'munsell380_780_1_glossy.mat'];
MunsellMat = load(MunsellPath);

WavelengthSize = size(MunsellMat.glossy, 1);
munsell = MunsellMat.glossy';
munsell = reshape(munsell, size(munsell, 1), 1, WavelengthSize);

wavelength = MunsellMat.wavelength;
range = [0, 1];

end

function [agfa, wavelength, range] = AgfaitSpectra(DataSetPath)

AgfaitPath = [DataSetPath, 'agfait872', filesep, 'agfait872.mat'];
AgfaitMat = load(AgfaitPath);

WavelengthSize = size(AgfaitMat.agfa, 1);
agfa = AgfaitMat.agfa';
agfa = reshape(agfa, size(agfa, 1), 1, WavelengthSize);

wavelength = AgfaitMat.wavelength;
range = [0, 100];

end

function [natural, wavelength, range] = NaturalSpectra(DataSetPath)

NaturalPath = [DataSetPath, 'natural400_700_5', filesep, 'natural400_700_5.mat'];
[natural, wavelength] = LoadSignal(NaturalPath);
range = [0, 4096];

end

function [forest, wavelength, range] = ForestSpectra(DataSetPath)

ForestPath = [DataSetPath, 'forest_matlab', filesep, 'forest_matlab.mat'];
[forest, wavelength] = LoadSignal(ForestPath);
range = [0, 1];

end

function [lumber, wavelength, range] = LumberSpectra(DataSetPath)

LumberPath = [DataSetPath, 'lumber_matlab', filesep, 'lumber_matlab.mat'];
[lumber, wavelength] = LoadSignal(LumberPath);
range = [0, 1];

end

function [paper, wavelength, range] = PaperSpectra(DataSetPath)

PaperPath = [DataSetPath, 'paper_matlab', filesep, 'paper_matlab.mat'];
[paper, wavelength] = LoadSignal(PaperPath);
range = [0, 100];

end

function [cambridge, wavelength, range] = CambridgeSpectra(DataSetPath)

CambridgePath = [DataSetPath, 'CambridgeAll.mat'];
CambridgeMat = load(CambridgePath);

WavelengthSize = size(CambridgeMat.spectra, 1);
cambridge = CambridgeMat.spectra';
cambridge = reshape(cambridge, size(cambridge, 1), 1, WavelengthSize);

wavelength = CambridgeMat.wavelength;
range = [0, 1];

end

function [fred, wavelength, range] = Fred400Spectra(DataSetPath)

FredPath = [DataSetPath, 'FReD400.mat'];
[fred, wavelength] = LoadSignal(FredPath);
range = [0, 1];

end

function [fred, wavelength, range] = Fred401Spectra(DataSetPath)

FredPath = [DataSetPath, 'FReD401.mat'];
[fred, wavelength] = LoadSignal(FredPath);
range = [0, 1];

end

function [barnard, wavelength, range] = BarnardSpectra(DataSetPath)

BarnardPath = [DataSetPath, 'BarnardNoMunsellNoMacbeth.mat'];
BarnardMat = load(BarnardPath);

WavelengthSize = size(BarnardMat.spectra, 1);
barnard = BarnardMat.spectra';
barnard = reshape(barnard, size(barnard, 1), 1, WavelengthSize);

wavelength = BarnardMat.wavelength;
range = [0, 1];

end

function [matsumoto, wavelength, range] = MatsumotoSpectra(DataSetPath)

MatsumotoPath = [DataSetPath, 'matsumoto.mat'];
[matsumoto, wavelength] = LoadSignal(MatsumotoPath);
range = [0, 1];

end

function [westland, wavelength, range] = WestlandSpectra(DataSetPath)

WestlandPath = [DataSetPath, 'westland.mat'];
WestlandMat = load(WestlandPath);

WavelengthSize = size(WestlandMat.spectra, 1);
westland = WestlandMat.spectra';
westland = reshape(westland, size(westland, 1), 1, WavelengthSize);

wavelength = WestlandMat.wavelength;
range = [0, 100];

end

function [artist, wavelength, range] = ArtistSpectra(DataSetPath)

ArtistPath = [DataSetPath, 'artist_database.mat'];
ArtistMat = load(ArtistPath);

WavelengthSize = size(ArtistMat.spectra, 1);
artist = ArtistMat.spectra';
artist = reshape(artist, size(artist, 1), 1, WavelengthSize);

wavelength = ArtistMat.wavelength;
range = [0, 1];

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
