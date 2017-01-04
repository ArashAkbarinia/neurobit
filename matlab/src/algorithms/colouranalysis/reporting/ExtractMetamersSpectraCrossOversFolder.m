function AllCrossOvers = ExtractMetamersSpectraCrossOversFolder(ResultsFolder, WhichLth, WhichUth, WhichDatasets)
%ExtractMetamersSpectraCrossOversFolder  extracting crossovers of all mat
%                                        files in a folder.

if nargin < 2 || isempty(WhichLth)
  WhichLth = num2cell(0.5:0.5:5);
end
if nargin < 3 || isempty(WhichUth)
  WhichUth = num2cell(0.5:1:20.5);
end
if nargin < 4
  WhichDatasets = [];
end

MatList = dir([ResultsFolder, 'CrossOversReport*.mat']);
ExcludeInds = false(length(MatList), 1);
for i = 1:numel(WhichDatasets)
  ExcludeInds = ExcludeInds | arrayfun(@(x)strcmpi(x.name, ['CrossOversReport', WhichDatasets{i}, '.mat']), MatList);
end
MatList = MatList(~ExcludeInds);
nfiles = length(MatList);

nlths = numel(WhichLth);
nuths = numel(WhichUth);

AllCrossOvers = [];
for i = 1:nfiles
  CurrentFileName = MatList(i).name;
  MatPath = [ResultsFolder, CurrentFileName];
  CrossOversMat = load(MatPath);
  
  for l = 1:nlths
    for u = 1:nuths
      AllCrossOvers = [AllCrossOvers; ExtractMetamersSpectraCrossOvers(CrossOversMat.CrossOversReport, WhichLth{l}, WhichUth{u})]; %#ok
    end
  end
end

end
