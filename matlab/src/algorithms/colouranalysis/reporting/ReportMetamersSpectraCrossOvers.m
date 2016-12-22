function CrossOversReport = ReportMetamersSpectraCrossOvers(MetamerReport, WhichData)
%ReportMetamersSpectraCrossOvers Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
  WhichData = [];
end

FunctionPath = mfilename('fullpath');
[~, FunctionName, ~] = fileparts(FunctionPath);
FunctionRelativePath = ['matlab', filesep, 'src', filesep, 'algorithms', filesep, 'colouranalysis', filesep, 'reporting', filesep, FunctionName];

DataPath = ['matlab', filesep, 'data', filesep, 'mats', filesep, 'hsi', filesep];

AllSpectraPath = strrep(FunctionPath, FunctionRelativePath, [DataPath, 'AllSpectraUniformed.mat']);
AllSpectraMat = load(AllSpectraPath);

ThresholdNames = fieldnames(MetamerReport.all.lths);
nLowThreshes = numel(ThresholdNames);
nHighThreshes = numel(fieldnames(MetamerReport.all.lths.th1.uths));

% handling which data
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
  for i = 1:numel(WhichData)
    name = WhichData{i};
    [~, NameInd] = ismember(name, CatNames);
    if NameInd == 1
      StartInd = 1;
    else
      StartInd = CatEls(NameInd - 1, 1) + 1;
    end
    SpectraInds = [SpectraInds, StartInd:CatEls(NameInd, 1)]; %#ok
  end
  
  SpectraInds = SpectraInds';
end

TmpReport = struct();
AllCrossOvers = [];
for i = 1:nLowThreshes
  LowThreshold = MetamerReport.all.lths.(ThresholdNames{i});
  TmpReport.(ThresholdNames{i}).lth = LowThreshold.lth;
  for j = 1:nHighThreshes
    HighThreshold = LowThreshold.uths.(['uth', num2str(j)]);
    MetamerPairs = HighThreshold.metamerpairs;
    MetamerPairs = MetamerPairs(any(ismember(MetamerPairs, SpectraInds), 2), :);
    [xi, yi] = ComputeCorssOverPerPair(MetamerPairs, AllSpectraMat.spectra, AllSpectraMat.wavelength);
    TmpReport.(ThresholdNames{i}).uths.(['uth', num2str(j)]).uth = HighThreshold.uth;
    TmpReport.(ThresholdNames{i}).uths.(['uth', num2str(j)]).crossovers = [xi, yi];
    AllCrossOvers = [AllCrossOvers; xi, yi]; %#ok
  end
end

CrossOversReport.all.lths = TmpReport;
CrossOversReport.all.crossovers = AllCrossOvers;

end
