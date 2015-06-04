function DifferenceOfGaussians = dog2(gaussian1, gaussian2)
%DOG2  difference of Gaussians in two dimensions.
%   Explanation  http://en.wikipedia.org/wiki/Difference_of_Gaussians
%
% inputs
%   gaussian1  first Gaussian filter.
%   gaussian2  second Gaussian filter.
%
% outputs
%   DifferenceOfGaussians  the difference of Gaussians.
%

[h1, w1] = size(gaussian1);
[h2, w2] = size(gaussian2);

dh1 = 1:h1;
dw1 = 1:w1;
dh2 = 1:h2;
dw2 = 1:w2;

dh = abs(h1 - h2) / 2;
dw = abs(w1 - w2) / 2;

g1 = zeros(max(h1, h2), max(w1, w2));
g2 = zeros(max(h1, h2), max(w1, w2));

if h1 < h2
  sih = dh + 1;
  eih = h2 - dh;
  dh1 = sih:eih;
elseif h2 < h1
  sih = dh + 1;
  eih = h1 - dh;
  dh2 = sih:eih;
end
if w1 < w2
  siw = dw + 1;
  eiw = w2 - dw;
  dw1 = siw:eiw;
elseif w2 < w1
  siw = dw + 1;
  eiw = w1 - dw;
  dw2 = siw:eiw;
end

g1(dh1, dw1) = gaussian1;
g2(dh2, dw2) = gaussian2;
DifferenceOfGaussians = g1 - g2;

end
