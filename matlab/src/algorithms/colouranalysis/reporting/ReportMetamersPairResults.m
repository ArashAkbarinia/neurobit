function IlluminantPairReport = ReportMetamersPairResults(ResultsFolder)
%ReportMetamersPairResults Summary of this function goes here
%   Detailed explanation goes here

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
DiffReports = cell(nIllums, nIllums);
IllumNamesOrder = cell(nIllums, 1);
LastIllumIndx = 1;

for s = 1:nCombinations
  CurrentSubFolder = [ResultsFolder, filesep, SubFolders{s}, filesep];
  if ~exist([CurrentSubFolder, 'AllIlluminantReport.mat'], 'file')
    disp([CurrentSubFolder, 'AllIlluminantReport. mat']);
    continue;
  end
  disp(['Processing: ', SubFolders{s}]);
  
  MetamerReportMat = load([CurrentSubFolder, 'AllIlluminantReport']);
  MetamerReport = MetamerReportMat.MetamerReport;
  
  [AllSpectraCounter, AverageMetamerSignal] = PlotMetamersCompareSpectra(MetamerReport, CurrentSubFolder, [], [], [], false);
  
  % checking to see if the illuminant exist
  CurrentIllums = MetamerReport.illuminants;
  il1 = find(strcmp(IllumNamesOrder, CurrentIllums{1}));
  if isempty(il1)
    IllumNamesOrder{LastIllumIndx} = CurrentIllums{1};
    il1 = LastIllumIndx;
    LastIllumIndx = LastIllumIndx + 1;
  end
  il2 = find(strcmp(IllumNamesOrder, CurrentIllums{2}));
  if isempty(il2)
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
    
    % setting the lower threshold
    lths(1, i) = LowThreshold.lth;
    
    for j = 1:nHighThreshes
      HighThreshold = LowThreshold.uths.(['uth', num2str(j)]);
      
      % setting the upper thresholds
      if i == 1
        uths(1, j) = HighThreshold.uth;
      end
      
      LowHighPer(nHighThreshes - j + 1, i) = HighThreshold.metamerper;
      LowHighAbs(nHighThreshes - j + 1, i) = HighThreshold.metamernum;
    end
  end
  
  CurrentPairReport.LowHighPer = LowHighPer;
  CurrentPairReport.LowHighAbs = LowHighAbs;
  CurrentPairReport.AllSpectraCounter = AllSpectraCounter;
  CurrentPairReport.AverageMetamerSignal = AverageMetamerSignal;
  
  IllumPairsPlot{il1, il2} = CurrentPairReport;
  IllumPairsPlot{il2, il1} = CurrentPairReport;
  DiffReports{il1, il2} = MetamerReport.all.DiffReport;
  DiffReports{il2, il1} = MetamerReport.all.DiffReport;
end

IlluminantPairReport.IllumPairsPlot = IllumPairsPlot;
IlluminantPairReport.IllumNamesOrder = IllumNamesOrder;
IlluminantPairReport.lths = lths;
IlluminantPairReport.uths = uths;
IlluminantPairReport.DiffReports = DiffReports;

end
