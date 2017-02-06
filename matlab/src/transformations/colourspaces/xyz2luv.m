function luv = xyz2luv(xyz, WhitePoint)

if nargin < 2
  WhitePoint = whitepoint('d65');
end

[rows, cols, chns] = size(xyz);
if chns == 3
  xyz = reshape(xyz, rows * cols, chns);
end

luv = zeros(size(xyz, 1), size(xyz, 2));

% compute u' v' for sample
up = 4 * xyz(:, 1) ./ (xyz(:, 1) + 15 * xyz(:, 2) + 3 * xyz(:, 3));
vp = 9 * xyz(:, 2) ./ (xyz(:, 1) + 15 * xyz(:, 2) + 3 * xyz(:, 3));
% compute u' v' for white
upw = 4 * WhitePoint(1) / (WhitePoint(1) + 15 * WhitePoint(2) + 3 * WhitePoint(3));
vpw = 9 * WhitePoint(2) / (WhitePoint(1) + 15 * WhitePoint(2) + 3 * WhitePoint(3));

index = (xyz(:, 2) / WhitePoint(2) > 0.008856);
luv(:, 1) = luv(:, 1) + index .* (116 * (xyz(:, 2) / WhitePoint(2)) .^ (1 / 3) - 16);
luv(:, 1) = luv(:, 1) + (1 - index) .* (903.3 * (xyz(:, 2) / WhitePoint(2)));

luv(:, 2) = 13 * luv(:, 1) .* (up - upw);
luv(:, 3) = 13 * luv(:, 1) .* (vp - vpw);

if chns == 3
  luv = reshape(luv, rows, cols, chns);
end

end
