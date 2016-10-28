function FigureHandler = PlotTopMetamers(MetamerDiff, signals, nTops, wavelength)
%PlotTopMetamers  plots each metamer group into a subplot.
%
% inputs
%   MetamerDiff  the distance of metamers in any units.
%   signals      corresponding signals.
%   nTops        number of top signals to be drawn.
%   wavelength   the wavelength range of signals.
%
% outputs
%   FigureHandler  the figure handler.
%

if nargin < 3
  nTops = 9;
end
if nargin < 4
  wavelength = 1:size(signals, 1);
end

MetamersDis = MetamerDiff.SgnlDiffs;
MetamersDis(MetamerDiff.metamers == 0) = 0;
MetamersDis(isinf(MetamersDis)) = 0;

UniqueDistances = sort(unique(MetamersDis(:)), 'descend');
UniqueDistances = UniqueDistances(UniqueDistances > 0);
if UniqueDistances == 0
  FigureHandler = [];
  return;
end
nTops = min(nTops, length(UniqueDistances));
r = round(sqrt(nTops));
c = ceil(sqrt(nTops));

FigureHandler = figure('name', 'most different metamers');
for i = 1:nTops
  [row, col] = find(MetamersDis == UniqueDistances(i));
  row = row(1);
  col = col(1);
  subplot(r, c, i);
  hold on;
  plot(wavelength, signals(:, row) ./ sum(signals(:, row)), 'color', rand(1,3));
  plot(wavelength, signals(:, col) ./ sum(signals(:, col)), 'color', rand(1,3));
  xlim([wavelength(1), wavelength(end)]);
end

end
