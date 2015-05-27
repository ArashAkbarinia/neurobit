function g1 = GaussianGradient1(GaussianKernel, theta)
%GaussianGradient1  calculating the gradient of Gaussian.
%
% inputs
%   GaussianKernel  the Gaussian filter.
%   theta           the gradient angle.
%
% outputs
%   g1  the derivative at angle theta.
%

if nargin < 2
  theta = 0;
end

[gx, gy] = gradient(GaussianKernel);

g1 = cos(theta) * gx + sin(theta) * gy;

end
