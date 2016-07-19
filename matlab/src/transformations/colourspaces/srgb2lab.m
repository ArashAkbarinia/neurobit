function lab = srgb2lab(srgb)
%RGB2LAB Summary of this function goes here
%   Detailed explanation goes here

xyz = sRGB2XYZ(double(srgb), true, [10 ^ 2, 10 ^ 2, 10 ^ 2]);
lab = double(XYZ2Lab(xyz));

[rows, cols, chns] = size(lab);
if chns == 3
  lab = reshape(lab, rows * cols, chns);
end

% values outside of this range will be trimmed
MinChannel = [0,  -100, -100];
MaxChannel = [100, 100,  100];

for i = 1:3
  lab(:, i) = max(lab(:, i), MinChannel(i));
  lab(:, i) = min(lab(:, i), MaxChannel(i));
  lab(:, i) = NormaliseChannel(lab(:, i), 0, 1, MinChannel(i), MaxChannel(i)) .* 255;
end

if chns == 3
  lab = reshape(lab, rows, cols, chns);
end

end
