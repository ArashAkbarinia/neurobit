function FigureHandler = PlotMetamersOnHueCircle(MetamerReport, LabFolder)
%PlotMetamersOnHueCircle Summary of this function goes here
%   Detailed explanation goes here

FunctionPath = mfilename('fullpath');
[~, FunctionName, ~] = fileparts(FunctionPath);
FunctionRelativePath = ['matlab', filesep, 'src', filesep, 'algorithms', filesep, 'colouranalysis', filesep, 'plotting', filesep, FunctionName];

GenDataPath = ['data', filesep, 'dataset', filesep, 'hsi', filesep];

if nargin < 2
  LabFolder = strrep(FunctionPath, FunctionRelativePath, [GenDataPath, 'results', filesep, '1931', filesep, 'lab', filesep]);
end

pols = struct();
nillum = numel(MetamerReport.illuminants);
AllPairs = struct();
for i = 1:nillum
  IllumName = MetamerReport.illuminants{i};
  LabVals = load([LabFolder, IllumName]);
  pols.(IllumName) = LabVals.pol;
  AllPairs.(IllumName) = [];
end

ThresholdNames = fieldnames(MetamerReport.all.lths);
nLowThreshes = numel(ThresholdNames);

nHighThreshes = numel(fieldnames(MetamerReport.all.lths.th1.uths));

for i = 1:nLowThreshes
  LowThreshold = MetamerReport.all.lths.(ThresholdNames{i});
  for j = 1:nHighThreshes
    HighThreshold = LowThreshold.uths;
    MetamerPairs = HighThreshold.(['uth', num2str(j)]).metamerpairs;
    for l = 1:nillum
      IllumName = MetamerReport.illuminants{l};
      CurrentPols = pols.(IllumName);
      AllPairs.(IllumName) = [AllPairs.(IllumName); CurrentPols(MetamerPairs(:, 1), 1), CurrentPols(MetamerPairs(:, 1), 2)];
    end
  end
end

% computing the histogram
nbins = 20;
tmet = zeros(nillum, nbins * 4);
rmet = zeros(nillum, nbins * 4);
torg = zeros(nillum, nbins * 4);
rorg = zeros(nillum, nbins * 4);
for l = 1:nillum
  IllumName = MetamerReport.illuminants{l};
  [tmet(l, :), rmet(l, :)] = rose(AllPairs.(IllumName)(:, 1), nbins);
  rmet(l, :) = rmet(l, :) ./ sum(rmet(l, :));
  
  [torg(l, :), rorg(l, :)] = rose(pols.(IllumName)(:, 1), nbins);
  rorg(l, :) = rorg(l, :) ./ sum(rorg(l, :));
end

FigureHandler = figure('name', 'metamers on hue circle');
MaxRadius = max(rmet(:));
for l = 1:nillum
  subplot(2, nillum, l);
  DrawHueCircle(MaxRadius);
  hold on;
  polar(tmet(l, :), rmet(l, :), 'black');
  title([MetamerReport.illuminants{l}, ' Metamer distribution']);
  
  subplot(2, nillum, l + nillum);
  DrawHueCircle(MaxRadius);
  hold on;
  polar(torg(l, :), rorg(l, :), 'black');
  title([MetamerReport.illuminants{l}, ' Original distribution']);
end

end
