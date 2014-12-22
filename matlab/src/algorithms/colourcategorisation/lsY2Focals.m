function belongings = lsY2Focals(lsYImage, ColourEllipsoids)

%Table 3 of D. Cao et al. / Vision Research 45 (2005) 1929-1934
%The cone chromaticities of the focal colors
% Focal color       L/(L + M)       S/(L + M)
% Red               0.777           0.54
% Green             0.630           0.44
% Blue              0.595           2.72
% Yellow            0.687           0.13
% Purple            0.659           2.15
% Orange            0.730           0.33
% Pink              0.687           1.15
% White             0.660           0.87
%
% This function was updated by Alej in/Sept/2014
%

[nelpisd, ~] = size(ColourEllipsoids);
[rows, cols, chns] = size(lsYImage);

belongings = zeros(rows, cols, nelpisd);

if chns == 3
  % first, convert the picture into a giant vector where every row correspond to
  % a pixel in lsY space
  lsYVector = reshape(lsYImage, rows * cols, chns);
end

for i = 1:nelpisd
  ibelonging = EllipsoidEvaluateBelonging(lsYVector, ColourEllipsoids(i, :));
  %   ibelonging = evaluate_belonging(lsYVector, ColourEllipsoids(i, :));
  
  belongings(:, :, i) = reshape(ibelonging, rows, cols, 1);
end

% generate achromatic representation
% achromatic = lsYImage(:, :, 3) ./ max(max(lsYImage(:, :, 3)));

end
