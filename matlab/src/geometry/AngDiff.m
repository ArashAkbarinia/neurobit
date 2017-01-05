function d = AngDiff(th1, th2)
%AngDiff  returns the difference between two angles on the circle.
%
% inputs
%  th1  the first angle in radians.
%  th2  the second angle in radians.
%
% outputs
%  d  the distance in the interval [-pi pi).
%

if nargin < 2
  d = th1;
else
  d = th2 - th1;
end

d = mod(d + pi, 2 * pi) - pi;

end
