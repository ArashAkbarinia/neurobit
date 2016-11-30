function MetamerReport = ReportResultsPerIlluminant( FolderPath )
%ReportResultsPerIlluminant  generates reports from the metamers results.
%

MetamerReport = struct();

if nargin < 1
  FolderPath = '/home/arash/Documents/Software/repositories/neurobit/data/dataset/hsi/results/1931/';
end

MetamerPath = [FolderPath, 'metamers'];
CategorPath = [FolderPath, 'categorisation'];
LabCaPoPath = [FolderPath, 'lab'];
ReportsPath = [FolderPath, 'reports'];

MatList = dir([MetamerPath, '/*.mat']);
nfiles = length(MatList);
nthreshes = 4;
th = 0.5;

CatEls = [1600, 21, 289, 182, 1056, 272, 803, 3283, 2323, 702, 339, 404];
CatNames = {'Munsell', 'Candy', 'Agfa', 'Natural', 'Forest', 'Lumber', 'Paper', 'Cambridge', 'Flowers', 'Barnard', 'Matsumoto', 'Westland'};

for i = 7:7 % 1:nfiles
  disp(['Processing: ', MatList(i).name]);
  CurrentMat = load([MetamerPath, '/', MatList(i).name]);
  fileid = fopen([ReportsPath, '/', MatList(i).name(1:end - 3), 'txt'], 'w');
  MetamerReport.all = CategoryReport(fileid, CurrentMat.CompMat, th, nthreshes, 'All');

  si = 1;
  for k = 1:numel(CatNames)
    ei = CatEls(k) + si - 1;
    inds = si:ei;
    MetamerReport.(lower(CatNames{k})) = CategoryReport(fileid, CurrentMat.CompMat(inds, inds), th, nthreshes, CatNames{k});
    si = si + CatEls(k);
  end
  fclose(fileid);
end

end

function MetamerReport = CategoryReport(fileid, CompMat, th, nthreshes, pretext)

% 9 is the length of largest text which is cambridge
if numel(pretext) < 9
  pretext = [pretext, zeros(1, 9 - numel(pretext))];
end

MetamerReport = struct();

[rows, cols] = size(CompMat);
nPixels = rows * (cols - 1) / 2;
CompMat = CompMat(CompMat > 0);

MetamerReport.NumElements = rows;

for j = 0:nthreshes
  CurrentThreshold = th * (2 ^ j);
  AbsoluteMetamers = sum(CompMat < CurrentThreshold);
  fprintf(fileid, ' (%s)\tth %.1f:\t%f percent metamers (num elements %d)\n', pretext, CurrentThreshold, AbsoluteMetamers / nPixels, rows);
  MetamerReport.(['th', num2str(j)]).('th') = CurrentThreshold;
  MetamerReport.(['th', num2str(j)]).('metamernum') = AbsoluteMetamers;
  MetamerReport.(['th', num2str(j)]).('metamerper') = AbsoluteMetamers / nPixels;
end

end
