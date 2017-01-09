function [ ] = ApplyMetamerAllIllums(ResultFolder, IllumNames)
%ApplyMetamerAllIllums Summary of this function goes here
%   Detailed explanation goes here

FunctionPath = mfilename('fullpath');
[~, FunctionName, ~] = fileparts(FunctionPath);
FunctionRelativePath = ['matlab', filesep, 'src', filesep, 'algorithms', filesep, 'colouranalysis', filesep, 'datareading', filesep, FunctionName];

GenDataPath = ['data', filesep, 'dataset', filesep, 'hsi', filesep];

if nargin < 1 || isempty(ResultFolder)
  ResultFolder = strrep(FunctionPath, FunctionRelativePath, [GenDataPath, 'results', filesep, '1931']);
end

IlluminantsPath = strrep(FunctionPath, FunctionRelativePath, ['matlab', filesep, 'data', filesep, 'mats', filesep, 'hsi', filesep, 'AllIlluminants.mat']);
AllIlluminants = load(IlluminantsPath);

if nargin < 2
  IllumNames = fieldnames(AllIlluminants.spectras);
end

for i = 1:numel(IllumNames)
  CurrentLabel = IllumNames{i};
  ApplyMetamerTest(AllIlluminants.wavelengths.(CurrentLabel), AllIlluminants.spectras.(CurrentLabel), ResultFolder, CurrentLabel);
end

end

function [] = ApplyMetamerTest(wavelength, spectra, FilePath, FileName)

disp(['Illumuninat ', FileName, ' is being processed.']);

MatResPath = [FilePath, filesep, 'metamers', filesep, FileName, '.mat'];
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
% I set these values (0.25 and 1.55) based on the spectra reflectance of
% munsell chart. Apparently the dark objects don't work very good with
% spectrameters.
rgb = min(max(rgb, 0.25), 1.55);
rgb = uint8(NormaliseChannel(rgb, 0, 1, min(min(rgb)), max(max(rgb))) .* 255);
[~, CurrentNames] = ColourNamingTestImage(rgb, 'ourlab', false); %#ok

save([FilePath, filesep, 'categorisation', filesep, 'ellipsoid', filesep, FileName], 'CurrentNames');

end
