function de = deltae1976(x1, x2)
%DELTAE1976  computed the colour difference based on the 1976 equation.
%   Explanation  http://en.wikipedia.org/wiki/Color_difference#CIE76
%   A delta E of ~= 2.3 corresponds to a JND (just noticeable difference).
%
% inputs
%   x1  the colour 1.
%   x2  the colour 2.
%
% outputs
%   de  the delta E based on 1976 equation.
%

de = sqrt(sum((x1 - x2) .^ 2, 2));

end
