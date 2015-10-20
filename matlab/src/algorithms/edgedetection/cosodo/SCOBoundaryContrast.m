function fb = SCOBoundaryContrast(map,sigma,angles,weights,ws)


if nargin < 5, ws= 5; end
if nargin < 4, weights= -0.7; end
if nargin < 3,  angles = 8;  end

% obtain the final response
[Res, theta] = resSCOContrast(map,sigma,angles,weights,ws);
Re = Res./max(Res(:));

% non-max suppression...
theta = (theta-1)*pi/angles;
theta = mod(theta+pi/2,pi);
fb = nonmax(Re,theta);
fb = max(0,min(1,fb));

% mask out 1-pixel border where nonmax suppression fails
fb(1,:) = 0;
fb(end,:) = 0;
fb(:,1) = 0;
fb(:,end) = 0;

end
