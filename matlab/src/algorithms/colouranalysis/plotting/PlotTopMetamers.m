function FigureHandler = PlotTopMetamers(MetamerDiff, signals, nTops, wavelength, lab, name, wp, ResultDirectory)
%PlotTopMetamers  plots each metamer group into a subplot.
%
% inputs
%   MetamerDiff  the distance of metamers in any units.
%   signals      corresponding signals.
%   nTops        number of top signals to be drawn.
%   wavelength   the wavelength range of signals.
%   lab          the L*a*b* values optinally to be plotted.
%
% outputs
%   FigureHandler  the figure handler.
%

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
r = round(sqrt(nTops));
c = ceil(sqrt(nTops));

FigureHandler.m = figure('name', ['metamers signals ', name], 'visible', isvisible, 'pos',[1, 1, 2001 2001]);
if ~isempty(lab)
  FigureHandler.r = figure('name', ['metamers RGBs ', name ], 'visible', isvisible, 'pos',[1, 1, 2001 2001]);
  rgb = applycform(lab, makecform('lab2srgb', 'AdaptedWhitePoint', wp));
end
black = reshape([0, 0, 0], 1, 1, 3);
for i = 1:nTops
  [row, col] = find(MetamersDis == UniqueDistances(i));
  row = row(1);
  col = col(1);
  set(0, 'CurrentFigure', FigureHandler.m);
  subplot(r, c, i);
  hold on;
  plot(wavelength, signals(:, row) ./ sum(signals(:, row)), 'color', rand(1,3));
  plot(wavelength, signals(:, col) ./ sum(signals(:, col)), 'color', rand(1,3));
  xlim([wavelength(1), wavelength(end)]);
  if ~isempty(lab)
    set(0, 'CurrentFigure', FigureHandler.r);
    subplot(r, c, i);
    image([rgb(row, :, :), rgb(row, :, :), black, rgb(col, :, :), rgb(col, :, :)]);
    axis off;
  end
end

if ~isempty(ResultDirectory)
  saveas(FigureHandler.m, [ResultDirectory, '/MetamerSignals-', name, '.jpg']);
  close(FigureHandler.m);
  if ~isempty(lab)
    saveas(FigureHandler.r, [ResultDirectory, '/MetamerColours-', name, '.jpg']);
    close(FigureHandler.r);
  end
end

end
