function belonging = EllipsoidEvaluateBelonging(lsY_points, ellipsoid)
%EllipsoidEvaluateBelonging Summary of this function goes here
%   Detailed explanation goes here

CentreL = ellipsoid(1);
CentreS = ellipsoid(2);
CentreY = ellipsoid(3);
RSS = ellipsoid(10);

AxisY = ellipsoid(6);

steepness = 10 / AxisY; % steepness of the sigmoidal transition.

[~, intersection] = DistanceEllipsoid(lsY_points, ellipsoid, 0);


do_belong = (abs(lsY_points(:, 3)) <= AxisY);

% distances from the centre to the closest points in the ellipse
H = sqrt((intersection(:, 1) - CentreL) .^ 2 + (intersection(:, 2) - CentreS) .^ 2 + (intersection(:, 3) - CentreY) .^ 2);

% distances from the centre to the lsY points
X = sqrt((lsY_points(:, 1) - CentreL) .^ 2 + (lsY_points(:, 2) - CentreS) .^ 2 + (lsY_points(:, 3) - CentreY) .^ 2);

% growth rate (width of the sigmoidal section)
G = steepness / sqrt(RSS);

belonging =  1 ./ (1 + exp(G .* (X - H)));
belonging = belonging .* do_belong;

end
