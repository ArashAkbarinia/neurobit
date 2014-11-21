function ColouredImage = ColourLabelImage(LabeledImage, colours)
%ColourLabelImage Summary of this function goes here
%   Detailed explanation goes here

[rows, cols, ~] = size(LabeledImage);
chns = size(colours, 1);

ColouredImage = zeros(rows, cols, 3);
LabeledImage(:, :, 2) = LabeledImage(:, :, 1);
LabeledImage(:, :, 3) = LabeledImage(:, :, 1);

for i = 1:chns
  [mi, ~] = size(ColouredImage(LabeledImage == i));
  ColouredImage(LabeledImage == i) = reshape(repmat(colours(i, :), mi / 3, 1), mi, 1);
end

ColouredImage = uint8(ColouredImage);

end
