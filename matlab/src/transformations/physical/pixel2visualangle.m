function VisualAngle = pixel2visualangle(PixelSize, MonitorHeight, distance, VerticalResolution)
%PIXEL2VISUALANGLE  converts pixels to visual angle.
%   Explanation  http://en.wikipedia.org/wiki/Visual_angle
%                http://osdoc.cogsci.nl/miscellaneous/visual-angle/
%
% inputs
%   PixelSize           the stimulus size in pixels.
%   MonitorHeight       monitor height in cm.
%   distance            distance between the person and the monitor.
%   VerticalResolution  vertical resolution of the monitor.
%
% outputs
%   VisualAngle  the visual angle in degree.
%
% See also: visualangle2pixel
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

VisualAngle = PixelSize * DegreePerPixel;

end
