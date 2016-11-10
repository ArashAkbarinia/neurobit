function MetamerReport = MetamerAnalysisColourDifferences(lab)
%MetamerAnalysisColourDifferences Summary of this function goes here
%   Detailed explanation goes here

nSignals = size(lab, 1);
lab = reshape(lab, nSignals, 3);
CompMat1976 = zeros(nSignals, nSignals);
CompMat1994 = zeros(nSignals, nSignals);
CompMat2000 = zeros(nSignals, nSignals);
for i = 1:nSignals
  RowI = repmat(lab(i, :), [nSignals, 1]);
  CompMat1976(i, :) = deltae1976(RowI, lab);
  CompMat1994(i, :) = deltae1994(RowI, lab);
  CompMat2000(i, :) = deltae2000(RowI, lab);
end

MetamerReport.m1976.CompMat = CompMat1976;
MetamerReport.m1994.CompMat = CompMat1994;
MetamerReport.m2000.CompMat = CompMat2000;
MetamerReport.mall.CompMat = (CompMat1976 + CompMat1994 + CompMat2000) / 3;

threshold = 0.5;
MetamerReport.m1976.metamers = CompMat1976 < threshold;
MetamerReport.m1976.metamers(logical(eye(size(MetamerReport.m1976.metamers)))) = 0;
MetamerReport.m1994.metamers = CompMat1994 < threshold;
MetamerReport.m1994.metamers(logical(eye(size(MetamerReport.m1994.metamers)))) = 0;
MetamerReport.m2000.metamers = CompMat2000 < threshold;
MetamerReport.m2000.metamers(logical(eye(size(MetamerReport.m2000.metamers)))) = 0;
MetamerReport.mall.metamers = CompMat1976 < threshold & CompMat1994 < threshold & CompMat2000 < threshold;
MetamerReport.mall.metamers(logical(eye(size(MetamerReport.mall.metamers)))) = 0;

end
