function lsy = srgb2lsy(srgb)
%SRGB2LMS Summary of this function goes here
%   Detailed explanation goes here

xyz = sRGB2XYZ(srgb + 1, true, [10 ^ 2, 10 ^ 2, 10 ^ 2]);
lsy = XYZ2lsY(xyz, 'evenly_ditributed_stds');

[rows, cols, chns] = size(lsy);
if chns == 3
  lsy = reshape(lsy, rows * cols, chns);
end

% values outside of this range will be trimmed
MinChannel = [55, 0, 0];
MaxChannel = [84, 29, 100];

for i = 1:3
  lsy(:, i) = max(lsy(:, i), MinChannel(i));
  lsy(:, i) = min(lsy(:, i), MaxChannel(i));
  lsy(:, i) = NormaliseChannel(lsy(:, i), 0, 1, MinChannel(i), MaxChannel(i)) .* 255;
end

if chns == 3
  lsy = reshape(lsy, rows, cols, chns);
end

end
