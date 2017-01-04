function [AllCrossOvers, FigureHandler] = PlotMetamersSpectraCrossOvers(CrossOversReport, WhichLth, WhichUth, NormaliseByAllCrossOvers)
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

if isstruct(CrossOversReport)
  AllCrossOvers = ExtractMetamersSpectraCrossOvers(CrossOversReport, WhichLth, WhichUth);
else
  AllCrossOvers = CrossOversReport;
end

TotalCrossOvers = size(AllCrossOvers, 1);
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
AllCrossOvers = r ./ sum(r);

if nargout > 1
  FigureHandler = figure('name', 'histogram of crossovers');
end
plot(WavelengthRange(1:end - 1), AllCrossOvers, 'DisplayName', ['T: ', num2str(TotalCrossOvers)]);
legend('show');
xlim([sw, ew]);

end
