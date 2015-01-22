function [belonging, distances] = EllipsoidEvaluateBelonging(points, ellipsoid)
%EllipsoidEvaluateBelonging  computes the belonging of each point to the
%                            given ellipsoid.
%
% Inputs
%   points     the input points.
%   ellipsoid  the parameters of the ellipsoid.
%
% Outputs
%   belonging  the belonging value of each point to the ellipsoid.
%   distances  the distance of each point to the ellipsoid.
%

[rows, cols, chns] = size(points);
if chns == 3
  points = reshape(points, rows * cols, chns);
end

CentreX = ellipsoid(1);
CentreY = ellipsoid(2);
CentreZ = ellipsoid(3);
% RSS = ellipsoid(10);

% AxisY = ellipsoid(6);

steepness = 10; % steepness of the sigmoidal transition.

[distances, intersection] = DistanceEllipsoid(points, ellipsoid, 0);

% distances from the centre to the closest points in the ellipse
H = sqrt((intersection(:, 1) - CentreX) .^ 2 + (intersection(:, 2) - CentreY) .^ 2 + (intersection(:, 3) - CentreZ) .^ 2);

% distances from the centre to the points
X = sqrt((points(:, 1) - CentreX) .^ 2 + (points(:, 2) - CentreY) .^ 2 + (points(:, 3) - CentreZ) .^ 2);

% growth rate (width of the sigmoidal section)
% TODO: what should be the growth rate.
G = steepness ./ H;

belonging = 1 ./ (1 + exp(G .* (X - H)));

if chns == 3
  belonging = reshape(belonging, rows, cols, 1);
end

end
