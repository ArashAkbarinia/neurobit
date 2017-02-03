function macstats = MacAdamStats(AxisPercentile, WhitePoint)
%MacAdamStats  computes different statistics of MacAdam ellipses
%
% inputs
%   AxisPercentile  portion of axis to be considered, default 1.
%   WhitePoint      by default the white point of illumination C.
%
% outputs
%   DeltaEs  Delta Es for each ellipse, in three columns: 76, 94 and 2000.
%

if nargin < 1
  AxisPercentile = 1;
end
if nargin < 2
  WhitePoint = whitepoint('c');
end

FunctionPath = mfilename('fullpath');
[~, FunctionName, ~] = fileparts(FunctionPath);
FunctionRelativePath = ['src', filesep, 'algorithms', filesep, 'colouranalysis', filesep, 'macadam', filesep, FunctionName];
WcsRelativePath = ['data', filesep, 'mats', filesep, 'visualisation', filesep, 'colours', filesep, 'MacAdamEllipses.mat'];
FilePath = strrep(FunctionPath, FunctionRelativePath, WcsRelativePath);

MacAdamPath = load(FilePath);
MacAdamEllipses = MacAdamPath.MacAdamEllipses;

MacAdamEllipses(:, 3:4) = MacAdamEllipses(:, 3:4) .* AxisPercentile;

nEllipses = size(MacAdamEllipses, 1);

MacAdamLuminance = 50;
luminance = 1;
nVertices = 4;

VerticesDeltaEs = zeros(nEllipses, 3);
CentreDeltaEs = zeros(nEllipses, 3);
DistanceToCentresXYZ = zeros(nEllipses, 1);
LabVars = zeros(nEllipses, 5);

for i = 1:nEllipses
  CurrentEllipse = MacAdamEllipses(i, :);
  
  CentreXY = CurrentEllipse(1:2);
  CentreXYZ = xyLum2XYZ([CentreXY, luminance]);
  CentreLAB = XYZ2Lab(CentreXYZ, WhitePoint);
  CentreLAB(1) = MacAdamLuminance;
  
  [a1, a2, b1, b2] = PointsEllipseAxes(CurrentEllipse);
  VerticesXY = [a1'; a2'; b1'; b2'];
  VerticesXYZ = xyLum2XYZ([VerticesXY, repmat(luminance, [nVertices, 1])]);
  VertticesLAB = XYZ2Lab(VerticesXYZ, WhitePoint);
  VertticesLAB(:, 1) = MacAdamLuminance;
  
  % centre delta E
  RowI = repmat(CentreLAB, [nVertices, 1]);
  CompMat76Centre = deltae1976(RowI, VertticesLAB);
  CompMat94Centre = deltae1994(RowI, VertticesLAB);
  CompMat00Centre = deltae2000(RowI, VertticesLAB);
  
  % vertices delta E
  CompMat76 = zeros(nVertices, nVertices);
  CompMat94 = zeros(nVertices, nVertices);
  CompMat00 = zeros(nVertices, nVertices);
  CurrentDistanceToCentresXYZ = zeros(nVertices, 1);
  for j = 1:nVertices
    RowI = repmat(VertticesLAB(j, :), [nVertices, 1]);
    CompMat76(j, :) = deltae1976(RowI, VertticesLAB);
    CompMat94(j, :) = deltae1994(RowI, VertticesLAB);
    CompMat00(j, :) = deltae2000(RowI, VertticesLAB);
    
    % distance to centre
    CurrentDistanceToCentresXYZ(j, 1) = sqrt(sum((CentreXYZ - VerticesXYZ(j, :)) .^ 2));
  end
  
  VerticesDeltaEs(i, :) = [max(CompMat76(:)), max(CompMat94(:)), max(CompMat00(:))];
  CentreDeltaEs(i, :) = [max(CompMat76Centre(:)), max(CompMat94Centre(:)), max(CompMat00Centre(:))];
  DistanceToCentresXYZ(i) = max(CurrentDistanceToCentresXYZ);
  
  LabAx1 = sqrt(sum((VertticesLAB(1, 2:3) - VertticesLAB(2, 2:3)) .^ 2));
  LabAx2 = sqrt(sum((VertticesLAB(3, 2:3) - VertticesLAB(4, 2:3)) .^ 2));
  LabAngle = AngleVectors([VertticesLAB(2, 2:3) - VertticesLAB(1, 2:3), 0], [1, 0, 0]);
  LabVars(i, :) = [CentreLAB(2:3), LabAx1 / 2, LabAx2 /2, LabAngle];
end

macstats.deltae.vert = VerticesDeltaEs;
macstats.deltae.cent = CentreDeltaEs;
macstats.dist = DistanceToCentresXYZ;
macstats.lab = LabVars;

end
