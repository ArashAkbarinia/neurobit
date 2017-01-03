function [  ] = PlotMetamersSpectraCrossOversAllPairs(ResultsFolder)
%PlotMetamersSpectraCrossOversAllPairs Summary of this function goes here
%   Detailed explanation goes here

SubFolders = GetSubFolders(ResultsFolder);
nCombinations = numel(SubFolders);

WhichLth = {0.5:0.5:1.5};
WhichUth = {4.5:6.5};

AllSpectraCrossovers = 0;
for s = 1:nCombinations
  CurrentSubFolder = [ResultsFolder, filesep, SubFolders{s}, filesep];
  if ~exist([CurrentSubFolder, 'AllIlluminantReport.mat'], 'file')
    disp([CurrentSubFolder, 'AllIlluminantReport. mat']);
    continue;
  end
  AllSpectraCrossovers = AllSpectraCrossovers + PlotMetamersSpectraCrossOversFolder(CurrentSubFolder, WhichLth, WhichUth, SubFolders{s});
end

sw = 400;
step = 10;
ew = 699;
WavelengthRange = sw:step:ew;
figure

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

