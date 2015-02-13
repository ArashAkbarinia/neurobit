function belongings = AllEllipsoidsEvaluateBelonging(InputImage, ColourEllipsoids)
%AllEllipsoidsEvaluateBelonging  computes belonging of each pixel for all
%                                elliposids.
%
% Inputs
%   InputImage        the input image.
%   ColourEllipsoids  the colour ellipsoids.
%
% Outputs
%   belongings  the belonging matrix with the same number of rows and
%               columns, each channel correponds to the belongign for each
%               pixel to ellipsoid X.
%

[nelpisd, ~] = size(ColourEllipsoids);
[rows, cols, chns] = size(InputImage);

belongings = zeros(rows, cols, nelpisd);

if chns == 3
  % first, convert the picture into a giant vector where every row
  % correspond to a pixel
  InputVector = reshape(InputImage, rows * cols, chns);
end

for i = 1:nelpisd
  [ibelonging, ~] = EllipsoidEvaluateBelonging(InputVector, ColourEllipsoids(i, :));
  
  belongings(:, :, i) = reshape(ibelonging, rows, cols, 1);
end

end
