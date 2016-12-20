function LthUthReport = ReportMetamersLthUth(MetamerReport, plotme)
%ReportMetamersLthUth Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
  plotme = false;
end

ThresholdNames = fieldnames(MetamerReport.all.lths);
nLowThreshes = numel(ThresholdNames);
nHighThreshes = numel(fieldnames(MetamerReport.all.lths.th1.uths));

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
  end
end

LthUthReport.LowHighPer = LowHighPer;
LthUthReport.LowHighAbs = LowHighAbs;
LthUthReport.lths = lths;
LthUthReport.uths = uths;

if plotme
  LthUthReport.FigureNumber = figure;
  imagesc(LowHighPer);
  colormap('gray');
  colorbar;
  set(gca, 'XTickLabel', lths);
  set(gca, 'XTick', 1:nLowThreshes);
  set(gca, 'YTickLabel', fliplr(uths));
  set(gca, 'YTick', 1:nHighThreshes);
  xlabel('Low Threshold');
  ylabel('High Threshold');
end

end
