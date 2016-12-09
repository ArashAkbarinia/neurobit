function FigureHandler = PlotMetamersAllIllumMat(PlotMat, FolderPath)
%PlotMetamersAllIllum  plots the metamers results
%   Detailed explanation goes here

if nargin < 2
  FolderPath = '/home/arash/Documents/Software/repositories/neurobit/data/dataset/hsi/results/1931/';
end
IllusMat = load(PlotMat);
illus = IllusMat.illus;

nTops = numel(illus.signal1);
r = nTops;
c = 1 + size(illus.rgbrows, 2);

isvisible = 'on';
name = 'testing';

FigureHandler.m = figure('name', ['metamers signals ', name], 'visible', isvisible, 'pos', [1, 1, 1280, 720]);
% rgb = zeros(size(lab));
% for i = 1:c - 1
%   rgb(:, i, :) = applycform(lab(:, i, :), makecform('lab2srgb', 'AdaptedWhitePoint', wp(i, :)));
% end

PlotInd = 1;
black = reshape([0, 0, 0], 1, 1, 3);

rgbrows = illus.rgbrows;
rgbcols = illus.rgbcols;

for i = 1:nTops
%   row = illus.rows(1);
%   col = illus.cols(1);
  
  set(0, 'CurrentFigure', FigureHandler.m);
  subplot(r, c, PlotInd);
  PlotInd = PlotInd + 1;
  hold on;
   
  signal1 = illus.signal1{i, :};
  signal2 = illus.signal2{i, :};
  wavelength1 = illus.wavelength1{i, :};
  wavelength2 = illus.wavelength2{i, :};
  
  plot(wavelength1, signal1 ./ sum(signal1), 'color', rand(1,3));
  plot(wavelength2, signal2 ./ sum(signal2), 'color', rand(1,3));
  xlim([min(wavelength1(1), wavelength2(1)), max(wavelength1(end), wavelength2(end))]);
  if i == 1
    title('Signals');
  end
  
  for j = 2:c
    subplot(r, c, PlotInd);
    PlotInd = PlotInd + 1;
    image([rgbrows(i, j - 1, :), rgbrows(i, j - 1, :), black, rgbcols(i, j - 1, :), rgbcols(i, j - 1, :)]);
%     if i == 1
%       title(labels{j - 1});
%     end
    axis off;
  end
end

end
