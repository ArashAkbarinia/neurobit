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

MetamerReport.CompMat1976 = CompMat1976;
MetamerReport.CompMat1994 = CompMat1994;
MetamerReport.CompMat2000 = CompMat2000;

MetamerReport.metamers = CompMat1976 < 0.5 & CompMat1994 < 0.5 & CompMat2000 < 0.5;

nAll = (sum(MetamerReport.metamers(:)) - nSignals) / 2;
disp(['Metamer percentage: ', num2str(nAll / ((nSignals * (nSignals - 1)) / 2))]);

end
