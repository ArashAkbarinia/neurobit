function IllumPairsShiftStats = PlotMetamersHueChange(ResultsFolder, LabFolder, saveme, WhichLth, WhichUth, ExcludeDatasets)
%PlotMetamersHueChange Summary of this function goes here
%   Detailed explanation goes here

FunctionPath = mfilename('fullpath');
[~, FunctionName, ~] = fileparts(FunctionPath);
FunctionRelativePath = ['matlab', filesep, 'src', filesep, 'algorithms', filesep, 'colouranalysis', filesep, 'plotting', filesep, FunctionName];

GenDataPath = ['data', filesep, 'dataset', filesep, 'hsi', filesep];

if nargin < 6 || isempty(ExcludeDatasets)
  ExcludeDatasets = [];
end
if nargin < 5
  WhichUth = [];
end
if nargin < 4
  WhichLth = [];
end
if nargin < 3
  saveme = false;
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

nbins = 180;

% getting the AllSpectra
FunctionPath = mfilename('fullpath');
[~, FunctionName, ~] = fileparts(FunctionPath);
FunctionRelativePath = ['matlab', filesep, 'src', filesep, 'algorithms', filesep, 'colouranalysis', filesep, 'plotting', filesep, FunctionName];

DataPath = ['matlab', filesep, 'data', filesep, 'mats', filesep, 'hsi', filesep];

AllSpectraPath = strrep(FunctionPath, FunctionRelativePath, [DataPath, 'AllSpectraUniformed.mat']);
AllSpectraMat = load(AllSpectraPath);

% output
IllumPairsShiftStats = struct();
IllumPairsShiftStats.shifts = cell(nIllums, nIllums);
IllumPairsShiftStats.labhist = cell(nIllums, 1);
IllumNamesOrder = cell(nIllums, 1);
LastIllumIndx = 1;

for s = 1:nCombinations
  CurrentSubFolder = [ResultsFolder, filesep, SubFolders{s}, filesep];
  if ~exist([CurrentSubFolder, 'AllIlluminantReport.mat'], 'file')
    disp([CurrentSubFolder, 'AllIlluminantReport. mat']);
    continue;
  end
  disp(['Processing: ', SubFolders{s}]);
  
  MetamerReportMat = load([CurrentSubFolder, 'AllIlluminantReport.mat']);
  MetamerReport = MetamerReportMat.MetamerReport;
  
  % handling which data
  SpectraInds = ExtractDatasetIndices(MetamerReport.all, AllSpectraMat.AllSpectra, ExcludeDatasets, false);
  
  LabCars11 = [];
  LabCars12 = [];
  LabCars21 = [];
  LabCars22 = [];
  
  % checking to see if the illuminant exist
  CurrentIllums = MetamerReport.illuminants;
  
  il1 = find(strcmp(IllumNamesOrder, CurrentIllums{1}));
  if isempty(il1)
    LabMats.(CurrentIllums{1}) = load([LabFolder, CurrentIllums{1}]);
    LabHist.(CurrentIllums{1}) = OriginalDataLabHist(LabMats.(CurrentIllums{1}).pol(SpectraInds, :), nbins);
    IllumNamesOrder{LastIllumIndx} = CurrentIllums{1};
    il1 = LastIllumIndx;
    IllumPairsShiftStats.labhist{LastIllumIndx}= LabHist.(CurrentIllums{1});
    LastIllumIndx = LastIllumIndx + 1;
  end
  il2 = find(strcmp(IllumNamesOrder, CurrentIllums{2}));
  if isempty(il2)
    LabMats.(CurrentIllums{2}) = load([LabFolder, CurrentIllums{2}]);
    LabHist.(CurrentIllums{2}) = OriginalDataLabHist(LabMats.(CurrentIllums{2}).pol, nbins);
    IllumNamesOrder{LastIllumIndx} = CurrentIllums{2};
    il2 = LastIllumIndx;
    IllumPairsShiftStats.labhist{LastIllumIndx}= LabHist.(CurrentIllums{2});
    LastIllumIndx = LastIllumIndx + 1;
  end
  
  for i = 1:nLowThreshes
    LowThreshold = MetamerReport.all.lths.(ThresholdNames{i});
    if isempty(WhichLth) || ismember(LowThreshold.lth, WhichLth)
      for j = 1:nHighThreshes
        HighThreshold = LowThreshold.uths.(['uth', num2str(j)]);
        if isempty(WhichUth) || ismember(HighThreshold.uth, WhichUth)
          
          mpairs = HighThreshold.metamerpairs;
          mpairs = mpairs(any(ismember(mpairs, SpectraInds), 2), :);
          LabCars11 = [LabCars11; LabMats.(CurrentIllums{1}).car(mpairs(:, 1), :)]; %#ok
          LabCars12 = [LabCars12; LabMats.(CurrentIllums{1}).car(mpairs(:, 2), :)]; %#ok
          LabCars21 = [LabCars21; LabMats.(CurrentIllums{2}).car(mpairs(:, 1), :)]; %#ok
          LabCars22 = [LabCars22; LabMats.(CurrentIllums{2}).car(mpairs(:, 2), :)]; %#ok
        end
      end
    end
  end
  
  ShiftStats = PlotLabCarsOnHueCircle(LabCars11, LabCars12, LabCars21, LabCars22, CurrentIllums, CurrentSubFolder, LabHist.(CurrentIllums{1}), LabHist.(CurrentIllums{2}), saveme);
  IllumPairsShiftStats.shifts{il1, il2} = ShiftStats;
  IllumPairsShiftStats.shifts{il2, il1} = ShiftStats;
end

end

function LabHist = OriginalDataLabHist(PolLab, nbins)

if nargin < 2
  nbins = 12;
end
[theta, radius] = rose(PolLab(:, 1), nbins);

LabHist.AbsRadius = radius;
LabHist.RatRadius = radius ./ sum(radius);
LabHist.theta = theta;

end

function ShiftStats = PlotLabCarsOnHueCircle(LabCars11, LabCars12, LabCars21, LabCars22, CurrentIllums, SubFolders, OrgHist1, OrgHist2, saveme)

ShiftStats = struct();

if isempty(LabCars11)
  return;
end

DeltaE2000(:, 1) = deltae2000(LabCars11, LabCars12);
DeltaE2000(:, 2) = deltae2000(LabCars21, LabCars22);

m1n2 = DeltaE2000(:, 1) < DeltaE2000(:, 2);
m2n1 = DeltaE2000(:, 2) < DeltaE2000(:, 1);

FigPos = [0, 0, 50, 25];
if saveme
  isvisible = 'off';
else
  isvisible = 'on';
end

if any(m1n2)
  FigureName = ['metamers under ''', CurrentIllums{1}, ''' but not under ''', CurrentIllums{2}, ''''];
  FigureHandler = figure('name', FigureName, 'PaperPosition', FigPos, 'visible', isvisible);
  ShiftStats.m1n2 = PlotMetamerPairsUnderTwoIllumsHist(LabCars11, LabCars21, LabCars12, LabCars22, m1n2, CurrentIllums, OrgHist1, OrgHist2);
  suptitle(FigureName);
  if saveme
    print(FigureHandler, [SubFolders, 'm1n2.jpg'], '-djpeg', '-r0');
    close(FigureHandler);
  end
end

if any(m2n1)
  FigureName = ['metamers under ''', CurrentIllums{2}, ''' but not under ''', CurrentIllums{1}, ''''];
  FigureHandler = figure('name', FigureName, 'PaperPosition', FigPos, 'visible', isvisible);
  ShiftStats.m2n1 = PlotMetamerPairsUnderTwoIllumsHist(LabCars11, LabCars21, LabCars12, LabCars22, m2n1, CurrentIllums, OrgHist1, OrgHist2);
  suptitle(FigureName);
  if saveme
    print(FigureHandler, [SubFolders, 'm2n1.jpg'], '-djpeg', '-r0');
    close(FigureHandler);
  end
end

end
