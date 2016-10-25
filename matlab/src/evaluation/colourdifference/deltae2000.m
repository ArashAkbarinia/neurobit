function de = deltae2000(x1, x2)
%DELTAE2000  computed the colour difference based on the 2000 equation.
%   Explanation  https://en.wikipedia.org/wiki/Color_difference#CIEDE2000
%
% inputs
%   x1  the colour 1.
%   x2  the colour 2.
%
% outputs
%   de  the delta E based on 2000 equation.
%

l1 = x1(:, 1);
a1 = x1(:, 2);
b1 = x1(:, 3);
l2 = x2(:, 1);
a2 = x2(:, 2);
b2 = x2(:, 3);

dl = l2 - l1;

lmu = (l1 + l2) ./ 2;

x12 = x1 .^ 2;
x22 = x2 .^ 2;

c1 = sqrt(x12(:, 2) + x12(:, 3));
c2 = sqrt(x22(:, 2) + x22(:, 3));
cmu = (c1 + c2) ./ 2;

a1prime = a1 + a1 .* 0.5 .* (1 - sqrt(cmu .^ 7 ./ (cmu .^ 7 + 25 .^ 7)));
a2prime = a2 + a2 .* 0.5 .* (1 - sqrt(cmu .^ 7 ./ (cmu .^ 7 + 25 .^ 7)));
c1prime = sqrt(a1prime .^ 2 + b1 .^ 2);
c2prime = sqrt(a2prime .^ 2 + b2 .^ 2);
dc = c2prime - c1prime;

h1prime = mod(rad2deg(atan2(b1, a1prime)), 360);
h2prime = mod(rad2deg(atan2(b2, a2prime)), 360);

tmph = abs(h2prime - h1prime);
dhprime = h2prime - h1prime;
cond0 = c1prime .* c2prime == 0;
dhprime(cond0) = 0;
cond1 = tmph > 180 & h2prime <= h1prime;
dhprime(cond1) = h2prime(cond1) - h1prime(cond1) + 360;
cond2 = tmph > 180 & h2prime >  h1prime;
dhprime(cond2) = h2prime(cond2) - h1prime(cond2) - 360;
dh = 2 .* sqrt(c1prime .* c2prime) .* sin(deg2rad(dhprime ./ 2));

cmuprime = (c1prime + c2prime) ./ 2;
hmu = (h1prime + h2prime) ./ 2;
cond0 = c1prime .* c2prime == 0;
hmu(cond0) = 0;
cond1 = tmph > 180 & h2prime + h1prime < 360;
hmu(cond1) = (h1prime(cond1) + h2prime(cond1) + 360) ./ 2;
cond2 = tmph > 180 & h2prime + h1prime >= 360;
hmu(cond2) = (h1prime(cond2) + h2prime(cond2) - 360) ./ 2;

sl = 1 + (0.015 .* (lmu - 50) .^ 2) ./ sqrt(20 + (lmu - 50) .^ 2);
sc = 1 + 0.045 .* cmuprime;
t = 1 - 0.17 .* cos(deg2rad(hmu - 30)) + 0.24 .* cos(deg2rad(2 .* hmu)) + 0.32 .* cos(deg2rad(3 .* hmu + 6)) - 0.2 .* cos(deg2rad(4 .* hmu - 63));
sh = 1 + 0.015 .* cmuprime .* t;
rt = -2 .* sqrt((cmuprime .^ 7) ./ (cmuprime .^ 7 + 25 .^ 7)) .* sin(deg2rad(60 .* exp(-((hmu - 275) ./ 25) .^ 2)));

% weighting factors
kl = 1;
kc = 1;
kh = 1;

de = sqrt((dl ./ (kl .* sl)) .^ 2 + (dc ./ (kc .* sc)) .^ 2 + (dh ./ (kh .* sh)) .^ 2 + rt .* (dc ./ (kc .* sc)) .* (dh ./ (kh .* sh)));

end
