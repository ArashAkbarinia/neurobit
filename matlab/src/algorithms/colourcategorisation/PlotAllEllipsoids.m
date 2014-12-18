function [] = PlotAllEllipsoids(FilePath)
%PlotAllEllipsoids Summary of this function goes here
%   Detailed explanation goes here

MatFile = load(FilePath);
ellipsoids = MatFile.ellipsoids;
rgbs = MatFile.RGBValues;

figure('NumberTitle', 'Off', 'Name', 'Colour Categorisation - Ellipsoids');
for i = 1:size(ellipsoids, 1)
  DrawEllipsoid(ellipsoids(i, :), 'FaceColor', [1, 1, 1], 'EdgeColor', rgbs(i, :), 'FaceAlpha', 0.3);
  hold on;
end

end
