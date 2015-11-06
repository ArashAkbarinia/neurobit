function StdGradient = LocalStdGradient(InputImage, theta, w, h, cw, ch)
%LocalStdGradient  local STD with direction.
%
% inputs
%   InputImage  the input image
%   theta       the direction for STD
%   w           the width of window, default 5
%   h           the height of window, default 5
%   cw          the centre zeroed width, default 0
%   ch          the centre zeroed height, default 0
%
% outputs
%   StdGradient  the STD of the InputImage in direction theta
%

if nargin < 2
  theta = 0;
end
if nargin < 3
  w = 5;
end
if nargin < 4
  h = w;
end
if nargin < 5
  cw = 0;
end
if nargin < 6
  ch = cw;
end

gx = LocalStdContrast(InputImage, [1, w], [1, cw]);
gy = LocalStdContrast(InputImage, [h, 1], [ch, 1]);

StdGradient = cos(theta) * gx + sin(theta) * gy;

end
