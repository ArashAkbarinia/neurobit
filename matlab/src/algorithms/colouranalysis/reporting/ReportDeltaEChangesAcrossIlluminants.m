function DeltaEReport = ReportDeltaEChangesAcrossIlluminants(IlluminantNames, LabFolder)
%ReportDeltaEChangesAcrossIlluminants Summary of this function goes here
%   Detailed explanation goes here

FunctionPath = mfilename('fullpath');
[~, FunctionName, ~] = fileparts(FunctionPath);
FunctionRelativePath = ['matlab', filesep, 'src', filesep, 'algorithms', filesep, 'colouranalysis', filesep, 'reporting', filesep, FunctionName];

GenDataPath = ['data', filesep, 'dataset', filesep, 'hsi', filesep];

if nargin < 2
  LabFolder = strrep(FunctionPath, FunctionRelativePath, [GenDataPath, 'results', filesep, '1931', filesep, 'lab', filesep]);
end

nillums = numel(IlluminantNames);

labs = struct();
for i = 1:nillums
  LabMat = load([LabFolder, IlluminantNames{i}, '.mat']);
  labs.(IlluminantNames{i}) = LabMat.car;
end

DeltaEReport.de.all = cell(nillums, nillums);
DeltaEReport.de.avg = cell(nillums, nillums);
for i = 1:nillums - 1
  for j = i + 1:nillums
    DeltaEReport.de.all{i, j} = deltae2000(labs.(IlluminantNames{i}), labs.(IlluminantNames{j}));
    DeltaEReport.de.all{j, i} = DeltaEReport.de.all{i, j};
    
    DeltaEReport.de.avg{i, j} = mean(DeltaEReport.de.all{i, j});
    DeltaEReport.de.avg{j, i} = DeltaEReport.de.avg{i, j};
  end
end

nSpectra = size(DeltaEReport.de.all{1, 2}, 1);
AvgDe = zeros(nSpectra, 1);
MaxDe = zeros(nSpectra, 1);
MinDe = inf(nSpectra, 1);

MaxInds = zeros(nSpectra, 2);
MinInds = zeros(nSpectra, 2);
for i = 1:nillums - 1
  for j = i + 1:nillums
    AvgDe = AvgDe + DeltaEReport.de.all{i, j};
    MaxDe = max(MaxDe, DeltaEReport.de.all{i, j});
    MinDe = min(MinDe, DeltaEReport.de.all{i, j});
    
    CurrentMaxInds = MaxDe == DeltaEReport.de.all{i, j};
    MaxInds1 = MaxInds(:, 1);
    MaxInds1(CurrentMaxInds) = i;
    MaxInds(:, 1) = MaxInds1;
    
    MaxInds2 = MaxInds(:, 2);
    MaxInds2(CurrentMaxInds) = j;
    MaxInds(:, 2) = MaxInds2;
    
    CurrentMinInds = MinDe == DeltaEReport.de.all{i, j};
    MinInds1 = MinInds(:, 1);
    MinInds1(CurrentMinInds) = i;
    MinInds(:, 1) = MinInds1;
    
    MinInds2 = MinInds(:, 2);
    MinInds2(CurrentMinInds) = j;
    MinInds(:, 2) = MinInds2;
  end
end

AvgDe = AvgDe ./ ((nillums * (nillums - 1)) / 2);

DeltaEReport.stats.avg = AvgDe;
DeltaEReport.stats.max = MaxDe;
DeltaEReport.stats.maxinds = MaxInds;
DeltaEReport.stats.min = MinDe;
DeltaEReport.stats.mininds = MinInds;

end
