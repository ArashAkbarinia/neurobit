function ColourEllipsoids = FitColourPointsToEllipsoid(WhichColours, plotme, saveme)
%FitColourPointsToEllipsoid Summary of this function goes here
%   Detailed explanation goes here

if nargin < 1
  WhichColours = {'a'};
end
if nargin < 2
  plotme = 1;
  saveme = 1;
end

if strcmpi(WhichColours{1}, 'a')
  WhichColours = {'G', 'B', 'Pp', 'Pk', 'R', 'O', 'Y', 'Br'}; % 'Gr', 'W', 'Bl' % TODO: we need to add GT for achromatic
end

WhichColours = lower(WhichColours);
ncolours = length(WhichColours);
ColourEllipsoids = zeros(11, 9);

% this allows us to only test one colour, the rest of the colour get the
% latest ellipsoid parameters.
GoodResult = load('2014_ellipsoid_params.mat');
ColourEllipsoids(:, 1:9) = GoodResult.ColourEllipsoids(:, 1:9);

WcsColourTable = WcsChart();
GroundTruth = WcsResults(true);

if plotme
  figure;
  grid on;
  hold on;
end

for i = 1:ncolours
  switch WhichColours{i}
    case {'g', 'green'}
      ColourEllipsoids(1, :) = DoColour(GroundTruth, WcsColourTable, 1, 'green', plotme);
    case {'b', 'blue'}
      ColourEllipsoids(2, :) = DoColour(GroundTruth, WcsColourTable, 2, 'blue', plotme);
    case {'pp', 'purple'}
      ColourEllipsoids(3, :) = DoColour(GroundTruth, WcsColourTable, 3, 'purple', plotme);
    case {'pk', 'pink'}
      ColourEllipsoids(4, :) = DoColour(GroundTruth, WcsColourTable, 4, 'pink', plotme);
    case {'r', 'red'}
      ColourEllipsoids(5, :) = DoColour(GroundTruth, WcsColourTable, 5, 'red', plotme);
    case {'o', 'orange'}
      ColourEllipsoids(6, :) = DoColour(GroundTruth, WcsColourTable, 6, 'orange', plotme);
    case {'y', 'yellow'}
      ColourEllipsoids(7, :) = DoColour(GroundTruth, WcsColourTable, 7, 'yellow', plotme);
    case {'br', 'brown'}
      ColourEllipsoids(8, :) = DoColour(GroundTruth, WcsColourTable, 8, 'brown', plotme);
    case {'gr', 'grey'}
      ColourEllipsoids(9, :) = DoColour(GroundTruth, WcsColourTable, 9, 'grey', plotme);
    case {'w', 'white'}
      ColourEllipsoids(10, :) = DoColour(GroundTruth, WcsColourTable, 10, 'white', plotme);
    case {'bl', 'black'}
      ColourEllipsoids(11, :) = DoColour(GroundTruth, WcsColourTable, 11, 'black', plotme);
    otherwise
      disp('Wrong category, returning the latest ellipsoid parameters.');
  end
end

if saveme
  RGBTitles = {'G', 'B', 'Pp', 'Pk', 'R', 'O', 'Y', 'Br', 'Gr', 'W', 'Bl'}; %#ok
  save('2014_ellipsoid_params_arash.mat', 'ColourEllipsoids', 'RGBTitles');
end

end

function ColourEllipsoid = DoColour(GroundTruth, WcsColourTable, ColourIndex, ColourName, plotme)

WcsColourTable = WcsColourTable + 1;
lsYPoints = XYZ2lsY(sRGB2XYZ(WcsColourTable, true, [10 ^ 2, 10 ^ 2, 10 ^ 2]), 'evenly_ditributed_stds');

inds = GroundTruth(:, :, ColourIndex) > 0;
inds(:, :, 2) = inds(:, :, 1);
inds(:, :, 3) = inds(:, :, 1);

PositivelsYPoints = lsYPoints(inds);
PositivelsYPoints = reshape(PositivelsYPoints, size(PositivelsYPoints, 1) / 3, 3);

if plotme
  if ~isempty(PositivelsYPoints)
    plot3(PositivelsYPoints(:, 1), PositivelsYPoints(:, 2), PositivelsYPoints(:, 3), '.', 'Color', name2rgb(ColourName));
  end
end

if size(PositivelsYPoints, 1) > 1
  initial = [mean(PositivelsYPoints), std(PositivelsYPoints), 0, 0, 0];
else
  initial = [PositivelsYPoints, 10, 10, 10, 0, 0, 0];
end
lb = ...
  [
  -inf, -inf, -inf, 0, 0, 0, 0, 0, 0;
  ];
ub = ...
  [
  inf, inf, inf, inf, inf, inf, pi, pi, pi;
  ];
options = optimoptions(@fmincon,'Algorithm', 'sqp', 'Display', 'off', 'MaxIter', 1e6, 'TolFun', 1e-10, 'MaxFunEvals', 1e6);

RSS(1) = ColourEllipsoidFitting(initial, lsYPoints, GroundTruth(:, :, ColourIndex));
[ColourEllipsoid, RSS(2), exitflag, output] = fmincon(@(x) ColourEllipsoidFitting(x, lsYPoints, GroundTruth(:, :, ColourIndex)), initial, [], [], [], [], lb, ub, [], options);

disp ('================================================================');
disp (['         Colour category: ', ColourName]);
disp ('================================================================');
PrintFittingResults(output, ColourEllipsoid, RSS, exitflag, initial(4:6));

if plotme
  DrawEllipsoid(ColourEllipsoid, 'FaceColor', [1, 1, 1], 'EdgeColor', name2rgb(ColourName), 'FaceAlpha', 0.5);
end

end

function RSS = ColourEllipsoidFitting(x, lsYPoints, GroundTruth)

if ~isempty(lsYPoints)
  [belonging, distances] = EllipsoidEvaluateBelonging(lsYPoints, x);
  RSS = sum(sum(abs(GroundTruth - belonging)));
else
  RSS = 0;
end

end
