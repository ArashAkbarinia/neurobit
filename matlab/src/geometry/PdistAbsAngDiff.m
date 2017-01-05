function d = PdistAbsAngDiff(th1, th2)
%PdistAbsAngDiff  same as AbsAngDiff though the output is a vertical vector
%
% inputs
%  th1  the first angle in radians.
%  th2  the second angle in radians.
%
% outputs
%  d  the distance in the interval [0 pi].
%

d = abs(AngDiff(th1, th2));

d = mean(d);

end
