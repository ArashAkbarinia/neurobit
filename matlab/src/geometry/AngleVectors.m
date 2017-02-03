function theta = AngleVectors(u, v)
%AngleVectors  comutes the angle between two vectors.
%
% inputs
%   u  vector 1
%   v  vector 2
%
% outputs
%   theta the orientation between two vectors.
%

theta = atan2(norm(cross(u, v)), dot(u, v));

end
