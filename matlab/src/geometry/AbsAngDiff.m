function d = AbsAngDiff(th1, th2)
%AbsAngDiff  returns the absolute difference between two angles.
%
% inputs
%  th1  the first angle in radians.
%  th2  the second angle in radians.
%
% outputs
%  d  the distance in the interval [0 pi].
%

d = abs(AngDiff(th1, th2));

end
