function FigureHandler = PlotMetamersSpectraCrossOvers(CrossOversReport, WhichLth, WhichUth, NormaliseByAllCrossOvers)
%PlotMetamersSpectraCrossOvers Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
  WhichLth = [];
end
if nargin < 3
  WhichUth = [];
end
if nargin < 4
  NormaliseByAllCrossOvers = true;
end

%TODO: I should have written these numbers in mat file for generality
sw = 400;
step = 10;
ew = 699;
WavelengthRange = sw:step:ew;

FigureHandler = figure('name', 'histogram of crossovers');

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

m = histcounts(AllCrossOvers, WavelengthRange, 'Normalization', 'Probability');
if NormaliseByAllCrossOvers
  FunctionPath = mfilename('fullpath');
  [~, FunctionName, ~] = fileparts(FunctionPath);
  FunctionRelativePath = ['matlab', filesep, 'src', filesep, 'algorithms', filesep, 'colouranalysis', filesep, 'plotting', filesep, FunctionName];
  
  DataPath = ['matlab', filesep, 'data', filesep, 'mats', filesep, 'hsi', filesep];
  
  RandimHistPairsPath = strrep(FunctionPath, FunctionRelativePath, [DataPath, 'RandomPairHists.mat']);
  RandimHistPairs = load(RandimHistPairsPath);
  r = m ./ RandimHistPairs.hists.(['bin', num2str(step)]);
else
  r = m;
end
plot(WavelengthRange(1:end - 1), r);
xlim([sw, ew]);

end
