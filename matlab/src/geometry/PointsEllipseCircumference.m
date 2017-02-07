function points = PointsEllipseCircumference(ellipse, nPoints)
%PointsEllipseCircumference  computing points on circumference of ellipse.
%
% inputs
%  ellipse  five parameters ellipse.
%  nPoints  number of points on the circumference, default 36.
%
% outputs
%   points  [x coordinates, y coordinates].
%

if nargin < 2
  nPoints = 36;
end

cx = ellipse(1);
cy = ellipse(2);
ax = ellipse(3);
ay = ellipse(4);
rx = ellipse(5);

crx = cos(rx);
srx = sin(rx);
theta = linspace(0, 2 * pi, nPoints);
cth = cos(theta);
sth = sin(theta);
points(:, 1) = ax * cth * crx - srx * ay * sth +cx;
points(:, 2) = ax * cth * srx + crx * ay * sth + cy;

end
