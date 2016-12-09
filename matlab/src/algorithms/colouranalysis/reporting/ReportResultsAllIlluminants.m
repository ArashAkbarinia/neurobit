function MetamerReport = ReportResultsAllIlluminants(FolderPath, DebugIllumInds, DebugCategoriesInds, lth, uth, plotme)
%ReportResultsAllIlluminants  generates the metamer reports based on all illums.
%   Detailed explanation goes here

MetamerReport = struct();

FunctionPath = mfilename('fullpath');
[~, FunctionName, ~] = fileparts(FunctionPath);

FunctionRelativePath = ['matlab', filesep, 'src', filesep, 'algorithms', filesep, 'colouranalysis', filesep, 'reporting', filesep, FunctionName];

if nargin < 1 || isempty(FolderPath)
  GenDataPath = ['data', filesep, 'dataset', filesep, 'hsi', filesep];
  FolderPath = strrep(FunctionPath, FunctionRelativePath, [GenDataPath, 'results', filesep, '1931', filesep]);
end

MatDataPath = ['matlab', filesep, 'data', filesep, 'mats', filesep, 'hsi', filesep];

MetamerPath = [FolderPath, 'metamers'];
CategorPath = [FolderPath, 'categorisation', filesep, 'arash'];
LabCaPoPath = [FolderPath, 'lab'];
ReportsPath = [FolderPath, 'reports', filesep, 'multiilluminant'];
AllSpectraMat = load(strrep(FunctionPath, FunctionRelativePath, [MatDataPath, 'AllSpectra.mat']));
AllSpectra = AllSpectraMat.AllSpectra;

% for debugging purposes
if nargin < 2 || isempty(DebugIllumInds)
  DebugIllumInds = [];
end
if nargin < 3 || isempty(DebugCategoriesInds)
  DebugCategoriesInds = [];
end

MatList = dir([MetamerPath, filesep, '*.mat']);
if isempty(DebugIllumInds)
  DebugIllumInds = 1:numel(MatList);
end
MatList = MatList(DebugIllumInds);
nfiles = length(MatList);

% the lower and upper threshold
if nargin < 4 || isempty(lth)
  lth = 0.5:0.5:5;
end
if nargin < 5 || isempty(uth)
  uth = 0.5:1:20.5;
end

% 0 means nothing, 1 means plot, 2 means save
if nargin < 6 || isempty(plotme)
  plotme = 2;
end

CatNames = fieldnames(AllSpectra.originals);
ncategories = numel(CatNames);
CatEls = zeros(ncategories, 1);
for i = 1:ncategories
  CatEls(i) = size(AllSpectra.originals.(CatNames{i}), 1);
end

if isempty(DebugCategoriesInds)
  DebugCategoriesInds = 1:numel(CatNames);
end
CatNames = CatNames(DebugCategoriesInds);
AllInds = sum(CatEls);
CatEls = CatEls(DebugCategoriesInds);
StartInd = AllInds - sum(CatEls) + 1;
DebugPositionInds = StartInd:StartInd + sum(CatEls) - 1;

labels = cell(nfiles, 1);

ColourNaming = [];

for i = 1:nfiles
  disp(['reading: ', MatList(i).name]);
  labels{i} = MatList(i).name(1:end - 4);
  CurrentDif = load([MetamerPath, filesep, MatList(i).name]);
  CurrentDif.CompMat = CurrentDif.CompMat(DebugPositionInds, DebugPositionInds);
  
  % some tricks to get the upper part of the matrix only
  CurrentDif.CompMat = CurrentDif.CompMat - tril(ones(size(CurrentDif.CompMat)));
  
  CompDiff(:, :, i) = CurrentDif.CompMat; %#ok
  
  CurrentCat = load([CategorPath, filesep, MatList(i).name]);
  CurrentCat.CurrentNames = CurrentCat.CurrentNames(DebugPositionInds, :);
  ColourNaming(:, i) = CurrentCat.CurrentNames; %#ok
  
  CurrentLab = load([LabCaPoPath, filesep, MatList(i).name]);
  CurrentLab.car = CurrentLab.car(DebugPositionInds, :);
  LabPoint.car(:, i, :) = reshape(CurrentLab.car, size(CurrentLab.car, 1), 1, 3);
  LabPoint.wp(i, :) = CurrentLab.wp;
end

clear CurrentDif;
clear CurrentLab;

disp('Starting to process:');

if plotme == 2
  fileid = fopen([ReportsPath, filesep, 'AllAnalysis.txt'], 'w');
  SavemeDirectory = [ReportsPath, filesep, 'all', filesep];
  if ~exist(SavemeDirectory, 'dir')
    mkdir(SavemeDirectory);
  end
else
  fileid = 1;
  SavemeDirectory = [];
end

CurrentSignal.spectra = AllSpectraMat.spectra;
CurrentSignal.wavelength = AllSpectraMat.wavelength;
MetamerReport.all = CategoryReport(fileid, CompDiff, lth, uth, 'All', ...
  plotme, CurrentSignal, LabPoint.car, LabPoint.wp, SavemeDirectory, labels, ColourNaming);

si = 1;
for k = 1:numel(CatNames)
  if plotme == 2
    SavemeDirectory = [ReportsPath, filesep, lower(CatNames{k}), filesep];
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
  MetamerReport.(lower(CatNames{k})) = CategoryReport(fileid, CompDiff(inds, inds, :), lth, uth, CatNames{k}, ...
    plotme, CurrentSignal, LabPoint.car(inds, :, :), LabPoint.wp, SavemeDirectory, labels, ColourNaming);
  si = si + CatEls(k);
end

if plotme == 2
  fclose(fileid);
end

save([ReportsPath, filesep, 'AllIlluminantReport.mat'], 'MetamerReport');

end

function MetamerReport = CategoryReport(fileid, CompMat, lth, uth, CategoryName, plotme, signal, lab, wp, SavemeDirectory, labels, ColourNaming)

PrintPreText = CategoryName;

% 9 is the length of largest text which is cambridge
if numel(PrintPreText) < 9
  PrintPreText = [PrintPreText, ones(1, 9 - numel(PrintPreText)) .* 32]; % 32 is space
end

MetamerReport = struct();

[rows, cols] = size(CompMat);
nPixels = rows * (cols - 1) / 2;

MetamerReport.NumElements = rows;

if plotme > 0
  MaskMat = CompMat(:, :, 1);
  DiffMat = max(CompMat, [], 3) - min(CompMat, [], 3);
  DiffMat(MaskMat == -1) = -1;
end

for j = 1:length(lth)
  LowThreshold = lth(j);
  mml = CompMat >= 0 & CompMat < LowThreshold;
  
  fprintf(fileid, '(%s)\tlth %.1f:\t(num elements %d)\n', PrintPreText, LowThreshold, rows);
  
  MetamerReport.(['th', num2str(j)]).('lth') = LowThreshold;
  
  for k = 1:length(uth)
    HighThreshold = uth(k);
    mmu = CompMat > HighThreshold;
    
    [AbsoluteMetamersJK, metamers] = LthUthMetamer(mml, mmu);
    
    [cnrows, cncols] = find(metamers == 1);
    
    MetamerColourNameReport = ReportColourNamingResults([cnrows, cncols], ColourNaming);
    AbsoluteColourNameChange = sum(MetamerColourNameReport);
    ProbabilityColourNameChange = AbsoluteColourNameChange / size(MetamerColourNameReport, 1);
    
    fprintf(fileid, '  uth %.1f:\t%f percent metamers\n', HighThreshold, AbsoluteMetamersJK / nPixels);
    
    MetamerReport.(['th', num2str(j)]).(['uth', num2str(k)]).('uth') = HighThreshold;
    MetamerReport.(['th', num2str(j)]).(['uth', num2str(k)]).('metamernum') = AbsoluteMetamersJK;
    MetamerReport.(['th', num2str(j)]).(['uth', num2str(k)]).('metamerper') = AbsoluteMetamersJK / nPixels;
    
    MetamerReport.(['th', num2str(j)]).(['uth', num2str(k)]).('collournamenum') = AbsoluteColourNameChange;
    MetamerReport.(['th', num2str(j)]).(['uth', num2str(k)]).('collournameper') = ProbabilityColourNameChange;
    
    if plotme > 0
      MetamerPlot.metamers = metamers;
      MetamerPlot.SgnlDiffs = DiffMat;
      PlotElementSignals(signal.spectra, MetamerPlot, signal.wavelength, lab, [CategoryName, '-lth', num2str(j), '-uth', num2str(k)], wp, SavemeDirectory, labels);
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

function [AbsoluteMetamers, metamers] = LthUthMetamer(mml, mmu)

metamers = any(mml, 3) & any(mmu, 3);
AbsoluteMetamers = sum(metamers(:));

end

function [] = PlotElementSignals(element, MetamerPlot, wavelength, lab, name, wp, SavemeDirectory, labels)

if isempty(SavemeDirectory)
  PlotMetamersAllIllum(MetamerPlot, element, 25, wavelength, lab, name, wp, labels);
else
  illus = SaveMetamersAllIllumMat(MetamerPlot, element, 25, wavelength, lab, wp, labels); %#ok
  save([SavemeDirectory, 'MetamerSignals-', name, '.mat'], 'illus');
end

end
