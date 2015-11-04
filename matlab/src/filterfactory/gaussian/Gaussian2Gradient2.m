function g2 = Gaussian2Gradient2(GaussianKernel, theta)
%Gaussian2Gradient2  calculating the second  gradient of 2D Gaussian.
%
% inputs
%   GaussianKernel  the Gaussian filter.
%   theta           the gradient angle.
%
% outputs
%   g2   the second derivative at angle theta.
%

if nargin < 2
  theta = 0;
end

g1 = Gaussian2Gradient1(GaussianKernel, theta);

[gx, gy] = gradient(g1);

g2 = cos(theta) * gx + sin(theta) * gy;

end
