function LthUthReport = ReportMetamersAveragePairResults(IlluminantPairReport)
%ReportMetamersAveragePairResults Summary of this function goes here
%   Detailed explanation goes here

nIllums = numel(IlluminantPairReport.IllumNamesOrder);

nuth = size(IlluminantPairReport.uths, 2);
nlth = size(IlluminantPairReport.lths, 2);
AvgLowHighAbs = zeros(nuth, nlth);
MaxLowHighAbs = zeros(nuth, nlth);
MinLowHighAbs = inf(nuth, nlth);

MaxInds = zeros(nuth, nlth, 2);
MinInds = zeros(nuth, nlth, 2);

nSpectra = size(IlluminantPairReport.IllumPairsPlot{1, 2}.AllSpectraCounter, 1);
nPixels = nSpectra * (nSpectra - 1) / 2;

for i = 1:nIllums
  for j = 1:nIllums
    if i == j
      continue;
    end
    AvgLowHighAbs = AvgLowHighAbs + IlluminantPairReport.IllumPairsPlot{i, j}.LowHighAbs;
    MaxLowHighAbs = max(MaxLowHighAbs, IlluminantPairReport.IllumPairsPlot{i, j}.LowHighAbs);
    MinLowHighAbs = min(MinLowHighAbs, IlluminantPairReport.IllumPairsPlot{i, j}.LowHighAbs);
    
    CurrentMaxInds = MaxLowHighAbs == IlluminantPairReport.IllumPairsPlot{i, j}.LowHighAbs;
    MaxInds1 = MaxInds(:, :, 1);
    MaxInds1(CurrentMaxInds) = i;
    MaxInds(:, :, 1) = MaxInds1;
    
    MaxInds2 = MaxInds(:, :, 2);
    MaxInds2(CurrentMaxInds) = j;
    MaxInds(:, :, 2) = MaxInds2;
    
    CurrentMinInds = MinLowHighAbs == IlluminantPairReport.IllumPairsPlot{i, j}.LowHighAbs;
    MinInds1 = MinInds(:, :, 1);
    MinInds1(CurrentMinInds) = i;
    MinInds(:, :, 1) = MinInds1;
    
    MinInds2 = MinInds(:, :, 2);
    MinInds2(CurrentMinInds) = j;
    MinInds(:, :, 2) = MinInds2;
  end
end

AvgLowHighAbs = AvgLowHighAbs ./ (nIllums * (nIllums - 1));

LthUthReport.avg.LowHighAbs = AvgLowHighAbs;
LthUthReport.avg.LowHighPer = AvgLowHighAbs ./ nPixels;

LthUthReport.max.LowHighAbs = MaxLowHighAbs;
LthUthReport.max.LowHighPer = MaxLowHighAbs ./ nPixels;
LthUthReport.max.inds = MaxInds;

LthUthReport.min.LowHighAbs = MinLowHighAbs;
LthUthReport.min.LowHighPer = MinLowHighAbs ./ nPixels;
LthUthReport.min.inds = MinInds;

end
