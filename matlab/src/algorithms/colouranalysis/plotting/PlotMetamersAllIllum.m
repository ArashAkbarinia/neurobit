function FigureHandler = PlotMetamersAllIllum(MetamerDiff, signals, nTops, wavelength, lab, name, wp, ResultDirectory, labels)
%PlotMetamersAllIllum  plots the metamers results
%   Detailed explanation goes here

if nargin < 3
  nTops = 9;
end
if nargin < 4 || isempty(wavelength)
  wavelength = 1:size(signals, 1);
end
if nargin < 5
  lab = [];
end
if nargin < 6
  name = '';
end
if nargin < 7
  wp = whitepoint('d65');
end
if nargin < 8
  ResultDirectory = [];
end
if nargin < 9
  labels = {};
end

if isempty(ResultDirectory)
  isvisible = 'on';
else
  isvisible = 'off';
end

MetamersDis = MetamerDiff.SgnlDiffs;
MetamersDis(MetamerDiff.metamers == 0) = -1;
MetamersDis(isinf(MetamersDis)) = -1;

UniqueDistances = sort(unique(MetamersDis(:)), 'descend');
UniqueDistances = UniqueDistances(UniqueDistances >= 0);
if UniqueDistances == 0
  FigureHandler = [];
  return;
end
nTops = min(nTops, length(UniqueDistances));
r = nTops;
c = 1 + size(lab, 2);

FigureHandler.m = figure('name', ['metamers signals ', name], 'visible', isvisible, 'pos', [1, 1, 1280, 720]);
rgb = zeros(size(lab));
for i = 1:c - 1
  rgb(:, i, :) = applycform(lab(:, i, :), makecform('lab2srgb', 'AdaptedWhitePoint', wp(i, :)));
end

PlotInd = 1;
black = reshape([0, 0, 0], 1, 1, 3);
for i = 1:nTops
  [row, col] = find(MetamersDis == UniqueDistances(i));
  row = row(1);
  col = col(1);
  set(0, 'CurrentFigure', FigureHandler.m);
  subplot(r, c, PlotInd);
  PlotInd = PlotInd + 1;
  hold on;
  if ~iscell(wavelength)
    wavelength1 = wavelength;
    wavelength2 = wavelength;
    signal1 = signals(row, :, :);
    signal2 = signals(col, :, :);
  else
    wavelength1 = wavelength{row, :};
    wavelength2 = wavelength{col, :};
    signal1 = signals{row, :, :};
    signal2 = signals{col, :, :};
  end
  
  signal1 = reshape(signal1, size(signal1, 3), 1);
  signal2 = reshape(signal2, size(signal2, 3), 1);
  
  plot(wavelength1, signal1 ./ sum(signal1), 'color', rand(1,3));
  plot(wavelength2, signal2 ./ sum(signal2), 'color', rand(1,3));
  xlim([min(wavelength1(1), wavelength2(1)), max(wavelength1(end), wavelength2(end))]);
  if i == 1
    title('Signals');
  end
  
  for j = 2:c
    subplot(r, c, PlotInd);
    PlotInd = PlotInd + 1;
    image([rgb(row, j - 1, :), rgb(row, j - 1, :), black, rgb(col, j - 1, :), rgb(col, j - 1, :)]);
    if i == 1
      title(labels{j - 1});
    end
    axis off;
  end
end

if ~isempty(ResultDirectory)
  saveas(FigureHandler.m, [ResultDirectory, '/MetamerSignals-', name, '.jpg']);
  close(FigureHandler.m);
end

end
