function IlluminantPairReport = ReportMetamersPairResults(ResultsFolder, LabFolder, plotme)
%ReportMetamersPairResults Summary of this function goes here
%   Detailed explanation goes here

FunctionPath = mfilename('fullpath');
[~, FunctionName, ~] = fileparts(FunctionPath);
FunctionRelativePath = ['matlab', filesep, 'src', filesep, 'algorithms', filesep, 'colouranalysis', filesep, 'reporting', filesep, FunctionName];

GenDataPath = ['data', filesep, 'dataset', filesep, 'hsi', filesep];

if nargin < 3
  plotme = false;
end
if nargin < 2 || isempty(LabFolder)
  LabFolder = strrep(FunctionPath, FunctionRelativePath, [GenDataPath, 'results', filesep, '1931', filesep, 'lab', filesep]);
end
LabMats = struct();

SubFolders = GetSubFolders(ResultsFolder);
nCombinations = numel(SubFolders);
c = -nCombinations * 2;
nIllums = (1 + sqrt(1 - 4 * c)) / 2;

MetamerReportMat = load([ResultsFolder, filesep, SubFolders{1}, filesep, 'AllIlluminantReport']);
MetamerReport = MetamerReportMat.MetamerReport;

ThresholdNames = fieldnames(MetamerReport.all.lths);
nLowThreshes = numel(ThresholdNames);
nHighThreshes = numel(fieldnames(MetamerReport.all.lths.th1.uths));

IllumPairsPlot = cell(nIllums, nIllums);
IllumNamesOrder = cell(nIllums, 1);
LastIllumIndx = 1;

for s = 1:nCombinations
  CurrentSubFolder = [ResultsFolder, filesep, SubFolders{s}, filesep];
  if ~exist([CurrentSubFolder, 'AllIlluminantReport.mat'], 'file')
    disp([CurrentSubFolder, 'AllIlluminantReport. mat']);
    continue;
  end
  
  MetamerReportMat = load([CurrentSubFolder, 'AllIlluminantReport']);
  MetamerReport = MetamerReportMat.MetamerReport;
  [AllSpectraCounter, AverageMetamerSignal] = PlotMetamersCompareSpectra(MetamerReport, CurrentSubFolder, [], [], [], plotme);
  
  if plotme
    LabCars11 = [];
    LabCars12 = [];
    LabCars21 = [];
    LabCars22 = [];
  end
  
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
  
  CurrentPairReport = struct();
  LowHighPer = zeros(nHighThreshes, nLowThreshes);
  LowHighAbs = zeros(nHighThreshes, nLowThreshes);
  
  lths = zeros(1, nLowThreshes);
  uths = zeros(1, nHighThreshes);
  for i = 1:nLowThreshes
    LowThreshold = MetamerReport.all.lths.(ThresholdNames{i});
    lths(1, i) = LowThreshold.lth;
    for j = 1:nHighThreshes
      HighThreshold = LowThreshold.uths.(['uth', num2str(j)]);
      if i == 1
        uths(1, j) = HighThreshold.uth;
      end
      
      LowHighPer(nHighThreshes - j + 1, i) = HighThreshold.metamerper;
      LowHighAbs(nHighThreshes - j + 1, i) = HighThreshold.metamernum;
      
      if plotme
        mpairs = HighThreshold.metamerpairs;
        LabCars11 = [LabCars11; LabMats.(CurrentIllums{1}).car(mpairs(:, 1), :)]; %#ok
        LabCars12 = [LabCars12; LabMats.(CurrentIllums{1}).car(mpairs(:, 2), :)]; %#ok
        LabCars21 = [LabCars21; LabMats.(CurrentIllums{2}).car(mpairs(:, 1), :)]; %#ok
        LabCars22 = [LabCars22; LabMats.(CurrentIllums{2}).car(mpairs(:, 2), :)]; %#ok
      end
    end
  end
  
  if plotme
    PlotLabCarsOnHueCircle(LabCars11, LabCars12, LabCars21, LabCars22, CurrentIllums, SubFolders{s});
  end
  
  CurrentPairReport.LowHighPer = LowHighPer;
  CurrentPairReport.LowHighAbs = LowHighAbs;
  CurrentPairReport.AllSpectraCounter = AllSpectraCounter;
  CurrentPairReport.AverageMetamerSignal = AverageMetamerSignal;
  
  IllumPairsPlot{il1, il2} = CurrentPairReport;
  IllumPairsPlot{il2, il1} = CurrentPairReport;
end

IlluminantPairReport.IllumPairsPlot = IllumPairsPlot;
IlluminantPairReport.IllumNamesOrder = IllumNamesOrder;
IlluminantPairReport.lths = lths;
IlluminantPairReport.uths = uths;

end

function PlotLabCarsOnHueCircle(LabCars11, LabCars12, LabCars21, LabCars22, CurrentIllums, SubFolders)

DeltaE2000(:, 1) = deltae2000(LabCars11, LabCars12);
DeltaE2000(:, 2) = deltae2000(LabCars21, LabCars22);

m1n2 = DeltaE2000(:, 1) < 0.5;
m2n1 = DeltaE2000(:, 2) < 0.5;

FigureName = ['metamers under ''', CurrentIllums{1}, ''' but not under ''', CurrentIllums{2}, ''''];
FigureHandler = figure('name', FigureName);
PlotMetamerPairsUnderTwoIllumsPoint(LabCars11, LabCars21, LabCars12, LabCars22, m1n2, CurrentIllums);
suptitle(FigureName);
% saveas(FigureHandler, [ResultsFolder, filesep, SubFolders, filesep, 'm1n2.jpg']);
% close(FigureHandler);

FigureName = ['metamers under ''', CurrentIllums{2}, ''' but not under ''', CurrentIllums{1}, ''''];
FigureHandler = figure('name', FigureName);
PlotMetamerPairsUnderTwoIllumsPoint(LabCars11, LabCars21, LabCars12, LabCars22, m2n1, CurrentIllums);
suptitle(FigureName);
% saveas(FigureHandler, [ResultsFolder, filesep, SubFolders, filesep, 'm2n1.jpg']);
% close(FigureHandler);

end
