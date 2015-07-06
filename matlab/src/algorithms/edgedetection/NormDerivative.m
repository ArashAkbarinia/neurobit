function dinput = NormDerivative(InputImage, sigma, order)
%NormDerivative Summary of this function goes here
%   Detailed explanation goes here

if nargin < 3
  order=1;
end

if order ==1
  dx = gDer(InputImage, sigma, 1, 0);
  dy = gDer(InputImage, sigma, 0, 1);
  dinput = sqrt(dx .^ 2 + dy .^ 2);
end

% computes frobius norm
if order == 2
  dxx = gDer(InputImage, sigma, 2, 0);
  dyy = gDer(InputImage, sigma, 0, 2);
  dxy = gDer(InputImage, sigma, 1, 1);
  dinput = sqrt(dxx .^ 2 + 4 * dxy .^ 2 + dyy .^ 2);
end

end
