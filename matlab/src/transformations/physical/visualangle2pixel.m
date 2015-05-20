function PixelSize = visualangle2pixel(VisualAngle, MonitorHeight, distance, VerticalResolution)
%VISUALANGLE2PIXEL  converts visual angle to pixels.
%   Explanation  http://en.wikipedia.org/wiki/Visual_angle
%                http://osdoc.cogsci.nl/miscellaneous/visual-angle/
%
% inputs
%   VisualAngle         the visual angle in degree.
%   MonitorHeight       monitor height in cm.
%   distance            distance between the person and the monitor.
%   VerticalResolution  vertical resolution of the monitor.
%
% outputs
%   PixelSize  the stimulus size in pixels.
%
% See also: pixel2visualangle
%

if nargin < 2 || isempty(MonitorHeight)
  MonitorHeight = 25;
end
if nargin < 3 || isempty(distance)
  distance = 60;
end
if nargin < 4 || isempty(VerticalResolution)
  VerticalResolution = 768;
end

DegreePerPixel = rad2deg(atan2(0.5 * MonitorHeight, distance)) / (0.5 * VerticalResolution);

PixelSize = VisualAngle / DegreePerPixel;

end
