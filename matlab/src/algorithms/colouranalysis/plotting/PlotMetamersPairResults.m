function LthUthReport = PlotMetamersPairResults(IlluminantPairReport, ResultsFolder)
%PlotMetamersPairResults Summary of this function goes here
%   Detailed explanation goes here

% reading the spectra mat file
FunctionPath = mfilename('fullpath');
[~, FunctionName, ~] = fileparts(FunctionPath);
FunctionRelativePath = ['matlab', filesep, 'src', filesep, 'algorithms', filesep, 'colouranalysis', filesep, 'plotting', filesep, FunctionName];

MatDataPath = ['matlab', filesep, 'data', filesep, 'mats', filesep, 'hsi', filesep];
AllSpectraMat = load(strrep(FunctionPath, FunctionRelativePath, [MatDataPath, 'AllSpectraUniformed.mat']));

IllumNamesOrder = IlluminantPairReport.IllumNamesOrder;
IllumPairsPlot = IlluminantPairReport.IllumPairsPlot;
% LowHighAbs and LowHighPer the x axis is reverse (low values in the last
% rows)
lths = IlluminantPairReport.lths;
uths = IlluminantPairReport.uths;

nillus = numel(IllumNamesOrder);

if nargin < 2
  PlotsFolder = ['data', filesep, 'dataset', filesep, 'hsi', filesep, 'results', filesep, '1931', filesep, 'plots', filesep, 'illuminantspair', filesep];
  ResultsFolder = strrep(FunctionPath, FunctionRelativePath, PlotsFolder);
end

% plotting the average metamer signal
PlotAverageSpectra(ResultsFolder, IllumPairsPlot, IllumNamesOrder, nillus, AllSpectraMat);

[nuth, nlth] = size(IllumPairsPlot{1, 2}.LowHighAbs);

ExcelFileName = [ResultsFolder, 'IlluminantComparison.xlsx'];

fileid = fopen([ResultsFolder, 'IlluminantComparison.txt'], 'w');

LthUthRanking = cell(nillus, nlth * nuth);
LthUthAbsolute = cell(nillus, nlth * nuth);
LthUthRankingHeaders = cell(1, nlth * nuth);
AllByAllLthUthPer = zeros(nuth, nlth);
AllByAllLthUthAbs = zeros(nuth, nlth);

ColumnNumber = 1;
for l = 1:nlth
  for u = nuth:-1:1
    CurrentLthUth = zeros(nillus, nillus);
    for i = 1:nillus - 1
      for j = i + 1:nillus
        CurrentLthUth(i, j) = IllumPairsPlot{i, j}.LowHighAbs(u, l);
        AllByAllLthUthPer(u, l) = AllByAllLthUthPer(u, l) + IllumPairsPlot{i, j}.LowHighPer(u, l);
        AllByAllLthUthAbs(u, l) = AllByAllLthUthAbs(u, l) + IllumPairsPlot{i, j}.LowHighAbs(u, l);
      end
    end
    CurrentLthUth = CurrentLthUth + CurrentLthUth';
    MeanIllumMetamer = mean(CurrentLthUth);
    [SortedAbs, SortedInds] = sort(MeanIllumMetamer, 'descend');
    fprintf(fileid, 'Ranking for lth=[%f] and uth=[%f]\n', lths(l), uths(nuth - u + 1));
    for i = 1:nillus
      fprintf(fileid, '  [%d] ''%s'' %d\n', i, IllumNamesOrder{SortedInds(i)}, SortedAbs(i));
      LthUthRanking{SortedInds(i), ColumnNumber} = i;
      LthUthAbsolute{SortedInds(i), ColumnNumber} = SortedAbs(i);
    end
    fprintf(fileid, '\n');
    
    LthUthRankingHeaders{1, ColumnNumber} = ['lth', num2str(lths(l)), 'uth', num2str(uths(nuth - u + 1))];
    ColumnNumber = ColumnNumber + 1;
  end
end

AllByAllLthUthPer = AllByAllLthUthPer ./ (nillus * (nillus - 1) / 2);
AllByAllLthUthAbs = AllByAllLthUthAbs ./ (nillus * (nillus - 1) / 2);

LthUthReport.LowHighPer = AllByAllLthUthPer;
LthUthReport.LowHighAbs = AllByAllLthUthAbs;
LthUthReport.lths = lths;
LthUthReport.uths = uths;

fclose(fileid);

TableForExcel = [LthUthRankingHeaders; LthUthRanking];
RowNames = cell(nillus + 1, 1);
RowNames(2:end, :) = IllumNamesOrder;
TableForExcel = [RowNames, TableForExcel];

xlswrite(ExcelFileName, TableForExcel, 'LthUthRanking', 'A1');

TableForExcel = [LthUthRankingHeaders; LthUthAbsolute];
RowNames = cell(nillus + 1, 1);
RowNames(2:end, :) = IllumNamesOrder;
TableForExcel = [RowNames, TableForExcel];
xlswrite(ExcelFileName, TableForExcel, 'LthUthAbsolute', 'A1');

end

function PlotAverageSpectra(ResultsFolder, IllumPairsPlot, IllumNamesOrder, nillus, AllSpectraMat)

AverageFolder = [ResultsFolder, 'AverageSpectra', filesep];
if ~exist(AverageFolder, 'dir')
  mkdir(AverageFolder);
end
AllSpectraCounter = 0;
for i = 1:nillus
  CurrentRowCounter = 0;
  for j = 1:nillus
    if i ~= j
      CurrentRowCounter = CurrentRowCounter + IllumPairsPlot{i, j}.AllSpectraCounter;
    end
  end
  PlotMetamersSpectraVector(CurrentRowCounter, AllSpectraMat, [AverageFolder, IllumNamesOrder{i}]);
  AllSpectraCounter = AllSpectraCounter + CurrentRowCounter;
end
% since every element was computed two times
AllSpectraCounter = AllSpectraCounter ./ 2;
PlotMetamersSpectraVector(AllSpectraCounter, AllSpectraMat, [AverageFolder, 'AllIlluminants']);

end
