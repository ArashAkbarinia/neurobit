function [d, p] = point_to_ellipse(XY, ParG, plotme)

if nargin < 3
  plotme = 0;
end

% Original algorithm by C. Alejandro Parraga (v.1.0 -August 2014)
%
%  Consider an ellipse centered in (0,0) aligned to the main axes (no
%  rotation):
%  x^2/a^2 + y^2/b^2 = 1
%  and a point in space P(Px,Py)
%  We consider the shortest distance between P and the ellipse to be
%  along the line that joins the centre of coordinates to P.
%  y = Py/Px * x
%  reeplacing the second equation in the first and solving for x gives two
%  possible solutions:
%
%  x1 = +sqrt( 1 / ((1/a^2) + (Py/Px/b)^2) )
%  x2 = -sqrt( 1 / ((1/a^2) + (Py/Px/b)^2) )
%
%  once we have x1 and x2 we can obtain y1 and y2
%  by using y = Py/Px * x
%
%  After that we simply select the point that gives the min value in
%
%  min ( sqrt((x1-Px)^2+(y1-Py)^2), sqrt((x2-Px)^2+(y2-Py)^2) )
%=========NOTE=====================
% This solution is a simplification and is not valid for very elongated
% ellipses.
%==================================

CentreL = ParG(1);
CentreS = ParG(2);
AxisL = ParG(3);
AxisS = ParG(4);
RotY = ParG(5); %in radians!
[rows, ~, ~] = size(XY);
%  Matrix Q for rotating the points and the ellipse to the canonical system
s = sin(RotY);
c = cos(RotY);
Q = [c -s; s c];
%  data points in canonical coordinates

% centre the points and rotate it
XY0 = [XY(:, 1) - CentreL XY(:, 2) - CentreS] * Q;
Px = XY0(:, 1);
Py = XY0(:, 2);
ToKeepPxs = (Px == 0);
Px = Px + ToKeepPxs .* realmin; %avoids division by zero

x1 = 1 ./ sqrt(1 ./ (AxisL .^ 2) + (Py ./ Px ./ AxisS) .^ 2);
x2 = -x1;
y1 = Py ./ Px .* x1 + ToKeepPxs .* AxisS; %avoids discontinuities when x=0;
y2 = -y1;

% TODO: I think here we should take sqrt of d1 and d2
d1 = (x1 - Px) .^ 2 + (y1 - Py) .^ 2;
d2 = (x2 - Px) .^ 2 + (y2 - Py) .^ 2;
d = min(d1, d2);

p = [x1, y1] .* [(d1 <= d2), (d1 <= d2)] + [x2, y2] .* [(d1 >= d2), (d1 >= d2)];

% FIXME: if there are more than one poitns maybe disable plotting
if plotme
  x0 = 0; %ParG(1);
  y0 = 0; %ParG(2);
  x = x1 .* (d1 <= d2) + x2 .* (d2 <= d1);
  y = y1 .* (d1 <= d2) + y2 .* (d2 <= d1);
  t = linspace(0, 2 * pi); % Generate ellipse parametrically
  XX = x0 + AxisL * cos(t);
  YY = y0 + AxisS * sin(t);
  q = [c s; -s c];
  XR = [XX' YY'] * q; % ellipse in canonical coordinates
  XcR = [Px Py] * q; % datapoints in canonical coordinates
  XYR = [x y] * q;   % points on the ellipse
  plot(XR(:, 1), XR(:, 2), 'r-', XcR(:, 1), XcR(:, 2), 'k.', XYR(:, 1), XYR(:, 2), 'b.');
  
  for k = 1:rows
    line([XcR(k, 1), XYR(k, 1)], [XcR(k, 2), XYR(k, 2)], 'Color', 'b', 'LineWidth', 1);
  end
  axis equal
end

end
