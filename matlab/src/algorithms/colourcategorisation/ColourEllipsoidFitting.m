function RSS = ColourEllipsoidFitting(x, FittingData)
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

RSS = FitData(FittingData.borders, x);

end

function RSS = FitData(data, x)

if ~isempty(data)
  RSS = norm_points_to_ellipse(data, x);
else
  RSS = 0;
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
