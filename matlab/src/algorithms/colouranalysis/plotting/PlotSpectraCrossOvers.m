function [xs, ys] = PlotSpectraCrossOvers(MetamerReport)
%PlotSpectraCrossOvers Summary of this function goes here
%   Detailed explanation goes here

FunctionPath = mfilename('fullpath');
[~, FunctionName, ~] = fileparts(FunctionPath);
FunctionRelativePath = ['matlab', filesep, 'src', filesep, 'algorithms', filesep, 'colouranalysis', filesep, 'plotting', filesep, FunctionName];

DataPath = ['matlab', filesep, 'data', filesep, 'mats', filesep, 'hsi', filesep];

AllSpectraPath = strrep(FunctionPath, FunctionRelativePath, [DataPath, 'AllSpectraNormalised.mat']);
AllSpectraMat = load(AllSpectraPath);

spectras = AllSpectraMat.spectra;
wavelengths = AllSpectraMat.wavelength;
clear AllSpectraMat;

ThresholdNames = fieldnames(MetamerReport.all.lths);
nLowThreshes = numel(ThresholdNames);

nHighThreshes = numel(fieldnames(MetamerReport.all.lths.th1.uths));

xs = [];
ys = [];

% TODO: too slow, fix it
for i = 1:nLowThreshes
  LowThreshold = MetamerReport.all.lths.(ThresholdNames{i});
  for j = 1:nHighThreshes
    HighThreshold = LowThreshold.uths;
    MetamerPairs = HighThreshold.(['uth', num2str(j)]).metamerpairs;
    [xi, yi] = ComputeCorssOverPerPair(MetamerPairs, spectras, wavelengths);
    xs = [xs; xi]; %#ok
    ys = [ys; yi]; %#ok
  end
end

end

function [xs, ys] = ComputeCorssOverPerPair(MetamerPairs, spectras, wavelengths)

xs = [];
ys = [];
for i = 1:size(MetamerPairs, 1)
  row = MetamerPairs(i, 1);
  col = MetamerPairs(i, 2);
  
  % fetching the spectra
  spectra1 = spectras{row};
  spectra1 = reshape(spectra1, size(spectra1, 3), 1);
  spectra1 = spectra1 ./ max(spectra1);
  spectra2 = spectras{col};
  spectra2 = reshape(spectra2, size(spectra2, 3), 1);
  spectra2 = spectra2 ./ max(spectra2);
  
  [xi, yi] = CorssOverSpectra(spectra1, wavelengths{row}, spectra2, wavelengths{col});
  xs = [xs; xi]; %#ok
  ys = [ys; yi]; %#ok
end

end