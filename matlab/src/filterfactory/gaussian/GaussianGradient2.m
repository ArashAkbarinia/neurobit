function g2 = GaussianGradient2(GaussianKernel, theta)
%GaussianGradient2  calculating the second  gradient of Gaussian.
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

g1 = GaussianGradient1(GaussianKernel, theta);

[gx, gy] = gradient(g1);

g2 = cos(theta) * gx + sin(theta) * gy;

end
