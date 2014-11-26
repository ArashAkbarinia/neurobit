% This function receives a list of N lsY points, the parameters of the
% ellipsoid that we want to consider (lsY_centre, abc_centre), the
% uncertainty associated with each of the dimensions of this ellipsoid and
% outputs a list of N "belonging" coefficients, one for each of the points
% Parameters:
% lsY_points: nx3 vector containing the points in lsY space to evaluate;
% cl, cs, cY: centre of the corresponding ellipsois;
% a, b, c: semi-axes of the ellipsoid;
% grl, grs, grY: grwth rate of the logistics function considered (it should
% correlate to the "error" of the measurements in each dimension.
% We estimate the degree of "belonging" to the category by means of a
% Logistics sigmoid in each of the three dimensions separately
% (http://en.wikipedia.org/wiki/Generalized_logistic_curve)
% If points are close to the centre of the ellipsoid, the GS will assign
% them a value of 1, if they are close to the border of the sigmoid, they
% will be given a value of 0.5 and if they are outside they will be zero.
% The contribution of the three components of the logistics function in
% l, s, and Y coordinates was considered via a Minkowsky sum with exponent
% mink. This is basically arbitrary and should be decided based on some
% criterion.
% Output: nx1 vector where each number corresponds to the probability of
% each lsY_points element belonging to the category considered.

% FIXME: why are we here in 3D and in point_to_ellipse in 2D.

function belonging = evaluate_belonging(lsY_points, ellipsoid)

CentreL = ellipsoid(1);
CentreS = ellipsoid(2);
% CentreY = ellipsoid(3);
AxisL = ellipsoid(4);
AxisS = ellipsoid(5);
AxisY = ellipsoid(6);
RotY = ellipsoid(7);
RSS = ellipsoid(8);

steepness = 5; % steepness of the sigmoidal transition.

[lines, ~] = size(lsY_points);
% Centre the points relatively to the ellipsoid.
lsY_points = lsY_points - repmat([CentreL, CentreS, 0], [lines, 1]);
% Points with luminance value larger than c don't belone to the ellipsoid
do_belong = (abs(lsY_points(:, 3)) <= AxisY);
% rotate all points an angle alpha so that we can reduce the problem to
% one of canonical ellipsoids
s = sin(RotY);
c = cos(RotY);
rot = [c -s 0; s c 0; 0 0 1];
lsY_points = lsY_points * rot;
% TODO: if you want to have it faster you can pre calculate the power 2
% lsYPointsSqr = lsY_points .^ 2;
Px = lsY_points(:, 1);
Py = lsY_points(:, 2);
Pz = lsY_points(:, 3);

% FIXME: should we check for px and b are not 0 for devision.

% calculate the distance from each point to the ellipsoid
% TODO: why here (1 - Pz ./ c) is different from point_to_ellipse
x1 = (1 - Pz ./ AxisY) ./ sqrt(1 ./ (AxisL .^ 2) + (Py ./ Px ./ AxisS) .^ 2);
x2 = -x1;
y1 = Py ./ Px .* x1;
y2 = -y1;

%distances between the lsY_points and the closest in the ellipse
% FIXME: in the point_to_ellipse there is no sqrt for distance
d1 = sqrt((Px - x1) .^ 2 + (Py - y1) .^ 2);
% TODO: why d1 shouldn't be real?
d1 = d1 .* isreal(d1) + realmax .* ~isreal(d1);
d2 = sqrt((Px - x2) .^ 2 + (Py - y2) .^ 2);
d2 = d2 .* isreal(d2) + realmax .* ~isreal(d2);

% closest points in the ellipse
p = [x1, y1] .* [(d1 <= d2), (d1 <= d2)] + [x2, y2] .* [(d1 >= d2), (d1 >= d2)];

% distances from the centre to the closest points in the ellipse
H = sqrt(p(:, 1) .^ 2 + p(:, 2) .^ 2);

% distances from the centre to the lsY points
X = sqrt(Px .^ 2 + Py .^ 2);

% growth rate (width of the sigmoidal section)
G = steepness / sqrt(RSS);

belonging =  1 ./ (1 + exp(G .* (abs(X) - H)));
belonging = belonging .* do_belong;

end
