function macstats = MacAdamStats(AxisPercentile, WhitePoint, ColourSpace, plotme)
%MacAdamStats  computes different statistics of MacAdam ellipses
%
% inputs
%   AxisPercentile  portion of axis to be considered, default 1.
%   WhitePoint      by default the white point of illumination C.
%   ColourSpace     lab or lav, default lab.
%   plotme          by default false.
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
if nargin < 3
  ColourSpace = 'lab';
end
if nargin < 4
  plotme = false;
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

MacAdamLuminance = 48;
WhitePoint = WhitePoint .* (48 / WhitePoint(2));
nVertices = 4;

VerticesDeltaEs = zeros(nEllipses, 3);
CentreDeltaEs = zeros(nEllipses, 3);
DistanceToCentresXYZ = zeros(nEllipses, 1);
LxxVars = zeros(nEllipses, 5);

islab = strcmpi(ColourSpace, 'lab');

for i = 1:nEllipses
  CurrentEllipse = MacAdamEllipses(i, :);
  
  CentreXY = CurrentEllipse(1:2);
  CentreXYZ = xyLum2XYZ([CentreXY, MacAdamLuminance]);
  if islab
    CentreLAB = xyz2lab(CentreXYZ, 'WhitePoint', WhitePoint);
  else
    CentreLAB = xyz2luv(CentreXYZ, WhitePoint);
  end
  
  [a1, a2, b1, b2] = PointsEllipseAxes(CurrentEllipse);
  VerticesXY = [a1'; a2'; b1'; b2'];
  VerticesXYZ = xyLum2XYZ([VerticesXY, repmat(MacAdamLuminance, [nVertices, 1])]);
  if islab
    VertticesLxx = xyz2lab(VerticesXYZ, 'WhitePoint', WhitePoint);
  else
    VertticesLxx = xyz2luv(VerticesXYZ, WhitePoint);
  end
  
  % centre delta E
  RowI = repmat(CentreLAB, [nVertices, 1]);
  CompMat76Centre = deltae1976(RowI, VertticesLxx);
  CompMat94Centre = deltae1994(RowI, VertticesLxx);
  CompMat00Centre = deltae2000(RowI, VertticesLxx);
  
  % vertices delta E
  CompMat76 = zeros(nVertices, nVertices);
  CompMat94 = zeros(nVertices, nVertices);
  CompMat00 = zeros(nVertices, nVertices);
  CurrentDistanceToCentresXYZ = zeros(nVertices, 1);
  for j = 1:nVertices
    RowI = repmat(VertticesLxx(j, :), [nVertices, 1]);
    CompMat76(j, :) = deltae1976(RowI, VertticesLxx);
    CompMat94(j, :) = deltae1994(RowI, VertticesLxx);
    CompMat00(j, :) = deltae2000(RowI, VertticesLxx);
    
    % distance to centre
    CurrentDistanceToCentresXYZ(j, 1) = sqrt(sum((CentreXYZ - VerticesXYZ(j, :)) .^ 2));
  end
  
  VerticesDeltaEs(i, :) = [max(CompMat76(:)), max(CompMat94(:)), max(CompMat00(:))];
  CentreDeltaEs(i, :) = [max(CompMat76Centre(:)), max(CompMat94Centre(:)), max(CompMat00Centre(:))];
  DistanceToCentresXYZ(i) = max(CurrentDistanceToCentresXYZ);
  
  LabAx1 = sqrt(sum((VertticesLxx(1, 2:3) - VertticesLxx(2, 2:3)) .^ 2));
  LabAx2 = sqrt(sum((VertticesLxx(3, 2:3) - VertticesLxx(4, 2:3)) .^ 2));
  LabAngle = AngleVectors([VertticesLxx(2, 2:3) - VertticesLxx(1, 2:3), 0], [1, 0, 0]);
  LxxVars(i, :) = [CentreLAB(2:3), LabAx1 / 2, LabAx2 /2, LabAngle];
end

macstats.deltae.vert = VerticesDeltaEs;
macstats.deltae.cent = CentreDeltaEs;
macstats.dist = DistanceToCentresXYZ;
macstats.lxx = LxxVars;

if plotme
  fprintf('Centre\n');
  fprintf('Min: 76 %.2f\t94 %.2f\t00 %.2f\n', min(CentreDeltaEs));
  fprintf('Avg: 76 %.2f\t94 %.2f\t00 %.2f\n', mean(CentreDeltaEs));
  fprintf('Max: 76 %.2f\t94 %.2f\t00 %.2f\n', max(CentreDeltaEs));
  fprintf('Vertices\n');
  fprintf('Min: 76 %.2f\t94 %.2f\t00 %.2f\n', min(VerticesDeltaEs));
  fprintf('Avg: 76 %.2f\t94 %.2f\t00 %.2f\n', mean(VerticesDeltaEs));
  fprintf('Max: 76 %.2f\t94 %.2f\t00 %.2f\n', max(VerticesDeltaEs));
  
  figure;
  hold on;
  for i = 1:25
    DrawEllipse(LxxVars(i, :));
  end
  axis equal
end

end
