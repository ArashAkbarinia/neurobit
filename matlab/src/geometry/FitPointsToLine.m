function [LineCoeffs, EucDis] = FitPointsToLine(points, plotme)
%FitPointsToLine  fits a set of points to a line and calculates distance.
%
% inputs
%   points  vector of points.
%   plotme  if passes as true the points and the line is plotted, by
%           default is false.
%
% outputs
%   LineCoeffs  the coefficients of the fitted line.
%   EucDis      euclidean distance of each point to the line.
%

if nargin < 2
  plotme = 0;
end

x = points(:, 1);
y = points(:, 2);

LineCoeffs = polyfit(x, y, 1);

if plotme
  figure;
  hold on;
  plot(x, y, 'b*');
  
  % get fitted values
  x1 = linspace(min(x), max(x), 200);
  y1 = polyval(LineCoeffs, x1);
  % plot the fitted line
  plot(x1, y1, 'r-');
end

EucDis = DistanceLine(a, b, points);

end
