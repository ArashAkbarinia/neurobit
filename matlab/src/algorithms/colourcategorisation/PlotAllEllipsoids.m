function [] = PlotAllEllipsoids(varargin)
%PlotAllEllipsoids plotting all the ellipsoids from different inputs
%

FigureNumber = 0;

if ischar(varargin{1})
  MatFile = load(varargin{1});
  ellipsoids = MatFile.ellipsoids;
  rgbs = MatFile.RGBValues;
  if nargin == 2
    FigureNumber = varargin{2};
  end
else
  ellipsoids = varargin{1};
  rgbs = varargin{2};
  if nargin == 3
    FigureNumber = varargin{3};
  end
end

if FigureNumber == 0
  figure('NumberTitle', 'Off', 'Name', 'Colour Categorisation - Ellipsoids');
else
  figure(FigureNumber);
end
for i = 1:size(ellipsoids, 1)
  DrawEllipsoid(ellipsoids(i, :), 'FaceColor', [1, 1, 1], 'EdgeColor', rgbs(i, :), 'FaceAlpha', 0.3);
  hold on;
end

end
