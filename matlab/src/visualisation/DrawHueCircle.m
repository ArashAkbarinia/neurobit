function [] = DrawHueCircle(radius)
%DrawHueCircle  draws the hue circle.
%
% inputs
%   radius  the radius of the circle, default is 1.
%

if nargin < 1
  radius = 1;
end

radii = linspace(0, radius, 10);
theta = linspace(0, 2 * pi, 100);
[rag, thg] = meshgrid(radii, theta);
[x, y] = pol2cart(thg, rag);
pcolor(x, y, thg);
colormap(LabColourMap);

shading('flat');
axis('equal');

xlim([-radius, radius]);
ylim([-radius, radius]);

end
