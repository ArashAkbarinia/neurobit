function de = deltae1994(x1, x2, k)
%DELTAE1994  computed the colour difference based on the 1994 equation.
%   Explanation  http://en.wikipedia.org/wiki/Color_difference#CIE94
%
% inputs
%   x1  the colour 1.
%   x2  the colour 2.
%
% outputs
%   de  the delta E based on 1994 equation.
%

if nargin < 3
  kl = 1;
  kc = 1;
  kh = 1;
  k1 = 0.045;
  k2 = 0.015;
else
  kl = k(1);
  kc = k(2);
  kh = k(3);
  k1 = k(4);
  k2 = k(5);
end

x12 = x1 .^ 2;
x22 = x2 .^ 2;

dl = x1(:, 1) - x2(:, 1);
c1 = sqrt(x12(:, 2) + x12(:, 3));
c2 = sqrt(x22(:, 2) + x22(:, 3));
dc = c1 - c2;
dh = sqrt((x1(:, 2) - x2(:, 2)) .^ 2 + (x1(:, 3) - x2(:, 3)) .^ 2 - dc .^ 2);

sl = 1;
sc = 1 + k1 .* c1;
sh = 1 + k2 .* c1;
de = sqrt((dl ./ (kl .* sl)) .^ 2 + (dc ./ (kc .* sc)) .^ 2 + (dh ./ (kh .* sh)) .^ 2);

end
