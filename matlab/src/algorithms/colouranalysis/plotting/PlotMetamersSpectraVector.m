function FigureHandler = PlotMetamersSpectraVector(AllSpectraCounter, AllSpectraMat, ResultsFolder)
%PlotMetamersSpectraVector Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2 || isempty(AllSpectraMat)
  FunctionPath = mfilename('fullpath');
  [~, FunctionName, ~] = fileparts(FunctionPath);
  FunctionRelativePath = ['matlab', filesep, 'src', filesep, 'algorithms', filesep, 'colouranalysis', filesep, 'plotting', filesep, FunctionName];
  
  MatDataPath = ['matlab', filesep, 'data', filesep, 'mats', filesep, 'hsi', filesep];
  AllSpectraMat = load(strrep(FunctionPath, FunctionRelativePath, [MatDataPath, 'AllSpectraUniformed.mat']));
end
if nargin < 3 || isempty(ResultsFolder)
  ResultsFolder = [];
  isvisible = 'on';
else
  isvisible = 'off';
end

SpectraMat = cell2mat(AllSpectraMat.spectra);
SpectraMat = permute(SpectraMat, [1, 3, 2]);
nWavelength = size(SpectraMat, 2);
AverageMetamerSignal = mean(SpectraMat .* repmat(AllSpectraCounter, [1, nWavelength]), 1);

% plotting the avreage metamers
uwave = AllSpectraMat.wavelength{1};
mall = mean(SpectraMat, 1); mall = mall ./ sum(mall);
mmet = AverageMetamerSignal ./ sum(AverageMetamerSignal);
mrat = mmet ./ mall; mrat = mrat ./ sum(mrat);

FigureHandler = figure('name', 'Average Metamer Spectra', 'visible', isvisible);
hold on;
title('Comparison of metamer spectra with original spectra');
plot(uwave, mall, 'color', 'red', 'DisplayName', 'original spectra');
plot(uwave, mmet, 'color', 'blue', 'DisplayName', 'metamer spectra');
plot(uwave, mrat, 'color', 'green', 'DisplayName', 'metamer ratio');
legend('show');
xlim([400, 700]);
if ~isempty(ResultsFolder)
  print(FigureHandler, [ResultsFolder, 'AverageMetamers.jpg'], '-djpeg', '-r0');
  close(FigureHandler);
end

end
