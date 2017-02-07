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
nCircumferencePoints = 36;

CircumferenceDeltaEs = zeros(nEllipses, 3);
VerticesDeltaEs = zeros(nEllipses, 3);
CentreDeltaEs = zeros(nEllipses, 3);
DistanceToCentresXYZ = zeros(nEllipses, 1);
LxxVars = zeros(nEllipses, 5);
LxxFits = zeros(nEllipses, 5);

islab = strcmpi(ColourSpace, 'lab');
isMax = true;

for i = 1:nEllipses
  CurrentEllipse = MacAdamEllipses(i, :);
  
  CentreXY = CurrentEllipse(1:2);
  CentreXYZ = xyLum2XYZ([CentreXY, MacAdamLuminance]);
  
  CircumferencePointsXY = PointsEllipseCircumference(CurrentEllipse, nCircumferencePoints);
  CircumferencePointsXYZ = xyLum2XYZ([CircumferencePointsXY, repmat(MacAdamLuminance, [nCircumferencePoints, 1])]);
  
  [a1, a2, b1, b2] = PointsEllipseAxes(CurrentEllipse);
  VerticesXY = [a1'; a2'; b1'; b2'];
  VerticesXYZ = xyLum2XYZ([VerticesXY, repmat(MacAdamLuminance, [nVertices, 1])]);
  if islab
    CentreLAB = xyz2lab(CentreXYZ, 'WhitePoint', WhitePoint);
    VertticesLxx = xyz2lab(VerticesXYZ, 'WhitePoint', WhitePoint);
    CircumferencePointsLxx = xyz2lab(CircumferencePointsXYZ, 'WhitePoint', WhitePoint);
  else
    CentreLAB = xyz2luv(CentreXYZ, WhitePoint);
    VertticesLxx = xyz2luv(VerticesXYZ, WhitePoint);
    CircumferencePointsLxx = xyz2luv(CircumferencePointsXYZ, WhitePoint);
  end
  
  CurrentDistanceToCentresXYZ = zeros(nVertices, 1);
  for j = 1:nVertices
    % distance to centre
    CurrentDistanceToCentresXYZ(j, 1) = sqrt(sum((CentreXYZ - VerticesXYZ(j, :)) .^ 2));
  end
  
  CircumferenceDeltaEs(i, :) = ComputeDeltaEs(CentreLAB, CircumferencePointsLxx, isMax);
  VerticesDeltaEs(i, :) = ComputeDeltaEs(VertticesLxx, VertticesLxx, isMax);
  CentreDeltaEs(i, :) = ComputeDeltaEs(CentreLAB, VertticesLxx, isMax);
  DistanceToCentresXYZ(i) = max(CurrentDistanceToCentresXYZ);
  
  LabAx1 = sqrt(sum((VertticesLxx(1, 2:3) - VertticesLxx(2, 2:3)) .^ 2));
  LabAx2 = sqrt(sum((VertticesLxx(3, 2:3) - VertticesLxx(4, 2:3)) .^ 2));
  LabAngle = AngleVectors([VertticesLxx(2, 2:3) - VertticesLxx(1, 2:3), 0], [1, 0, 0]);
  LxxVars(i, :) = [CentreLAB(2:3), LabAx1 / 2, LabAx2 /2, LabAngle];
  LxxFits(i, :) = FitPointsToEllipses(CircumferencePointsLxx(:, 2:3), false);
end

macstats.deltae.circ = CircumferenceDeltaEs;
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
  fprintf('Circumference\n');
  fprintf('Min: 76 %.2f\t94 %.2f\t00 %.2f\n', min(CircumferenceDeltaEs));
  fprintf('Avg: 76 %.2f\t94 %.2f\t00 %.2f\n', mean(CircumferenceDeltaEs));
  fprintf('Max: 76 %.2f\t94 %.2f\t00 %.2f\n', max(CircumferenceDeltaEs));
  
  figure;
  hold on;
  for i = 1:nEllipses
    h1 = DrawEllipse(LxxVars(i, :));
    h2 = DrawEllipse(LxxFits(i, :), 'color', 'red');
  end
  axis equal;
  legend([h1 h2], {'Ellipses', 'Fitted'});
  legend('show');
end

end

function deltaes = ComputeDeltaEs(CentrePoints, VertticesLxx, isMax)

if nargin < 2
  isMax = true;
end

nCentres = size(CentrePoints, 1);
nVertices = size(VertticesLxx, 1);

% vertices delta E
CompMat76Vertices = zeros(nCentres, nVertices);
CompMat94Vertices = zeros(nCentres, nVertices);
CompMat00Vertices = zeros(nCentres, nVertices);
for j = 1:nCentres
  RowI = repmat(CentrePoints(j, :), [nVertices, 1]);
  CompMat76Vertices(j, :) = deltae1976(RowI, VertticesLxx);
  CompMat94Vertices(j, :) = deltae1994(RowI, VertticesLxx);
  CompMat00Vertices(j, :) = deltae2000(RowI, VertticesLxx);
end

if isMax
  deltaes = [max(CompMat76Vertices(:)), max(CompMat94Vertices(:)), max(CompMat00Vertices(:))];
else
  deltaes = [mean(CompMat76Vertices(:)), mean(CompMat94Vertices(:)), mean(CompMat00Vertices(:))];
end

end
