function h = PlotTopMetamers(MetamerDiff, signal, n, wavelength)
%PlotTopMetamers Summary of this function goes here
%   Detailed explanation goes here

if nargin < 3
  n = 9;
end
if nargin < 4
  wavelength = 1:size(signal, 1);
end

MetamersDis = MetamerDiff.SgnlDiffs;
MetamersDis(MetamerDiff.metamers == 0) = 0;

a = sort(unique(MetamersDis(:)), 'descend');
r = floor(sqrt(n));
c = ceil(sqrt(n));

h = figure('name', 'most different metamers');
for i = 1:n
  [row, col] = find(MetamersDis == a(i));
  row = row(1);
  col = col(1);
  subplot(r, c, i);
  hold on
  plot(wavelength, signal(:, row) ./ max(signal(:, row)), 'color', rand(1,3), 'LineWidth', 2);
  plot(wavelength, signal(:, col) ./ max(signal(:, col)), 'color', rand(1,3), 'LineWidth', 2);
  xlim([wavelength(1), wavelength(end)]);
end

end
