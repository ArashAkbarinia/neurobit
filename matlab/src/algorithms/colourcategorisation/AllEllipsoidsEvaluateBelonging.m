function belongings = AllEllipsoidsEvaluateBelonging(InputImage, ColourEllipsoids)

[nelpisd, ~] = size(ColourEllipsoids);
[rows, cols, chns] = size(InputImage);

belongings = zeros(rows, cols, nelpisd);

if chns == 3
  % first, convert the picture into a giant vector where every row
  % correspond to a pixel
  lsYVector = reshape(InputImage, rows * cols, chns);
end

for i = 1:nelpisd
  [ibelonging, ~] = EllipsoidEvaluateBelonging(lsYVector, ColourEllipsoids(i, :));
  
  belongings(:, :, i) = reshape(ibelonging, rows, cols, 1);
end

end
