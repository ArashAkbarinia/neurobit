function h = GaussianFilter2(sigmax, sigmay, meanx, meany)
%GaussianFilter2  Gaussian kernel.
%   Explanation  http://mathworld.wolfram.com/GaussianFunction.html
%
% inputs
%   sigmax  the sigma in x direction, default 0.5.
%   sigmay  the sigma in y direction, default 0.5.
%   meanx   the mean in x direction, default centre.
%   meany   the mean in y direction, default centre.
%
% outputs
%   h  the Gaussian kernel.
%

if nargin < 1 || isempty(sigmax)
  sigmax = 0.5;
end
if nargin < 2 || isempty(sigmay)
  sigmay = sigmax;
end

sizex = CalculateGaussianWidth(sigmax);
sizey = CalculateGaussianWidth(sigmay);

if nargin < 3 || isempty(meanx)
  meanx = 0;
end
if nargin < 4 || isempty(meany)
  meany = 0;
end

centrex = (sizex + 1) / 2;
centrey = (sizey + 1) / 2;
centrex = centrex + (meanx * centrex);
centrey = centrey + (meany * centrey);

xs = linspace(1, sizex, sizex)' * ones(1, sizey) - centrex;
ys = ones(1, sizex)' * linspace(1, sizey, sizey) - centrey;

h = exp(-0.5 .* ((xs ./ sigmax) .^ 2 + (ys ./ sigmay) .^ 2)) ./ (2 * pi * sigmax * sigmay);

end

function FilterWidth = CalculateGaussianWidth(sigma, MaxWidth)

if nargin < 2
  MaxWidth = 100;
end

threshold = 0.0001;
pw = 1:MaxWidth;
FilterWidth = find(exp(-(pw .^ 2) / (2 * sigma .^ 2)) > threshold, 1, 'last');
if isempty(FilterWidth)
  warning(['input sigma ', num2str(sigma), ' is too small, returning width 5.'], 'CalculateGaussianWidth:SmallSigma');
  FilterWidth = 5;
end
FilterWidth = FilterWidth .* 2 + 1;

end
