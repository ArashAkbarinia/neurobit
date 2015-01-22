function ColourEllipsoids = FitColourPointsToEllipsoid(ColourSpace, WhichColours, plotme, saveme)
%FitColourPointsToEllipsoid Summary of this function goes here
%   Detailed explanation goes here

if nargin < 1
  ColourSpace = 'lab';
end
if nargin < 2
  WhichColours = {'c'};
end
if nargin < 3
  plotme = 1;
  saveme = 1;
end
ColourSpace = lower(ColourSpace);

if strcmpi(WhichColours{1}, 'c')
  WhichColours = {'G', 'B', 'Pp', 'Pk', 'R', 'O', 'Y', 'Br'};
end

if strcmpi(WhichColours{1}, 'a')
  WhichColours = {'G', 'B', 'Pp', 'Pk', 'R', 'O', 'Y', 'Br', 'Gr', 'W', 'Bl'};
end

WhichColours = lower(WhichColours);
ncolours = length(WhichColours);
ColourEllipsoids = zeros(11, 9);

% WcsColourTable = WcsChart();
% [PosGroundTruth, NegGroundTruth] = DomainColourBoundries();
[WcsColourTable, PosGroundTruth] = ColourBoxes();
NegGroundTruth = PosGroundTruth;
NegGroundTruth(NegGroundTruth > 0) = 1;

% this allows us to only test one colour, the rest of the colour get the
% latest ellipsoid parameters.
if strcmpi(ColourSpace, 'lsy')
  ColourPoints = XYZ2lsY(sRGB2XYZ(WcsColourTable, true, [10 ^ 2, 10 ^ 2, 10 ^ 2]), 'evenly_ditributed_stds');
  GoodResult = load('lsy_ellipsoid_params.mat');
elseif strcmpi(ColourSpace, 'lab')
  ColourPoints = double(applycform(WcsColourTable + 1, makecform('srgb2lab')));
  GoodResult = load('lab_ellipsoid_params.mat');
end
ColourEllipsoids(:, 1:9) = GoodResult.ColourEllipsoids(:, 1:9);

if plotme
  figure;
  grid on;
  hold on;
end

for i = 1:ncolours
  switch WhichColours{i}
    case {'g', 'green'}
      ColourEllipsoids(1, :) = DoColour(PosGroundTruth, NegGroundTruth, ColourPoints, 1, 'green', plotme);
    case {'b', 'blue'}
      ColourEllipsoids(2, :) = DoColour(PosGroundTruth, NegGroundTruth, ColourPoints, 2, 'blue', plotme);
    case {'pp', 'purple'}
      ColourEllipsoids(3, :) = DoColour(PosGroundTruth, NegGroundTruth, ColourPoints, 3, 'purple', plotme);
    case {'pk', 'pink'}
      ColourEllipsoids(4, :) = DoColour(PosGroundTruth, NegGroundTruth, ColourPoints, 4, 'pink', plotme);
    case {'r', 'red'}
      ColourEllipsoids(5, :) = DoColour(PosGroundTruth, NegGroundTruth, ColourPoints, 5, 'red', plotme);
    case {'o', 'orange'}
      ColourEllipsoids(6, :) = DoColour(PosGroundTruth, NegGroundTruth, ColourPoints, 6, 'orange', plotme);
    case {'y', 'yellow'}
      ColourEllipsoids(7, :) = DoColour(PosGroundTruth, NegGroundTruth, ColourPoints, 7, 'yellow', plotme);
    case {'br', 'brown'}
      ColourEllipsoids(8, :) = DoColour(PosGroundTruth, NegGroundTruth, ColourPoints, 8, 'brown', plotme);
    case {'gr', 'grey'}
      ColourEllipsoids(9, :) = DoColour(PosGroundTruth, NegGroundTruth, ColourPoints, 9, 'grey', plotme);
    case {'w', 'white'}
      ColourEllipsoids(10, :) = DoColour(PosGroundTruth, NegGroundTruth, ColourPoints, 10, 'white', plotme);
    case {'bl', 'black'}
      ColourEllipsoids(11, :) = DoColour(PosGroundTruth, NegGroundTruth, ColourPoints, 11, 'black', plotme);
    otherwise
      disp('Wrong category, returning the latest ellipsoid parameters.');
  end
end

if saveme
  RGBTitles = {'G', 'B', 'Pp', 'Pk', 'R', 'O', 'Y', 'Br', 'Gr', 'W', 'Bl'}; %#ok
  save([ColourSpace, '_ellipsoid_params_arash.mat'], 'ColourEllipsoids', 'RGBTitles');
end

end

function ColourEllipsoid = DoColour(PosGroundTruth, NegGroundTruth, ColourPoints, ColourIndex, ColourName, plotme)

inds = PosGroundTruth(:, :, ColourIndex) > 0;
inds(:, :, 2) = inds(:, :, 1);
inds(:, :, 3) = inds(:, :, 1);

PositivelsYPoints = ColourPoints(inds);
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
  inf, inf, inf, 150, 150, 150, pi, pi, pi;
  ];
options = optimoptions(@fmincon,'Algorithm', 'sqp', 'Display', 'off', 'MaxIter', 1e6, 'TolFun', 1e-10, 'MaxFunEvals', 1e6);

RSS(1) = ColourEllipsoidFitting(initial, ColourPoints, PosGroundTruth(:, :, ColourIndex), NegGroundTruth(:, :, ColourIndex));
[ColourEllipsoid, RSS(2), exitflag, output] = fmincon(@(x) ColourEllipsoidFitting(x, ColourPoints, PosGroundTruth(:, :, ColourIndex), NegGroundTruth(:, :, ColourIndex)), initial, [], [], [], [], lb, ub, [], options);

disp ('================================================================');
disp (['         Colour category: ', ColourName]);
disp ('================================================================');
PrintFittingResults(output, ColourEllipsoid, RSS, exitflag, initial(4:6));

if plotme
  DrawEllipsoid(ColourEllipsoid, 'FaceColor', [1, 1, 1], 'EdgeColor', name2rgb(ColourName), 'FaceAlpha', 0.5);
end

end

function RSS = ColourEllipsoidFitting(x, lsYPoints, PosGroundTruth, NegGroundTruth)

if ~isempty(lsYPoints)
  [belonging, distances] = EllipsoidEvaluateBelonging(lsYPoints, x);
  PosDiff = PosGroundTruth - belonging;
  PosDiff = PosDiff(PosDiff > 0);
  NegDiff = belonging - NegGroundTruth;
  NegDiff = NegDiff(NegDiff > 0);
  RSS = 1 * sum(sum(abs(PosGroundTruth - belonging))) + 0 * sum(sum(NegDiff));
else
  RSS = 0;
end

end
