function FrontierHistogram = PlotFrontierRadiusHistogram(CartPoints, RadiusStep, plotme, normalise)
%PlotFrontierRadiusHistogram Summary of this function goes here
%
% inputs
%   CartPoints  the frontier points.
%   RadiusStep  the radius, by default 1.
%   plotme      if true it plots the histogram
%   normalise   if true the results are normalised to [0, 1], default true.
%
% outputs
%   FrontierHistogram  the histogram of radii.
%

if nargin < 2
  RadiusStep = 5;
end
if nargin < 3
  plotme = false;
end
if nargin < 4
  normalise = true;
end

xbins = 0:RadiusStep:50;
if isempty(CartPoints)
  FrontierHistogram = zeros(1, length(xbins));
  return;
end

PolarPoints = cart2pol3([CartPoints(:, 2), CartPoints(:, 3), CartPoints(:, 1)]);

[FrontierHistogram, centres] = hist(PolarPoints(:, 2), xbins);
if normalise
  FrontierHistogram = FrontierHistogram ./ sum(FrontierHistogram(:));
end

if plotme
  figure;
  bar(centres, FrontierHistogram);
end

end
