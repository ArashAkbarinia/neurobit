function AllCrossOvers = ExtractMetamersSpectraCrossOvers(CrossOversReport, WhichLth, WhichUth)
%ExtractMetamersSpectraCrossOvers  extrating the crossovers for specific
%                                  lower and upper thresholds.

if nargin < 2
  WhichLth = [];
end
if nargin < 3
  WhichUth = [];
end

if isempty(WhichLth) && isempty(WhichUth)
  AllCrossOvers = CrossOversReport.all.crossovers(:, 1);
else
  ThresholdNames = fieldnames(CrossOversReport.all.lths);
  nLowThreshes = numel(ThresholdNames);
  nHighThreshes = numel(fieldnames(CrossOversReport.all.lths.th1.uths));
  
  AllCrossOvers = [];
  for i = 1:nLowThreshes
    LowThreshold = CrossOversReport.all.lths.(ThresholdNames{i});
    if isempty(WhichLth) || ismember(LowThreshold.lth, WhichLth)
      for j = 1:nHighThreshes
        HighThreshold = LowThreshold.uths.(['uth', num2str(j)]);
        if isempty(WhichUth) || ismember(HighThreshold.uth, WhichUth)
          if ~isempty(HighThreshold.crossovers)
            crossovers = HighThreshold.crossovers(:, 1);
            AllCrossOvers = [AllCrossOvers; crossovers]; %#ok
          end
        end
      end
    end
  end
end

end
