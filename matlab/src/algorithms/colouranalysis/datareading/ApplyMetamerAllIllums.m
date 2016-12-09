function [ ] = ApplyMetamerAllIllums(ResultFolder)
%ApplyMetamerAllIllums Summary of this function goes here
%   Detailed explanation goes here

FunctionPath = mfilename('fullpath');
[~, FunctionName, ~] = fileparts(FunctionPath);
FunctionRelativePath = ['matlab', filesep, 'src', filesep, 'algorithms', filesep, 'colouranalysis', filesep, 'datareading', filesep, FunctionName];

GenDataPath = ['data', filesep, 'dataset', filesep, 'hsi', filesep];
MatDataPath = ['matlab', filesep, 'data', filesep, 'mats', filesep, 'hsi', filesep];

if nargin < 1
  ResultFolder = strrep(FunctionPath, FunctionRelativePath, [GenDataPath, 'results', filesep, '1931']);
end

ArtLightsPath = strrep(FunctionPath, FunctionRelativePath, [GenDataPath, 'lights', filesep, 'ArtLights.mat']);
ArtIlluminantsMat = load(ArtLightsPath);

IlluminantstPath = strrep(FunctionPath, FunctionRelativePath, [MatDataPath, 'illuminants.mat']);
IlluminantsMat = load(IlluminantstPath);

FosterPath = strrep(FunctionPath, FunctionRelativePath, [MatDataPath, 'FosterIlluminants.mat']);
FosterIlluminantsMat = load(FosterPath);

DayLightsPath = strrep(FunctionPath, FunctionRelativePath, [GenDataPath, 'lights', filesep, 'DayLights.mat']);
DayIlluminantsMat = load(DayLightsPath);

for i = 1:4
  ApplyMetamerTest(ArtIlluminantsMat.wavelength, ArtIlluminantsMat.lights(:, i), ResultFolder, ['ArtLights', num2str(i), '.mat']);
end

ApplyMetamerTest(IlluminantsMat.wavelength, IlluminantsMat.a, ResultFolder, 'a.mat');
ApplyMetamerTest(IlluminantsMat.wavelength, IlluminantsMat.c, ResultFolder, 'c.mat');
ApplyMetamerTest(IlluminantsMat.wavelength, IlluminantsMat.d65, ResultFolder, 'd65.mat');
ApplyMetamerTest(FosterIlluminantsMat.wavelength, FosterIlluminantsMat.illum_25000, ResultFolder, 'illum_25000.mat');
ApplyMetamerTest(FosterIlluminantsMat.wavelength, FosterIlluminantsMat.illum_4000, ResultFolder, 'illum_4000.mat');

for i = 1:15
  ApplyMetamerTest(DayIlluminantsMat.wavelength, DayIlluminantsMat.sky(:, i), ResultFolder, ['sky', num2str(i), '.mat']);
end

end

function [] = ApplyMetamerTest(wavelength, spectra, FilePath, FileName)

disp(['Illumuninat ', FileName, ' is being processed.']);

MatResPath = [FilePath, filesep, 'metamers', filesep, FileName];
if exist(MatResPath, 'file')
  OldComptMat = load(MatResPath);
  OldComptMat = double(OldComptMat.CompMat);
else
  OldComptMat = [];
end

illuminant.wavelength = wavelength;
illuminant.spectra = spectra;
[CompMat, lab] = ColourDiffSpectraSamples([], illuminant, OldComptMat);
CompMat = single(triu(CompMat)); %#ok
save(MatResPath, 'CompMat');

car = reshape(lab.car, size(lab.car, 1), 3);
pol = cart2pol3(car(:, [2, 3, 1])); %#ok
wp = lab.wp;

save([FilePath, filesep, 'lab', filesep, FileName], 'car', 'pol', 'wp');

rgb = lab2rgb(reshape(car, size(car, 1), 1, 3), 'WhitePoint', wp);
rgb = uint8(min(max(rgb, 0), 1) .* 255);
[~, CurrentNames] = ColourNamingTestImage(rgb, 'ourlab', false); %#ok

save([FilePath, filesep, 'categorisation', filesep, 'arash', filesep, FileName], 'CurrentNames');

end
