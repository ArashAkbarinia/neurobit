function [  ] = PlotMetamersSpectraCrossOversAllPairs(ResultsFolder, WhichDatasets, SelectedIllums, isInclude, WhichLth, WhichUth)
%PlotMetamersSpectraCrossOversAllPairs Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2 || isempty(WhichDatasets)
  WhichDatasets = {'', 'barnard'};
end
if nargin < 3 || isempty(SelectedIllums)
  SelectedIllums = [];
end
if nargin < 4 || isempty(isInclude)
  isInclude = true;
end
if nargin < 5 || isempty(WhichLth)
  WhichLth = {[]};
end
if nargin < 6 || isempty(WhichUth)
  WhichUth = {[]};
end

SubFolders = GetSubFolders(ResultsFolder);
nCombinations = numel(SubFolders);

if ~isempty(WhichDatasets)
  AllSpectraCrossovers = [];
else
  AllSpectraCrossovers = 0;
end
for s = 1:nCombinations
  CurrentSubFolder = [ResultsFolder, SubFolders{s}, filesep];
  if ~exist([CurrentSubFolder, 'AllIlluminantReport.mat'], 'file')
    disp([CurrentSubFolder, 'AllIlluminantReport. mat']);
    continue;
  elseif ~isempty(SelectedIllums)
    MetamerReportMat = load([CurrentSubFolder, 'AllIlluminantReport.mat']);
    CurrentIlluminants = MetamerReportMat.MetamerReport.illuminants;
    BreakFor = isInclude;
    for i = 1:numel(SelectedIllums)
      if strcmpi(CurrentIlluminants{1}, SelectedIllums{i}) || ...
          strcmpi(CurrentIlluminants{2}, SelectedIllums{i})
        BreakFor = ~isInclude;
        break;
      end
    end
    if BreakFor
      continue;
    end
  end
  
  disp(['Processing: ', SubFolders{s}]);
  
  if ~isempty(WhichDatasets)
    CurrentCrossOvers = ExtractMetamersSpectraCrossOversFolder(CurrentSubFolder, WhichLth, WhichUth, WhichDatasets);
    AllSpectraCrossovers = [AllSpectraCrossovers; CurrentCrossOvers]; %#ok
  else
    [CurrentCrossOvers, ~] = PlotMetamersSpectraCrossOversFolder(CurrentSubFolder, WhichLth, WhichUth, SubFolders{s});
    AllSpectraCrossovers = AllSpectraCrossovers + CurrentCrossOvers;
  end
end

sw = 400;
step = 10;
ew = 709;
WavelengthRange = sw:step:ew;
figure

if ~isempty(WhichDatasets)
  PlotMetamersSpectraCrossOvers(AllSpectraCrossovers);
else
  MatList = dir([ResultsFolder, filesep, SubFolders{s}, filesep, 'CrossOversReport*.mat']);
  nfiles = length(MatList);
  rows = round(sqrt(nfiles));
  cols = ceil(sqrt(nfiles));
  for i = 1:nfiles
    CurrentFileName = MatList(i).name;
    
    subplot(rows, cols, i); hold on;
    AllSpectraCrossovers(i, :) = AllSpectraCrossovers(i, :) ./ sum(AllSpectraCrossovers(i, :)); %#ok
    plot(WavelengthRange(1:end - 1), AllSpectraCrossovers(i, :));
    xlim([sw, ew]);
    TilteName = strrep(CurrentFileName, 'CrossOversReport', '');
    TilteName = strrep(TilteName, '.mat', '');
    if isempty(TilteName)
      TilteName = 'all';
    end
    title(TilteName);
  end
end

end
