function RSS = ColourEllipsoidFitting(x, plotme, FittingData, FittingParams)
% Describe the function
% This function does the actual fitting of the three level datapoints
% obtained by variables data36 data58 and data81 and the 3D-ellipsoid.
% The datapoints correspond to the psychophysical results obtained through
% colour categorization experiments in the frontiers between colour names.
% The ellipsoid parameters are passed to the funtion though the variable x
% which contains the centre and the semi-axes of the 3D-ellipsoid to fit to
% the data. Imagine the ellipsoid as a rugby ball placed with its main axis
% vertically. It intersects the three horizontal dataplanes (at three
% luminance levels) forming three horizontal ellipses.
% The actual fitting is done considering the distance between each
% point in the luminance data plane and the closest point on the ellipse
% for each plane. The output of this function is the residual
% sum of squares (RSS) of these distances, added for the three planes.
% Since the data in the lowest luminance plane has the largest variance, it
% tends to bias the fitting. To counter this, we weighted the RSS
% corresponding to each luminance plane.

if nargin < 2
  plotme = 0;
end

RSS = FitData(FittingData.borders, 0, x);

end

function RSS = FitData(data, ylevel, x)

% TODO: if speed matters we pass some of the parameters to the function

if ~isempty(data)
  RSS = norm_points_to_ellipse(data, x);
else
  RSS = 0;
end

end

function [] = PlotData(data, ylevel, kolor, x)

if ~isempty(data)
  center = x(1:3);
  radii = x(4:6);
  Angle_rad = x(7);
  curradii(:,1:2) = real(radii(:,1:2).* (sqrt(1-((ylevel - center(3))./radii(3))^2)));
  [x1, y1] = alej_ellipse(center(1), center(2), curradii(1), curradii(2), Angle_rad) ;
  z1 = ylevel * ones(size(x1,1));
  plot3(data(:, 1), data(:, 2), data(:, 3), '.', 'Color', kolor * kfactor);
  hold on;
  plot3(x1, y1, z1, 'LineWidth', 3);
  hold on;
end

end

function [carryon, PlotAxes] = DoSomething(FittingData, x, FittingParams)

center = x(1:3);
radii = x(4:6);

carryon = 1;

PlotAxes = [0.55 0.85 -0.1 0.2 0 300];
if sum(radii > FittingParams.AxesDeviation .* FittingData.allstd) || sum(radii > FittingParams.MaxAxes)
  carryon = 0;
elseif sum(abs(center- FittingParams.EstimatedCentre) > FittingParams.CentreDeviation .* FittingData.allstd) || sum(center < FittingParams.MinCentre)
  carryon = 0;
end

end

function RSS = norm_points_to_ellipse(XY, ParG, plotme)

if nargin < 3
  plotme = 0;
end

distances = DistanceEllipsoid(XY, ParG, plotme);
%  The Frobenius norm, sometimes also called the Euclidean norm (which may
%  cause confusion with the vector L^2-norm which also sometimes known as
%  the Euclidean norm), is matrix norm of an min matrix  A defined as the
%  square root of the sum of the absolute squares of its elements
%   RSS = norm(distances, 'fro');
RSS = mean(distances);

end
