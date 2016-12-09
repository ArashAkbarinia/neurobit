function [ ] = ApplyMetamerAllIllums(ResultFolder)
%ApplyMetamerAllIllums Summary of this function goes here
%   Detailed explanation goes here

if nargin < 1
  ResultFolder = '/home/arash/Documents/Software/repositories/neurobit/data/dataset/hsi/results/1931';
end

FunctionPath = mfilename('fullpath');
FunctionRelativePath = 'matlab/src/algorithms/colouranalysis/datareading/ApplyMetamerAllIllums';

ArtLightsPath = strrep(FunctionPath, FunctionRelativePath, 'data/dataset/hsi/lights/ArtLights.mat');
ArtIlluminantsMat = load(ArtLightsPath);

IlluminantstPath = strrep(FunctionPath, FunctionRelativePath, 'matlab/data/mats/hsi/illuminants.mat');
IlluminantsMat = load(IlluminantstPath);

FosterPath = strrep(FunctionPath, FunctionRelativePath, 'matlab/data/mats/hsi/FosterIlluminants.mat');
FosterIlluminantsMat = load(FosterPath);

DayLightsPath = strrep(FunctionPath, FunctionRelativePath, 'data/dataset/hsi/lights/DayLights.mat');
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

illuminant.wavelength = wavelength;
illuminant.spectra = spectra;
[MetamerMats, lab] = MetamerTestSpectraSamples([], illuminant);
CompMat = single(triu(MetamerMats.nfall.m2000.CompMat)); %#ok
save([FilePath, '/metamers/', FileName], 'CompMat');

car = reshape(lab.car, size(lab.car, 1), 3);
pol = cart2pol3(car(:, [2, 3, 1])); %#ok
wp = lab.wp; %#ok

save([FilePath, '/lab/', FileName], 'car', 'pol', 'wp');

end
