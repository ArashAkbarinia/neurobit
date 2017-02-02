function macstats = MacAdamStats(AxisPercentile)
%MacAdamStats  computes different statistics of MacAdam ellipses
%
% inputs
%   AxisPercentile  portion of axis to be considered, default 1.
%
% outputs
%   DeltaEs  Delta Es for each ellipse, in three columns: 76, 94 and 2000.
%

if nargin < 1
  AxisPercentile = 1;
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

luminance = 1;
nVertices = 4;

VerticesDeltaEs = zeros(nEllipses, 3);
CentreDeltaEs = zeros(nEllipses, 3);
DistanceToCentresXYZ = zeros(nEllipses, 1);

for i = 1:nEllipses
  CurrentEllipse = MacAdamEllipses(i, :);
  
  CentreXY = CurrentEllipse(1:2);
  CentreXYZ = xyLum2XYZ([CentreXY, luminance]);
  CentreLAB = xyz2lab(CentreXYZ, 'WhitePoint', whitepoint('d65'));
  
  [a1, a2, b1, b2] = PointsEllipseAxes(CurrentEllipse);
  VerticesXY = [a1'; a2'; b1'; b2'];
  VerticesXYZ = xyLum2XYZ([VerticesXY, repmat(luminance, [nVertices, 1])]);
  VertticesLAB = xyz2lab(VerticesXYZ, 'WhitePoint', whitepoint('d65'));
  
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
end

macstats.deltae.vert = VerticesDeltaEs;
macstats.deltae.cent = CentreDeltaEs;
macstats.dist = DistanceToCentresXYZ;

fprintf('Centre\n');
fprintf('Min: 76 %.2f\t94 %.2f\t00 %.2f\n', min(CentreDeltaEs));
fprintf('Avg: 76 %.2f\t94 %.2f\t00 %.2f\n', mean(CentreDeltaEs));
fprintf('Max: 76 %.2f\t94 %.2f\t00 %.2f\n', max(CentreDeltaEs));
fprintf('Vertices\n');
fprintf('Min: 76 %.2f\t94 %.2f\t00 %.2f\n', min(VerticesDeltaEs));
fprintf('Avg: 76 %.2f\t94 %.2f\t00 %.2f\n', mean(VerticesDeltaEs));
fprintf('Max: 76 %.2f\t94 %.2f\t00 %.2f\n', max(VerticesDeltaEs));

end
