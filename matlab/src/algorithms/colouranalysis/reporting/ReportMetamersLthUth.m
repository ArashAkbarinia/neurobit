function LthUthReport = ReportMetamersLthUth(MetamerReport, plotme)
%ReportMetamersLthUth Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
  plotme = false;
end

ThresholdNames = fieldnames(MetamerReport.all.lths);
nLowThreshes = numel(ThresholdNames);
nHighThreshes = numel(fieldnames(MetamerReport.all.lths.th1.uths));

FunctionPath = mfilename('fullpath');
[~, FunctionName, ~] = fileparts(FunctionPath);
FunctionRelativePath = ['matlab', filesep, 'src', filesep, 'algorithms', filesep, 'colouranalysis', filesep, 'reporting', filesep, FunctionName];

DataPath = ['matlab', filesep, 'data', filesep, 'mats', filesep, 'hsi', filesep];

AllSpectraPath = strrep(FunctionPath, FunctionRelativePath, [DataPath, 'AllSpectraUniformed.mat']);
AllSpectraMat = load(AllSpectraPath);

CatNames = fieldnames(MetamerReport);

for c = 1:numel(CatNames)
  name = CatNames{c};
  if strcmpi(name, 'illuminants')
    continue;
  end
  
  if strcmpi(name, 'all')
    [LowHighPer, LowHighAbs, lths, uths] = ExtractDatasetLthUth(nLowThreshes, nHighThreshes, MetamerReport, name, ThresholdNames);
  else
    [LowHighPer, LowHighAbs, lths, uths] = ExtractSpectraLthUth(nLowThreshes, nHighThreshes, MetamerReport, name, ThresholdNames, AllSpectraMat);
  end
  
  LthUthReport.(name).LowHighPer = LowHighPer;
  LthUthReport.(name).LowHighAbs = LowHighAbs;
  LthUthReport.(name).lths = lths;
  LthUthReport.(name).uths = uths;
  
  if plotme
    LthUthReport.(name).FigureNumber = figure;
    imagesc(LowHighPer);
    colormap('gray');
    colorbar;
    set(gca, 'XTickLabel', lths);
    set(gca, 'XTick', 1:nLowThreshes);
    set(gca, 'YTickLabel', fliplr(uths));
    set(gca, 'YTick', 1:nHighThreshes);
    xlabel('Low Threshold');
    ylabel('High Threshold');
    title(name);
  end
  
end

end

function [LowHighPer, LowHighAbs, lths, uths] = ExtractDatasetLthUth(nLowThreshes, nHighThreshes, MetamerReport, name, ThresholdNames)

LowHighPer = zeros(nHighThreshes, nLowThreshes);
LowHighAbs = zeros(nHighThreshes, nLowThreshes);
lths = zeros(1, nLowThreshes);
uths = zeros(1, nHighThreshes);

for i = 1:nLowThreshes
  LowThreshold = MetamerReport.(name).lths.(ThresholdNames{i});
  lths(1, i) = LowThreshold.lth;
  for j = 1:nHighThreshes
    HighThreshold = LowThreshold.uths.(['uth', num2str(j)]);
    if i == 1
      uths(1, j) = HighThreshold.uth;
    end
    LowHighPer(nHighThreshes - j + 1, i) = HighThreshold.metamerper;
    LowHighAbs(nHighThreshes - j + 1, i) = HighThreshold.metamernum;
  end
end

end

function [LowHighPer, LowHighAbs, lths, uths] = ExtractSpectraLthUth(nLowThreshes, nHighThreshes, MetamerReport, name, ThresholdNames, AllSpectraMat)

SpectraInds = ExtractDatasetIndices(MetamerReport.all, AllSpectraMat.AllSpectra, {name});
nInds = size(SpectraInds, 1);
nAll = MetamerReport.all.NumElements - 1;

LowHighPer = zeros(nHighThreshes, nLowThreshes);
LowHighAbs = zeros(nHighThreshes, nLowThreshes);
lths = zeros(1, nLowThreshes);
uths = zeros(1, nHighThreshes);

for i = 1:nLowThreshes
  LowThreshold = MetamerReport.all.lths.(ThresholdNames{i});
  lths(1, i) = LowThreshold.lth;
  for j = 1:nHighThreshes
    HighThreshold = LowThreshold.uths.(['uth', num2str(j)]);
    if i == 1
      uths(1, j) = HighThreshold.uth;
    end
    SpectraCounter = HighThreshold.SpectraCounter(SpectraInds);
    metamernum = sum(SpectraCounter);
    metamerper = metamernum / (nInds * nAll);
    LowHighPer(nHighThreshes - j + 1, i) = metamerper;
    LowHighAbs(nHighThreshes - j + 1, i) = metamernum;
  end
end

end
