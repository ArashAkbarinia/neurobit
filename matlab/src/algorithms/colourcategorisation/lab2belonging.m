function BelongingImage = lab2belonging(ImageLab, ConfigsMat)
%LAB2BELONGING Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
  ConfigsMat = load('lab_ellipsoid_params');
end

ColourEllipsoids = ConfigsMat.ColourEllipsoids;

BelongingImage = AllEllipsoidsEvaluateBelonging(ImageLab, ColourEllipsoids);

end
