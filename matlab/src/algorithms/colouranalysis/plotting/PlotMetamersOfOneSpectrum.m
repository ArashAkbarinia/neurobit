function MetamerPairsSpectrumReport = PlotMetamersOfOneSpectrum(SpectrumIndex, ResultsFolder, WhichLth, WhichUth, LabFolder)
%PlotMetamersOfOneSpectrum Summary of this function goes here
%   Detailed explanation goes here

if nargin < 5
  LabFolder = [];
end
if nargin < 4
  WhichUth = [];
end
if nargin < 3
  WhichLth = [];
end

SubFolders = GetSubFolders(ResultsFolder);
nCombinations = numel(SubFolders);
c = -nCombinations * 2;
nIllums = (1 + sqrt(1 - 4 * c)) / 2;

MetamerReportMat = load([ResultsFolder, filesep, SubFolders{1}, filesep, 'AllIlluminantReport']);
MetamerReport = MetamerReportMat.MetamerReport;

ThresholdNames = fieldnames(MetamerReport.all.lths);
nLowThreshes = numel(ThresholdNames);
nHighThreshes = numel(fieldnames(MetamerReport.all.lths.th1.uths));

if isempty(LabFolder)
  LabFolder = strrep(ResultsFolder, ['reports', filesep, 'illuminantpairs'], ['lab', filesep]);
end
LabMats = struct();

LastIllumIndx = 1;
IllumNamesOrder = cell(nIllums, 1);

nSpectrum = length(SpectrumIndex);
MetamerPairsSpectrumReport = cell(nSpectrum, 9);

for i = 1:nSpectrum
  MetamerPairsSpectrumReport{i, 1}.metamerpairs = cell(nIllums, nIllums);
  MetamerPairsSpectrumReport{i, 1}.deltaes = cell(nIllums, nIllums);
end

for s = 1:nCombinations
  CurrentSubFolder = [ResultsFolder, filesep, SubFolders{s}, filesep];
  if ~exist([CurrentSubFolder, 'AllIlluminantReport.mat'], 'file')
    disp([CurrentSubFolder, 'AllIlluminantReport. mat']);
    continue;
  end
  disp(['Processing: ', SubFolders{s}]);
  
  MetamerReportMat = load([CurrentSubFolder, 'AllIlluminantReport']);
  MetamerReport = MetamerReportMat.MetamerReport;
  
  % checking to see if the illuminant exist
  CurrentIllums = MetamerReport.illuminants;
  il1 = find(strcmp(IllumNamesOrder, CurrentIllums{1}));
  if isempty(il1)
    LabMats.(CurrentIllums{1}) = load([LabFolder, CurrentIllums{1}]);
    IllumNamesOrder{LastIllumIndx} = CurrentIllums{1};
    il1 = LastIllumIndx;
    LastIllumIndx = LastIllumIndx + 1;
  end
  il2 = find(strcmp(IllumNamesOrder, CurrentIllums{2}));
  if isempty(il2)
    LabMats.(CurrentIllums{2}) = load([LabFolder, CurrentIllums{2}]);
    IllumNamesOrder{LastIllumIndx} = CurrentIllums{2};
    il2 = LastIllumIndx;
    LastIllumIndx = LastIllumIndx + 1;
  end
  
  for i = 1:nLowThreshes
    LowThreshold = MetamerReport.all.lths.(ThresholdNames{i});
    if LowThreshold.lth == WhichLth
      for j = 1:nHighThreshes
        HighThreshold = LowThreshold.uths.(['uth', num2str(j)]);
        if HighThreshold.uth == WhichUth
          break;
        else
          HighThreshold = [];
        end
      end
    end
  end
  
  if isempty(HighThreshold)
    error('These thresholds are not found');
  end
  CurrentPairs = HighThreshold.metamerpairs;
  
  for o = 1:nSpectrum
    CurrentPairsInds = any(CurrentPairs == SpectrumIndex{o}, 2);
    CurrentPairsSel = CurrentPairs(CurrentPairsInds, :);
    CurrentPairsSel = CurrentPairsSel(:);
    CurrentPairsSel = unique(CurrentPairsSel(CurrentPairsSel ~= SpectrumIndex{o}));
    MetamerPairsSpectrumReport{o, 1}.metamerpairs{il1, il2} = CurrentPairsSel;
    MetamerPairsSpectrumReport{o, 1}.metamerpairs{il2, il1} = CurrentPairsSel;
    
    lab1 = LabMats.(CurrentIllums{1}).car;
    lab2 = LabMats.(CurrentIllums{2}).car;
    CurrentSpecrumRow = repmat(SpectrumIndex{o}, [length(CurrentPairsSel), 1]);
    de1 = deltae2000(lab1(CurrentSpecrumRow, :), lab1(CurrentPairsSel, :));
    de2 = deltae2000(lab2(CurrentSpecrumRow, :), lab2(CurrentPairsSel, :));
    deltaes = min(de1, de2);
    MetamerPairsSpectrumReport{o, 1}.deltaes{il1, il2} = deltaes;
    MetamerPairsSpectrumReport{o, 1}.deltaes{il2, il1} = deltaes;
  end
end

for o = 1:nSpectrum
  for i = 1:nIllums - 1
    for j = i:nIllums
      MetamerPairsSpectrumReport{o, 2} = [MetamerPairsSpectrumReport{o, 2}; MetamerPairsSpectrumReport{o, 1}.metamerpairs{i, j}];
      MetamerPairsSpectrumReport{o, 3} = [MetamerPairsSpectrumReport{o, 3}; MetamerPairsSpectrumReport{o, 1}.deltaes{i, j}];
    end
  end
end

for o = 1:nSpectrum
  MetamerPairsSpectrumReport{o, 4} = length(MetamerPairsSpectrumReport{o, 2});
  MetamerPairsSpectrumReport{o, 5} = mean(MetamerPairsSpectrumReport{o, 3});
  MetamerPairsSpectrumReport{o, 6} = std(MetamerPairsSpectrumReport{o, 3});
  
  CurrentUniqueMetamers = unique(MetamerPairsSpectrumReport{o, 2});
  MetamerPairsSpectrumReport{o, 7} = length(CurrentUniqueMetamers);
  MetamerPairsSpectrumReport{o, 8} = mean(CurrentUniqueMetamers);
  MetamerPairsSpectrumReport{o, 9} = std(CurrentUniqueMetamers);
end

end
