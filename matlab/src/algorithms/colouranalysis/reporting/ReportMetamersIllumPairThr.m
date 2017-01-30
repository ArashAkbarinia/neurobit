function AllIllumPairReport = ReportMetamersIllumPairThr(IlluminantPairReport, lth, uth)
%ReportMetamersIllumPairThr Summary of this function goes here
%   Detailed explanation goes here

nillums = size(IlluminantPairReport.IllumPairsPlot, 1);
AllIllumPairReport.abs = zeros(nillums, nillums);

lths = IlluminantPairReport.lths;
uths = IlluminantPairReport.uths;

WhichLth = ismember(lths, lth) == 1;
% the flipping is beause LowHighAbs and LowHighPer the x axis is reverse
% (low values in the last rows)
WhichUth = fliplr(ismember(uths, uth)) == 1;

for i = 1:nillums
  for j = 1:nillums
    if i == j
      continue;
    end
    AllIllumPairReport.abs(i, j) = IlluminantPairReport.IllumPairsPlot{i, j}.LowHighAbs(WhichUth, WhichLth);
    AllIllumPairReport.diff.med(i, j) = IlluminantPairReport.DiffReports{i, j}.med;
    AllIllumPairReport.diff.avg(i, j) = IlluminantPairReport.DiffReports{i, j}.avg;
  end
end

AllIllumPairReport.per = AllIllumPairReport.abs ./ IlluminantPairReport.nPossiblePairs;

end
