function MetamerReport = MetamerAllIlluminants( FolderPath )
%MetamerAllIlluminants  generates the metamer reports based on all illums.
%   Detailed explanation goes here

MetamerReport = struct();

if nargin < 1
  FolderPath = '/home/arash/Documents/Software/repositories/neurobit/data/dataset/hsi/results/1931/';
end

MetamerPath = [FolderPath, 'metamers'];
CategorPath = [FolderPath, 'categorisation'];
LabCaPoPath = [FolderPath, 'lab'];
ReportsPath = [FolderPath, 'reports'];
AllSpectraMat = load([FolderPath, 'signals/AllSpectra.mat']);
AllSpectra = AllSpectraMat.AllSpectra;

MatList = dir([MetamerPath, '/*.mat']);
nfiles = length(MatList);
nthreshes = 3;
lth = 0.5;
uth = [5, 10];
% 0 means nothing, 1 means plot, 2 means save
plotme = 2;

CatEls = [1600, 21, 289, 182, 1056, 272, 803, 3283, 2323, 702, 339, 404];
CatNames = {'Munsell', 'Candy', 'Agfa', 'Natural', 'Forest', 'Lumber', 'Paper', 'Cambridge', 'Flowers', 'Barnard', 'Matsumoto', 'Westland'};

for i = 1:nfiles
  disp(['reading: ', MatList(i).name]);
  CurrentDif = load([MetamerPath, '/', MatList(i).name]);
  
  % some tricks to get the upper part of the matrix only
  CurrentDif.CompMat = CurrentDif.CompMat - tril(ones(size(CurrentDif.CompMat)));
  
  CompDiff(:, :, i) = CurrentDif.CompMat; %#ok
  
  CurrentLab = load([LabCaPoPath, '/', MatList(i).name]);
  LabPoint.car(:, :, i) = CurrentLab.car(10531:end, :); 
  LabPoint.wp(i, :) = CurrentLab.wp;
end

clear CurrentDif;

disp('Starting to process:');

if plotme == 2
  fileid = fopen([ReportsPath, '/', 'AllAnalysis.txt'], 'w');
else
  fileid = 1;
end
MetamerReport.all = CategoryReport(fileid, CompDiff, lth, uth, nthreshes, 'All');

si = 1;
for k = 1:numel(CatNames)
  ei = CatEls(k) + si - 1;
  inds = si:ei;
  MetamerReport.(lower(CatNames{k})) = CategoryReport(fileid, CompDiff(inds, inds, :), lth, uth, nthreshes, CatNames{k});
  si = si + CatEls(k);
end

save([ReportsPath, '/AllIlluminantReport.mat'], 'MetamerReport');

end

function MetamerReport = CategoryReport(fileid, CompMat, lth, uth, nthreshes, pretext)

% 9 is the length of largest text which is cambridge
if numel(pretext) < 9
  pretext = [pretext, ones(1, 9 - numel(pretext)) .* 32]; % 32 is space
end

MetamerReport = struct();

[rows, cols] = size(CompMat);
nPixels = rows * (cols - 1) / 2;

MetamerReport.NumElements = rows;

for j = 0:nthreshes
  CurrentThreshold = lth * (2 ^ j);
  mml = CompMat < CurrentThreshold & CompMat >= 0;
  
  [AbsoluteIsomersJ, AbsoluteMetamersJ] = IsomerVsMetamer(mml);
  
  fprintf(fileid, '(%s)\tlth %.1f:\t%f metamers \t%f isomers (num elements %d)\n', pretext, CurrentThreshold, AbsoluteMetamersJ / nPixels, AbsoluteIsomersJ / nPixels, rows);
  
  MetamerReport.(['th', num2str(j)]).('lth') = CurrentThreshold;
  MetamerReport.(['th', num2str(j)]).('isomers') = AbsoluteIsomersJ / nPixels;
  MetamerReport.(['th', num2str(j)]).('isomersnum') = AbsoluteIsomersJ;
  MetamerReport.(['th', num2str(j)]).('metamers') = AbsoluteMetamersJ / nPixels;
  MetamerReport.(['th', num2str(j)]).('metamernum') = AbsoluteMetamersJ;
  
  for k = [uth, CurrentThreshold * 2]
    mmu = CompMat > k;
    
    AbsoluteMetamersJK = LthUthMetamer(mml, mmu);
    
    fprintf(fileid, '  uth %.1f:\t%f percent metamers\n', k, AbsoluteMetamersJK / nPixels);
    
    MetamerReport.(['th', num2str(j)]).(['uth', num2str(k)]).('metamernum') = AbsoluteMetamersJK;
    MetamerReport.(['th', num2str(j)]).(['uth', num2str(k)]).('metamerper') = AbsoluteMetamersJK / nPixels;
  end
end

MetamerReport.DiffReport = MetamerDiffReport(CompMat);

end

function DiffReport = MetamerDiffReport(fileid, CompMat)

DiffMat = max(CompMat, [], 3) - min(CompMat, [], 3);

DiffReport.max = max(DiffMat(:));
DiffReport.min = min(DiffMat(DiffMat(:) >= 0));
DiffReport.avg = mean(DiffMat(DiffMat(:) >= 0));

fprintf(fileid, '  uth %.1f:\t%f percent metamers\n', k, AbsoluteMetamersJK / nPixels);

end

function [AbsoluteIsomers, AbsoluteMetamers] = IsomerVsMetamer(mml)

isomers = all(mml, 3);
AbsoluteIsomers = sum(isomers(:));

PotentialMetamers = any(mml, 3);
metamers = PotentialMetamers & ~isomers;
AbsoluteMetamers = sum(metamers(:));

end

function AbsoluteMetamers = LthUthMetamer(mml, mmu)

metamers = any(mml, 3) & any(mmu, 3);
AbsoluteMetamers = sum(metamers(:));

end
