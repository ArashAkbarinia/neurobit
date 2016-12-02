function MetamerReport = ReportResultsAllIlluminants( FolderPath )
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
plotme.p = 2;
plotme.h = 2;
plotmeall.p = plotme.p;
plotmeall.h = plotme.h;

CatEls = [1600, 21, 289, 182, 1056, 272, 803, 3283, 1939, 384, 702, 339, 404];
CatNames = {'Munsell', 'Candy', 'Agfa', 'Natural', 'Forest', 'Lumber', 'Paper', 'Cambridge', 'Fred400', 'Fred401', 'Barnard', 'Matsumoto', 'Westland'};
labels = cell(nfiles);

for i = 1:nfiles
  disp(['reading: ', MatList(i).name]);
  labels{i} = MatList(i).name;
  CurrentDif = load([MetamerPath, '/', MatList(i).name]);
  
  % some tricks to get the upper part of the matrix only
  CurrentDif.CompMat = CurrentDif.CompMat - tril(ones(size(CurrentDif.CompMat)));
  
  CompDiff(:, :, i) = CurrentDif.CompMat; %#ok
  
  CurrentLab = load([LabCaPoPath, '/', MatList(i).name]);
  LabPoint.car(:, i, :) = reshape(CurrentLab.car, size(CurrentLab.car, 1), 1, 3);
  LabPoint.wp(i, :) = CurrentLab.wp;
end

clear CurrentDif;
clear CurrentLab;

disp('Starting to process:');

if plotme.p == 2
  fileid = fopen([ReportsPath, '/', 'AllAnalysis.txt'], 'w');
else
  fileid = 1;
end

if plotmeall.p == 2 || plotmeall.h == 2
  SavemeDirectory = [ReportsPath, '/all'];
  if ~exist(SavemeDirectory, 'dir')
    mkdir(SavemeDirectory);
  end
else
  SavemeDirectory = [];
end

CurrentSignal.spectra = AllSpectraMat.spectra;
CurrentSignal.wavelength = AllSpectraMat.wavelength;
MetamerReport.all = CategoryReport(fileid, CompDiff, lth, uth, nthreshes, 'All', ...
  plotmeall, CurrentSignal, LabPoint.car, LabPoint.wp, SavemeDirectory, labels);

si = 1;
for k = 1:numel(CatNames)
  if plotme.p == 2 || plotme.h == 2
    SavemeDirectory = [ReportsPath, '/', lower(CatNames{k})];
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
    plotme, CurrentSignal, LabPoint.car(inds, :, :), LabPoint.wp, SavemeDirectory, labels);
  si = si + CatEls(k);
end

if plotme.p == 2
  fclose(fileid);
end

save([ReportsPath, '/AllIlluminantReport.mat'], 'MetamerReport');

end

function MetamerReport = CategoryReport(fileid, CompMat, lth, uth, nthreshes, CategoryName, plotme, signal, lab, wp, SavemeDirectory, labels)

PrintPreText = CategoryName;

% 9 is the length of largest text which is cambridge
if numel(PrintPreText) < 9
  PrintPreText = [PrintPreText, ones(1, 9 - numel(PrintPreText)) .* 32]; % 32 is space
end

MetamerReport = struct();

[rows, cols] = size(CompMat);
nPixels = rows * (cols - 1) / 2;

MetamerReport.NumElements = rows;

if plotme.p > 0
  MaskMat = CompMat(:, :, 1);
  DiffMat = max(CompMat, [], 3) - min(CompMat, [], 3);
  DiffMat(MaskMat == -1) = -1;
end

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
  
  if plotme.p > 0
    MetamerPlot.metamers = metamers;
    MetamerPlot.SgnlDiffs = DiffMat;
    PlotElementSignals(signal.spectra, MetamerPlot, signal.wavelength, lab, [CategoryName, '-lth', num2str(j)], wp, SavemeDirectory, labels);
  end
  
  for k = [uth, CurrentThreshold * 2]
    mmu = CompMat > k;
    
    [AbsoluteMetamersJK, metamers] = LthUthMetamer(mml, mmu);
    
    fprintf(fileid, '  uth %.1f:\t%f percent metamers\n', k, AbsoluteMetamersJK / nPixels);
    
    MetamerReport.(['th', num2str(j)]).(['uth', num2str(k)]).('metamernum') = AbsoluteMetamersJK;
    MetamerReport.(['th', num2str(j)]).(['uth', num2str(k)]).('metamerper') = AbsoluteMetamersJK / nPixels;
    
    if plotme.p > 0
      MetamerPlot.metamers = metamers;
      MetamerPlot.SgnlDiffs = DiffMat;
      PlotElementSignals(signal.spectra, MetamerPlot, signal.wavelength, lab, [CategoryName, '-lth', num2str(j), '-uth', num2str(k)], wp, SavemeDirectory, labels);
    end
  end
end

MetamerReport.DiffReport = MetamerDiffReport(CompMat, 0:0.5:20);

% plotting the diff histogram
if plotme.h > 0
  if isempty(SavemeDirectory)
    isvisible = 'on';
  else
    isvisible = 'off';
  end
  FigureHandler = figure('name', ['diff histograms ', CategoryName], 'visible', isvisible, 'pos', [1, 1, 1280, 720]);
  NormalisedCounts = 100 * MetamerReport.DiffReport.hist.hcounts / sum(MetamerReport.DiffReport.hist.hcounts);
  bar(MetamerReport.DiffReport.hist.hedges, NormalisedCounts, 'barwidth', 1);
  xlabel('Input Value');
  ylabel('Normalised Count [%]');
  xlim([0, MetamerReport.DiffReport.hist.hedges(end)]);
end

if ~isempty(SavemeDirectory)
  saveas(FigureHandler, [SavemeDirectory, '/DiffHistograms-', CategoryName, '.jpg']);
  close(FigureHandler);
end

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

function [] = PlotElementSignals(element, MetamerPlot, wavelength, lab, name, wp, SavemeDirectory, labels)

PlotMetamersAllIllum(MetamerPlot, element, 9, wavelength, lab, name, wp, SavemeDirectory, labels);

end
