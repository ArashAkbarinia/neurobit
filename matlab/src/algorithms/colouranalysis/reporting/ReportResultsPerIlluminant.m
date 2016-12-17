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
AllSpectraMat = load([FolderPath, 'signals/AllSpectraNormalised.mat']);
AllSpectra = AllSpectraMat.AllSpectra;

MatList = dir([MetamerPath, '/*.mat']);
nfiles = length(MatList);
nthreshes = 4;
th = 0.5;
% 0 means nothing, 1 means plot, 2 means save
plotme = 2;

CatEls = [1600, 21, 289, 182, 1056, 272, 803, 3283, 1939, 384, 702, 339, 404];
CatNames = {'Munsell', 'Candy', 'Agfa', 'Natural', 'Forest', 'Lumber', 'Paper', 'Cambridge', 'Fred400', 'Fred401', 'Barnard', 'Matsumoto', 'Westland'};

for i = 1:nfiles
  disp(['Processing: ', MatList(i).name]);
  CurrentDif = load([MetamerPath, '/', MatList(i).name]);
  CurrentLab = load([LabCaPoPath, '/', MatList(i).name]);
  
  if plotme == 2
    fileid = fopen([ReportsPath, '/', MatList(i).name(1:end - 3), 'txt'], 'w');
  else
    fileid = 1;
  end
  
  % TODO: think about how you plot for ALL
  %   if plotme == 1
  %     SavemeDirectory = [ReportsPath, '/', MatList(i).name(1:end - 4), '/all', lower(CatNames{k})];
  %     if ~exist(SavemeDirectory, 'dir')
  %       mkdir(SavemeDirectory);
  %     end
  %   else
  %     SavemeDirectory = [];
  %   end
  
  %   CurrentSignal.spectra = AllSpectra.originals.all;
  %   CurrentSignal.wavelength = AllSpectra.wavelengths.all;
  %   MetamerReport.all = CategoryReport(fileid, CurrentDif.CompMat, th, nthreshes, 'All', ...
  %     plotme, CurrentSignal, CurrentLab.car, CurrentLab.wp, SavemeDirectory);
  MetamerReport.(MatList(i).name(1:end - 4)).all = CategoryReport(fileid, CurrentDif.CompMat, th, nthreshes, 'All', ...
    0, [], [], CurrentLab.wp, []);
  
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
    MetamerReport.(MatList(i).name(1:end - 4)).(lower(CatNames{k})) = CategoryReport(fileid, CurrentDif.CompMat(inds, inds), th, nthreshes, CatNames{k}, ...
      plotme, CurrentSignal, CurrentLab.car(inds, :), CurrentLab.wp, SavemeDirectory);
    si = si + CatEls(k);
  end
  
  if plotme == 2
    fclose(fileid);
  end
end

save([ReportsPath, '/PerIlluminantReport.mat'], 'MetamerReport');

end

function MetamerReport = CategoryReport(fileid, CompMat, th, nthreshes, CategoryName, plotme, signal, lab, wp, SavemeDirectory)

PrintPreText = CategoryName;

% 9 is the length of largest text which is cambridge
if numel(PrintPreText) < 9
  PrintPreText = [PrintPreText, ones(1, 9 - numel(PrintPreText)) .* 32]; % 32 is space
end

MetamerReport = struct();

% some tricks to get the upper part of the matrix only
CompMat = CompMat - tril(ones(size(CompMat)));

[rows, cols] = size(CompMat);
nPixels = rows * (cols - 1) / 2;

MetamerReport.NumElements = rows;

for j = 0:nthreshes
  CurrentThreshold = th * (2 ^ j);
  mml = CompMat < CurrentThreshold & CompMat >= 0;
  AbsoluteMetamers = sum(mml(:));
  fprintf(fileid, ' (%s)\tth %.1f:\t%f percent metamers (num elements %d)\n', PrintPreText, CurrentThreshold, AbsoluteMetamers / nPixels, rows);
  MetamerReport.(['th', num2str(j)]).('th') = CurrentThreshold;
  MetamerReport.(['th', num2str(j)]).('metamernum') = AbsoluteMetamers;
  MetamerReport.(['th', num2str(j)]).('metamerper') = AbsoluteMetamers / nPixels;
  
  if plotme > 0
    MetamerPlot.metamers = mml;
    MetamerPlot.SgnlDiffs = CompMat;
    PlotElementSignals(signal.spectra, MetamerPlot, signal.wavelength, lab, [CategoryName, '-th', num2str(j)], wp, SavemeDirectory);
  end
end

end

function [] = PlotElementSignals(element, MetamerPlot, wavelength, lab, name, wp, SavemeDirectory)

SignalLength = size(element, 3);
nSignals = size(element, 1);
lab = reshape(lab, size(lab, 1), 1, 3);
PlotTopMetamers(MetamerPlot, reshape(element, nSignals, SignalLength)', 25, wavelength, lab, name, wp, SavemeDirectory);

end
