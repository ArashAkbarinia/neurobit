function AllSpectra = ReadSpectraData()
%ReadSpectraData  utility function to reads all spectra data we have

FunctionPath = mfilename('fullpath');
UefDataSetFolder = ['data', filesep, 'dataset', filesep, 'hsi', filesep, 'uef', filesep];
OthersDataSetFolder = ['data', filesep, 'dataset', filesep, 'hsi', filesep, 'others', filesep];
FunctionRelativePath = ['src', filesep, 'algorithms', filesep, 'colouranalysis', filesep, 'datareading', filesep, 'ReadSpectraData'];
UefDataSetPath = strrep(FunctionPath, ['matlab', filesep, FunctionRelativePath], UefDataSetFolder);
OthersDataSetPath = strrep(FunctionPath, ['matlab', filesep, FunctionRelativePath], OthersDataSetFolder);

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
[originals.artist, wavelengths.artist] = ArtistSpectra(OthersDataSetPath);

AllSpectra.originals = originals;
AllSpectra.wavelengths = wavelengths;

end

function [munsell, wavelength] = MunsellSpectra(DataSetPath)

MunsellPath = [DataSetPath, 'munsell380_780_1_glossy', filesep, 'munsell380_780_1_glossy.mat'];
MunsellMat = load(MunsellPath);

WavelengthSize = size(MunsellMat.glossy, 1);
munsell = MunsellMat.glossy';
munsell = reshape(munsell, size(munsell, 1), 1, WavelengthSize);

wavelength = MunsellMat.wavelength;

end

function [candy, wavelength] = CandySpectra(DataSetPath)

CandyPath = [DataSetPath, 'candy_matlab', filesep, 'candy_matlab.mat'];
CandyMat = load(CandyPath);

WavelengthSize = size(CandyMat.candy, 1);
candy = CandyMat.candy';
candy = reshape(candy, size(candy, 1), 1, WavelengthSize);

wavelength = CandyMat.wavelength;

end

function [agfa, wavelength] = AgfaitSpectra(DataSetPath)

AgfaitPath = [DataSetPath, 'agfait872', filesep, 'agfait872.mat'];
AgfaitMat = load(AgfaitPath);

WavelengthSize = size(AgfaitMat.agfa, 1);
agfa = AgfaitMat.agfa';
agfa = reshape(agfa, size(agfa, 1), 1, WavelengthSize);

wavelength = AgfaitMat.wavelength;

end

function [natural, wavelength] = NaturalSpectra(DataSetPath)

NaturalPath = [DataSetPath, 'natural400_700_5', filesep, 'natural400_700_5.mat'];
[natural, wavelength] = LoadSignal(NaturalPath);

end

function [forest, wavelength] = ForestSpectra(DataSetPath)

ForestPath = [DataSetPath, 'forest_matlab', filesep, 'forest_matlab.mat'];
[forest, wavelength] = LoadSignal(ForestPath);

end

function [lumber, wavelength] = LumberSpectra(DataSetPath)

LumberPath = [DataSetPath, 'lumber_matlab', filesep, 'lumber_matlab.mat'];
[lumber, wavelength] = LoadSignal(LumberPath);

end

function [paper, wavelength] = PaperSpectra(DataSetPath)

PaperPath = [DataSetPath, 'paper_matlab', filesep, 'paper_matlab.mat'];
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

function [artist, wavelength] = ArtistSpectra(DataSetPath)

ArtistPath = [DataSetPath, 'artist_database.mat'];
ArtistMat = load(ArtistPath);

WavelengthSize = size(ArtistMat.spectra, 1);
artist = ArtistMat.spectra';
artist = reshape(artist, size(artist, 1), 1, WavelengthSize);

wavelength = ArtistMat.wavelength;

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
