function h = GaussianFilter1(sigmax, meanx)
%GaussianFilter1  1D Gaussian kernel.
%   Explanation  http://mathworld.wolfram.com/GaussianFunction.html
%
% inputs
%   sigmax  the sigma in x direction, default 0.5.
%   meanx   the mean in x direction, default centre.
%
% outputs
%   h  the Gaussian kernel.
%

if nargin < 1 || isempty(sigmax)
  sigmax = 0.5;
end

sizex = CalculateGaussianWidth(sigmax);

if nargin < 2 || isempty(meanx)
  meanx = 0;
end

centrex = (sizex + 1) / 2;
centrex = centrex + (meanx * centrex);

xs = linspace(1, sizex, sizex) - centrex;
h = exp(-xs .^ 2 / (2 * sigmax ^ 2));

h = h / sum(h(:));

end
