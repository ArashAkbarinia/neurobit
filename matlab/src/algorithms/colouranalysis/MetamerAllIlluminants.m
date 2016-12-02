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
ReportsPath = [FolderPath, 'reports/multiilluminant'];
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
  LabPoint.car(:, :, i) = CurrentLab.car;
  LabPoint.wp(i, :) = CurrentLab.wp;
end

clear CurrentDif;
clear CurrentLab;

disp('Starting to process:');

if plotme == 2
  fileid = fopen([ReportsPath, '/', 'AllAnalysis.txt'], 'w');
else
  fileid = 1;
end
MetamerReport.all = CategoryReport(fileid, CompDiff, lth, uth, nthreshes, 'All', ...
  0, [], [], [], []);

si = 1;
for k = 1:numel(CatNames)
  if plotme == 2
    SavemeDirectory = [ReportsPath, '/', MatList(i).name(1:end - 4), '/', lower(CatNames{k})];
    if ~exist(SavemeDirectory, 'dir')
      mkdir(SavemeDirectory);
    end
  else
    SavemeDirectory = [];
  end
  
  ei = CatEls(k) + si - 1;
  inds = si:ei;
  CurrentSignal.spectra = AllSpectra.originals.(lower(CatNames{k}));
  CurrentSignal.wavelength = AllSpectra.wavelengths.(lower(CatNames{k}));
  MetamerReport.(lower(CatNames{k})) = CategoryReport(fileid, CompDiff(inds, inds, :), lth, uth, nthreshes, CatNames{k}, ...
    plotme, CurrentSignal, LabPoint.car(inds, :, :), LabPoint.wp, SavemeDirectory);
  si = si + CatEls(k);
end

save([ReportsPath, '/AllIlluminantReport.mat'], 'MetamerReport');

end

function MetamerReport = CategoryReport(fileid, CompMat, lth, uth, nthreshes, CategoryName, plotme, signal, lab, wp, SavemeDirectory)

PrintPreText = CategoryName;

% 9 is the length of largest text which is cambridge
if numel(PrintPreText) < 9
  PrintPreText = [PrintPreText, ones(1, 9 - numel(PrintPreText)) .* 32]; % 32 is space
end

MetamerReport = struct();

[rows, cols] = size(CompMat);
nPixels = rows * (cols - 1) / 2;

MetamerReport.NumElements = rows;

%TODO: fix this with plotting all iluminant
d65ind = 7;

for j = 0:nthreshes
  CurrentThreshold = lth * (2 ^ j);
  mml = CompMat < CurrentThreshold & CompMat >= 0;
  
  [AbsoluteIsomersJ, AbsoluteMetamersJ, metamers] = IsomerVsMetamer(mml);
  
  fprintf(fileid, '(%s)\tlth %.1f:\t%f metamers \t%f isomers (num elements %d)\n', PrintPreText, CurrentThreshold, AbsoluteMetamersJ / nPixels, AbsoluteIsomersJ / nPixels, rows);
  
  MetamerReport.(['th', num2str(j)]).('lth') = CurrentThreshold;
  MetamerReport.(['th', num2str(j)]).('isomers') = AbsoluteIsomersJ / nPixels;
  MetamerReport.(['th', num2str(j)]).('isomersnum') = AbsoluteIsomersJ;
  MetamerReport.(['th', num2str(j)]).('metamers') = AbsoluteMetamersJ / nPixels;
  MetamerReport.(['th', num2str(j)]).('metamernum') = AbsoluteMetamersJ;
  
  if plotme > 0
    %TODO: plot the signal under all illuminants
    MetamerPlot.metamers = metamers;
    MetamerPlot.SgnlDiffs = CompMat(:, :, d65ind); %7 is d65 just for plotting now
    PlotElementSignals(signal.spectra, MetamerPlot, signal.wavelength, lab(:, :, d65ind), [CategoryName, '-lth', num2str(j)], wp(d65ind, :), SavemeDirectory);
  end
  
  for k = [uth, CurrentThreshold * 2]
    mmu = CompMat > k;
    
    [AbsoluteMetamersJK, metamers] = LthUthMetamer(mml, mmu);
    
    fprintf(fileid, '  uth %.1f:\t%f percent metamers\n', k, AbsoluteMetamersJK / nPixels);
    
    MetamerReport.(['th', num2str(j)]).(['uth', num2str(k)]).('metamernum') = AbsoluteMetamersJK;
    MetamerReport.(['th', num2str(j)]).(['uth', num2str(k)]).('metamerper') = AbsoluteMetamersJK / nPixels;
    
    if plotme > 0
      %TODO: plot the signal under all illuminants
      MetamerPlot.metamers = metamers;
      MetamerPlot.SgnlDiffs = CompMat(:, :, d65ind); %7 is d65 just for plotting now
      PlotElementSignals(signal.spectra, MetamerPlot, signal.wavelength, lab(:, :, d65ind), [CategoryName, '-lth', num2str(j), '-uth', num2str(k)], wp(d65ind, :), SavemeDirectory);
    end
  end
end

MetamerReport.DiffReport = MetamerDiffReport(CompMat, 0:0.5:20);

fprintf(fileid, '(%s)\tMax: %f  Min: %f  Avg: %f  Med: %f\n', ...
  PrintPreText, MetamerReport.DiffReport.max, MetamerReport.DiffReport.min, MetamerReport.DiffReport.avg, MetamerReport.DiffReport.med);

end

function DiffReport = MetamerDiffReport(CompMat, edges)

MaskMat = CompMat(:, :, 1);
DiffMat = max(CompMat, [], 3) - min(CompMat, [], 3);
DiffMat(MaskMat == -1) = -1;
DiffMat = DiffMat(:);

DiffReport.max = max(DiffMat);
DiffReport.min = min(DiffMat(DiffMat >= 0));
DiffReport.avg = mean(DiffMat(DiffMat >= 0));
DiffReport.med = median(DiffMat(DiffMat >= 0));

[DiffReport.hist.hcounts, DiffReport.hist.hedges] = hist(DiffMat(DiffMat >= 0), edges);

end

function [AbsoluteIsomers, AbsoluteMetamers, metamers] = IsomerVsMetamer(mml)

isomers = all(mml, 3);
AbsoluteIsomers = sum(isomers(:));

PotentialMetamers = any(mml, 3);
metamers = PotentialMetamers & ~isomers;
AbsoluteMetamers = sum(metamers(:));

end

function [AbsoluteMetamers, metamers] = LthUthMetamer(mml, mmu)

metamers = any(mml, 3) & any(mmu, 3);
AbsoluteMetamers = sum(metamers(:));

end

function [] = PlotElementSignals(element, MetamerPlot, wavelength, lab, name, wp, SavemeDirectory)

SignalLength = size(element, 3);
nSignals = size(element, 1);
lab = reshape(lab, size(lab, 1), 1, 3);
PlotTopMetamers(MetamerPlot, reshape(element, nSignals, SignalLength)', 25, wavelength, lab, name, wp, SavemeDirectory);

end
