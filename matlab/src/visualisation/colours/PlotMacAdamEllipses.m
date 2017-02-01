function FigureHandler = PlotMacAdamEllipses()
%PlotMacAdamEllipses  plotting MacAdam ellipses in the chromatic space.
%
% outputs
%  FigureHandler  Matlab figure object.
%

FunctionPath = mfilename('fullpath');
[~, FunctionName, ~] = fileparts(FunctionPath);
FunctionRelativePath = ['src', filesep, 'visualisation', filesep, 'colours', filesep, FunctionName];
WcsRelativePath = ['data', filesep, 'mats', filesep, 'visualisation', filesep, 'colours', filesep, 'MacAdamEllipses.mat'];
FilePath = strrep(FunctionPath, FunctionRelativePath, WcsRelativePath);

MacAdamPath = load(FilePath);
MacAdamEllipses = MacAdamPath.MacAdamEllipses;

% otherwise they're too small and not visually prominent
MacAdamEllipses(:, 3:4) = MacAdamEllipses(:, 3:4) .* 10;

FigureHandler = figure;

PlotCieXyLocus();
hold on;

nEllipses = size(MacAdamEllipses, 1);

for i = 1:nEllipses
  DrawEllipse(MacAdamEllipses(i, :), 'color', 'black');
  
  [a1, a2, b1, b2] = PointsEllipseAxes(MacAdamEllipses(i, :));
  plot([a1(1), a2(1)], [a1(2), a2(2)], 'black');
  plot([b1(1), b2(1)], [b1(2), b2(2)], 'black');
end

end
