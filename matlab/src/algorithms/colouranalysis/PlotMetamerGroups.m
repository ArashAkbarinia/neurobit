function FigureHandler = PlotMetamerGroups(MetamerGroups, signals, wavelength)
%PlotMetamerGroups  plots each metamer group into a subplot.
%
% inputs
%   MetamerGroups  the indeces of metamer groups.
%   signals        corresponding signals.
%   wavelength     the wavelength range of signals.
%
% outputs
%   FigureHandler  the figure handler.
%

UniqueMetamers = unique(MetamerGroups(MetamerGroups > 0));
nGroups = sum(UniqueMetamers > 0);

if nargin < 3
  wavelength = 1:size(signals, 1);
end

r = round(sqrt(nGroups));
c = ceil(sqrt(nGroups));

FigureHandler = figure('name', 'metamer groups');
for i = 1:nGroups
  rows = find(MetamerGroups == UniqueMetamers(i));
  subplot(r, c, i);
  hold on;
  for j = 1:length(rows)
    row = rows(j);
    plot(wavelength, signals(:, row) ./ max(signals(:, row)), 'color', rand(1, 3));
  end
  xlim([wavelength(1), wavelength(end)]);
end

end
