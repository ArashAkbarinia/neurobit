function [x, y, z] = alej_ellipsoid(center, radii, azel, alpha, origin)
%
%     [X,Y,Z]=ALEJ_ELLIPSOID(XC,YC,ZC,XR,YR,ZR,N) generates three
%     (N+1)-by-(N+1) matrices so that SURF(X,Y,Z) produces an
%     ellipsoid with center (XC,YC,ZC), radii (XR, YR, ZR) rotated
%     an angle ALPHA (in degrees) alongside the origin and directions
%     specified by the vector azel [THETA PHI]. If azel is specified in
%     Cartesian coordinates [X Y Z], The direction vector
%     then is the vector from the center of the plot box to (X,Y,Z).
%     The number of surface points is 30 by default.


if nargin < 5 || isempty(origin)
  origin = [0 0 0];
end

if nargin < 4 || isempty(alpha)
  alpha = 0;
end

if nargin < 3 || isempty(azel)
  azel = [0 0 1];
end

if nargin < 2 || isempty(radii)
  radii = [1 2 3];
end

if nargin < 1 || isempty(center)
  center = [0 0 0];
end


spoints = 30;

[x, y, z] = ellipsoid(center(1),center(2),center(3),radii(1),radii(2),radii(3),spoints);


%rotate(h,azel,alpha,origin);

% find unit vector for axis of rotation
if numel(azel) == 2 % theta, phi
  theta = pi*azel(1)/180;
  phi = pi*azel(2)/180;
  u = [cos(phi)*cos(theta); cos(phi)*sin(theta); sin(phi)];
elseif numel(azel) == 3 % direction vector
  u = azel(:)/norm(azel);
end

alph = alpha*pi/180;
cosa = cos(alph);
sina = sin(alph);
vera = 1 - cosa;
x1 = u(1);
y1 = u(2);
z1 = u(3);
rot = ...
  [
  cosa + x1 ^ 2 * vera,       x1 * y1 * vera - z1 * sina, x1 * z1 * vera + y1 * sina;
  x1 * y1 * vera + z1 * sina, cosa + y1 ^ 2 * vera,       y1 * z1 * vera - x1 * sina;
  x1 * z1 * vera - y1 * sina, y1 * z1 * vera + x1 * sina, cosa + z1 ^ 2* vera;
  ]';


if isempty(z)
  z = -origin(3)*ones(size(y));
end
[m,n] = size(z);
if numel(x) < m*n
  [x,y] = meshgrid(x,y);
end

[m,n] = size(x);
newxyz = [x(:)-origin(1), y(:)-origin(2), z(:)-origin(3)];
newxyz = newxyz*rot;
x = origin(1) + reshape(newxyz(:,1),m,n);
y = origin(2) + reshape(newxyz(:,2),m,n);
z = origin(3) + reshape(newxyz(:,3),m,n);

% This is just to make a more aesthetically pleasing mesh, since
% negative luminance values lack any meaning in vision.
z= z.*(z>0);

end
