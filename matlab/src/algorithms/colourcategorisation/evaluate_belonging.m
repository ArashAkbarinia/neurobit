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

cl = ellipsoid(1);
cs = ellipsoid(2);
% cv = ColourEllipsoids(3);
a = ellipsoid(4);
b = ellipsoid(5);
c = ellipsoid(6);
alpha_rad = ellipsoid(7);
RSS = ellipsoid(8);

steepness = 5; % steepness of the sigmoidal transition.

[lines, ~] = size(lsY_points);
% Centre the points relatively to the ellipsoid.
lsY_points = lsY_points - repmat([cl, cs, 0], [lines, 1]);
%Points with luminance value larger than c don't belone to the ellipsoid
do_belong = (abs(lsY_points(:, 3)) <= c);
%rotate all points an angle -alpha_rad so that we can reduce the problem to
%one of canonical ellipsoids
sa = sin(alpha_rad);
ca = cos(alpha_rad);
rot = [ca -sa 0; sa ca 0; 0 0 1];
lsY_points = lsY_points * rot;
lsYPointsSqr = lsY_points .^ 2;

% calculate the distance from each point to the ellipsoid
x1 = (1 - lsY_points(:, 3) ./ c) ./ sqrt(1 / (a .^ 2) + 1 / (b .^ 2) .* (lsYPointsSqr(:, 2) ./ lsYPointsSqr(:, 1)));
x2 = -x1;
y1 = lsY_points(:, 2) ./ lsY_points(:, 1) .* x1;
y2 = -y1;

%distances between the lsY_points and the closest in the ellipse
d1 = sqrt((lsY_points(:, 1) - x1) .^ 2 + (lsY_points(:, 2) - y1) .^ 2);
d1 = d1 .* isreal(d1) + realmax .* ~isreal(d1);
d2 = sqrt((lsY_points(:, 1) - x2) .^ 2 + (lsY_points(:, 2) - y2) .^ 2);
d2 = d2 .* isreal(d2) + realmax .* ~isreal(d2);
%closest points in the ellipse
p = [x1, y1] .* [(d1 <= d2), (d1 <= d2)] + [x2, y2] .* [(d1 >= d2), (d1 >= d2)];
%distances from the centre to the closest points in the ellipse
H = sqrt(p(:, 1) .^ 2 + p(:, 2) .^ 2);
% distances from the centre to the lsY points
X = sqrt(lsYPointsSqr(:, 1) + lsYPointsSqr(:, 2));
%growth rate (width of the sigmoidal section)
G = steepness / sqrt(RSS);

belonging =  1 ./ (1 + exp(G .* (abs(X) - H)));
belonging = belonging .* do_belong;

end
