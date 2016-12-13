function FigureHandler = PlotMetamersAllIllumMat(PlotMat, isvisible)
%PlotMetamersAllIllum  plots the metamers results saved in the mat fotmat.

[~, FigureName, ~] = fileparts(PlotMat);

IllusMat = load(PlotMat);
illus = IllusMat.illus;

nTops = numel(illus.signal1);
r = nTops;
c = 1 + size(illus.rgbrows, 2);

if nargin < 2
  isvisible = 'on';
end

FigureHandler.m = figure('name', FigureName, 'visible', isvisible, 'pos', [1, 1, 1280, 720]);

PlotInd = 1;
black = reshape([0, 0, 0], 1, 1, 3);

rgbrows = illus.rgbrows;
rgbcols = illus.rgbcols;

for i = 1:nTops
  set(0, 'CurrentFigure', FigureHandler.m);
  subplot(r, c, PlotInd);
  PlotInd = PlotInd + 1;
  hold on;
  
  signal1 = illus.signal1{i, :};
  signal2 = illus.signal2{i, :};
  wavelength1 = illus.wavelength1{i, :};
  wavelength2 = illus.wavelength2{i, :};
  
  plot(wavelength1, signal1 ./ max(signal1), 'color', rand(1,3));
  plot(wavelength2, signal2 ./ max(signal2), 'color', rand(1,3));
  
  % plotting just over the visible spectrum
  xlim([400, 700]);
  if i == 1
    title('Signals');
  end
  
  for j = 2:c
    subplot(r, c, PlotInd);
    PlotInd = PlotInd + 1;
    image([rgbrows(i, j - 1, :), rgbrows(i, j - 1, :), black, rgbcols(i, j - 1, :), rgbcols(i, j - 1, :)]);
    if i == 1
      title(illus.labels{j - 1});
    end
    axis off;
  end
end

end
