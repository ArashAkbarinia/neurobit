function h = gderivative(f, sigma, iorder, jorder)
%DGERIVATIVE Summary of this function goes here
%   Detailed explanation goes here

BreakOffSigma = 3.0;
filtersize = floor(BreakOffSigma * sigma + 0.5);

f = fill_border(f, filtersize);

x = -filtersize:1:filtersize;

gauss = 1 / (sqrt(2 * pi) * sigma) * exp((x .^ 2) / (-2 * sigma * sigma));

switch iorder
  case 0
    gx = gauss / sum(gauss);
  case 1
    gx = -(x / sigma ^ 2) .* gauss;
    gx = gx./(sum(sum(x .* gx)));
  case 2
    gx = (x .^ 2 / sigma ^ 4 - 1 / sigma ^ 2) .* gauss;
    gx = gx - sum(gx) / size(x, 2);
    gx = gx / sum(0.5 * x .* x .* gx);
end
h = filter2(gx,f);

switch jorder
  case 0
    gy= gauss / sum(gauss);
  case 1
    gy = -(x / sigma ^ 2) .* gauss;
    gy = gy ./ (sum(sum(x .* gy)));
  case 2
    gy = (x .^ 2 / sigma ^ 4 - 1 / sigma ^ 2) .* gauss;
    gy = gy - sum(gy) / size(x, 2);
    gy = gy / sum(0.5 * x .* x .* gy);
end
h = filter2(gy', h);

h = h(filtersize + 1:size(h, 1) - filtersize, filtersize + 1:size(h, 2) - filtersize);

end

