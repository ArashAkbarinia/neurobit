function MetamerReport = MetamerAnalysisColourDifferences(lab, threshold, do1976, do1994, do2000)
%MetamerAnalysisColourDifferences Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
  threshold = 0.5;
end
if nargin < 3
  do1976 = true;
  do1994 = true;
  do2000 = true;
end

nSignals = size(lab, 1);
lab = reshape(lab, nSignals, 3);
if do1976
  MetamerReport.m1976.CompMat = zeros(nSignals, nSignals);
end
if do1994
  MetamerReport.m1994.CompMat = zeros(nSignals, nSignals);
end
if do2000
  MetamerReport.m2000.CompMat = zeros(nSignals, nSignals);
end

for i = 1:nSignals
  RowI = repmat(lab(i, :), [nSignals, 1]);
  if do1976
    MetamerReport.m1976.CompMat(i, :) = deltae1976(RowI, lab);
  end
  if do1994
    MetamerReport.m1994.CompMat(i, :) = deltae1994(RowI, lab);
  end
  if do2000
    MetamerReport.m2000.CompMat(i, :) = deltae2000(RowI, lab);
  end
end

if do1976
  MetamerReport.m1976.metamers = MetamerReport.m1976.CompMat < threshold;
  MetamerReport.m1976.metamers(logical(eye(size(MetamerReport.m1976.metamers)))) = 0;
end
if do1994
  MetamerReport.m1994.metamers = MetamerReport.m1994.CompMat < threshold;
  MetamerReport.m1994.metamers(logical(eye(size(MetamerReport.m1994.metamers)))) = 0;
end
if do2000
  MetamerReport.m2000.metamers = MetamerReport.m2000.CompMat < threshold;
  MetamerReport.m2000.metamers(logical(eye(size(MetamerReport.m2000.metamers)))) = 0;
end

end
