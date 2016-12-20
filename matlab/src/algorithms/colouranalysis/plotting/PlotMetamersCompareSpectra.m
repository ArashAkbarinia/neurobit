function [AllSpectraCounter, AverageMetamerSignal] = PlotMetamersCompareSpectra(MetamerReport, ResultsFolder, WhichLth, WhichUth, WhichData)
%PlotCompareSpectra Summary of this function goes here
%   Detailed explanation goes here

if nargin < 5
  WhichData = [];
end
if nargin < 4
  WhichUth = [];
end
if nargin < 3
  WhichLth = [];
end

FunctionPath = mfilename('fullpath');
[~, FunctionName, ~] = fileparts(FunctionPath);
FunctionRelativePath = ['matlab', filesep, 'src', filesep, 'algorithms', filesep, 'colouranalysis', filesep, 'plotting', filesep, FunctionName];

MatDataPath = ['matlab', filesep, 'data', filesep, 'mats', filesep, 'hsi', filesep];
AllSpectraMat = load(strrep(FunctionPath, FunctionRelativePath, [MatDataPath, 'AllSpectraUniformed.mat']));

ThresholdNames = fieldnames(MetamerReport.all.lths);
nLowThreshes = numel(ThresholdNames);

nHighThreshes = numel(fieldnames(MetamerReport.all.lths.th1.uths));

if isempty(WhichData)
  SpectraInds = 1:MetamerReport.all.NumElements;
else
  CatNames = fieldnames(AllSpectraMat.AllSpectra.originals);
  ncategories = numel(CatNames);
  CatEls = zeros(ncategories, 1);
  for i = 1:ncategories
    CatEls(i) = size(AllSpectraMat.AllSpectra.originals.(CatNames{i}), 1);
  end
  CatEls = cumsum(CatEls);
  SpectraInds = [];
  
  % only the selected datasets
  NewSpectraMat = struct();
  NewSpectraMat.spectra = {};
  NewSpectraMat.wavelength = {};
  for i = 1:numel(WhichData)
    name = WhichData{i};
    NewSpectraMat.AllSpectra.originals.(name) = AllSpectraMat.AllSpectra.originals.(name);
    NewSpectraMat.AllSpectra.wavelengths.(name) = AllSpectraMat.AllSpectra.wavelengths.(name);
    NewSpectraMat.spectra = [NewSpectraMat.spectra; num2cell(NewSpectraMat.AllSpectra.originals.(name), 3)];
    NewSpectraMat.wavelength = [NewSpectraMat.wavelength; num2cell(repmat(NewSpectraMat.AllSpectra.wavelengths.(name), [size(NewSpectraMat.AllSpectra.originals.(name), 1), 1]), 2)];
    [~, NameInd] = ismember(name, CatNames);
    if NameInd == 1
      StartInd = 1;
    else
      StartInd = CatEls(NameInd - 1, 1) + 1;
    end
    SpectraInds = [SpectraInds, StartInd:CatEls(NameInd, 1)]; %#ok
  end
  
  AllSpectraMat = NewSpectraMat;
  SpectraInds = SpectraInds';
end

AllSpectraCounter = 0;
for i = 1:nLowThreshes
  LowThreshold = MetamerReport.all.lths.(ThresholdNames{i});
  if isempty(WhichLth) || ismember(LowThreshold.lth, WhichLth)
    for j = 1:nHighThreshes
      HighThreshold = LowThreshold.uths.(['uth', num2str(j)]);
      if isempty(WhichUth) || ismember(HighThreshold.uth, WhichUth)
        SpectraCounter = HighThreshold.SpectraCounter(SpectraInds, :);
        AllSpectraCounter = AllSpectraCounter + SpectraCounter;
      end
    end
  end
end
AllSpectraCounter = double(AllSpectraCounter);

PlotMetameristSpectraReflectance(AllSpectraCounter, AllSpectraMat, ResultsFolder);

SpectraMat = cell2mat(AllSpectraMat.spectra);
SpectraMat = permute(SpectraMat, [1, 3, 2]);
nWavelength = size(SpectraMat, 2);
AverageMetamerSignal = mean(SpectraMat .* repmat(AllSpectraCounter, [1, nWavelength]), 1);

PlotMetamersSpectraVector(AllSpectraCounter, AllSpectraMat, [ResultsFolder, filesep]);

end

function [] = PlotMetameristSpectraReflectance(SpectraCounter, AllSpectra, ResultsFolder)

CatNames = fieldnames(AllSpectra.AllSpectra.originals);
ncategories = numel(CatNames);
CatEls = zeros(ncategories, 1);
for i = 1:ncategories
  CatEls(i) = size(AllSpectra.AllSpectra.originals.(CatNames{i}), 1);
end
CatEls = cumsum(CatEls);

SpectraCounter = double(SpectraCounter);

[~, SortedInds] = sort(SpectraCounter, 'descend');

RelativeSpectraCounter = SpectraCounter ./ max(SpectraCounter);

FigPos = [0, 0, 50, 25];
isvisible = 'off';

FigureHandler = figure('name', 'Top metamerist reflectances', 'PaperUnits', 'centimeters', 'PaperPosition', FigPos, 'visible', isvisible);
ColourMapInds = colormap('jet');
hold on;

nSpectraPlot = 50;
nTopSpectraPlot = min(nSpectraPlot, size(SpectraCounter, 1));
for i = 1:nTopSpectraPlot
  row = SortedInds(i);
  PlotOneSignal(AllSpectra, row, CatNames, ColourMapInds, CatEls, RelativeSpectraCounter);
end
xlim([400, 700]);
legend('show', 'location', 'westoutside');
title(['Top metamers, ratios scaled from ', num2str(max(SpectraCounter))]);
print(FigureHandler, [ResultsFolder, filesep, 'TopMetamers.jpg'], '-djpeg', '-r0')
close(FigureHandler);

% plotting the zero metamers
FigureHandler = figure('name', 'Bottom metamerist reflectances', 'PaperUnits', 'centimeters', 'PaperPosition', FigPos, 'visible', isvisible);
hold on;
ZeroMetamers = find(SpectraCounter == 0);
ZeroMetamers = ZeroMetamers(1:min(nSpectraPlot, size(ZeroMetamers, 1)));
for i = ZeroMetamers'
  row = i;
  PlotOneSignal(AllSpectra, row, CatNames, ColourMapInds, CatEls, RelativeSpectraCounter);
end
xlim([400, 700]);
legend('show', 'location', 'westoutside');
title('Bottom metamers (all 0 ones)');
print(FigureHandler, [ResultsFolder, filesep, 'BottomMetamers.jpg'], '-djpeg', '-r0')
close(FigureHandler);

end

function [] = PlotOneSignal(AllSpectra, row, CatNames, ColourMapInds, CatEls, RelativeSpectraCounter)

wavelength1 = AllSpectra.wavelength{row, :};
signal1 = AllSpectra.spectra{row, :, :};

signal1 = reshape(signal1, size(signal1, 3), 1);

CategoryInd = find(row < CatEls, 1);
CurrentDisplayName = ['Dataset: ', CatNames{CategoryInd}, ' [', num2str(RelativeSpectraCounter(row)), ']'];

cind = round(RelativeSpectraCounter(row) * size(ColourMapInds, 1));
cind = max(cind, 1);
plot(wavelength1, signal1, 'color', ColourMapInds(cind, :), 'DisplayName', CurrentDisplayName);

end
