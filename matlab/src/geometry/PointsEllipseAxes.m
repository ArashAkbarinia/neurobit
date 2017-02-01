function [a1, a2, b1, b2] = PointsEllipseAxes(ellipse)
%PointsEllipseAxes  computing the vertices of an ellipse.
%
% inputs
%  ellipse  five parameters ellipse.
%
% outputs
%   a1  sought vertex.
%   a2  north vertex.
%   b1  west vertex.
%   b2  east vertex.
%

cx = ellipse(1);
cy = ellipse(2);
ax = ellipse(3);
ay = ellipse(4);
rx = ellipse(5);

crx = cos(rx);
srx = sin(rx);

rotm = [crx, -srx; srx, crx];

a1 = [-ax; 0];
a2 = [+ax; 0];
b1 = [0; -ay];
b2 = [0; +ay];

a1 = rotm * a1 + [cx; cy];
a2 = rotm * a2 + [cx; cy];
b1 = rotm * b1 + [cx; cy];
b2 = rotm * b2 + [cx; cy];

end
