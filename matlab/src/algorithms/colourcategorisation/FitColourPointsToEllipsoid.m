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
% [WcsColourTable, PosGroundTruth] = ColourBoxes();

[WcsColourTable, PosGroundTruth] = SatfacesData();
% PlotAllChannels(WcsColourTable, PosGroundTruth);

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
      ColourEllipsoids(1, :) = DoColour(PosGroundTruth, ColourPoints, 1, 'green', plotme);
    case {'b', 'blue'}
      ColourEllipsoids(2, :) = DoColour(PosGroundTruth, ColourPoints, 2, 'blue', plotme);
    case {'pp', 'purple'}
      ColourEllipsoids(3, :) = DoColour(PosGroundTruth, ColourPoints, 3, 'purple', plotme);
    case {'pk', 'pink'}
      ColourEllipsoids(4, :) = DoColour(PosGroundTruth, ColourPoints, 4, 'pink', plotme);
    case {'r', 'red'}
      ColourEllipsoids(5, :) = DoColour(PosGroundTruth, ColourPoints, 5, 'red', plotme);
    case {'o', 'orange'}
      ColourEllipsoids(6, :) = DoColour(PosGroundTruth, ColourPoints, 6, 'orange', plotme);
    case {'y', 'yellow'}
      ColourEllipsoids(7, :) = DoColour(PosGroundTruth, ColourPoints, 7, 'yellow', plotme);
    case {'br', 'brown'}
      ColourEllipsoids(8, :) = DoColour(PosGroundTruth, ColourPoints, 8, 'brown', plotme);
    case {'gr', 'grey'}
      ColourEllipsoids(9, :) = DoColour(PosGroundTruth, ColourPoints, 9, 'grey', plotme);
    case {'w', 'white'}
      ColourEllipsoids(10, :) = DoColour(PosGroundTruth, ColourPoints, 10, 'white', plotme);
    case {'bl', 'black'}
      ColourEllipsoids(11, :) = DoColour(PosGroundTruth, ColourPoints, 11, 'black', plotme);
    otherwise
      disp('Wrong category, returning the latest ellipsoid parameters.');
  end
end

if saveme
  RGBTitles = {'G', 'B', 'Pp', 'Pk', 'R', 'O', 'Y', 'Br', 'Gr', 'W', 'Bl'}; %#ok
  save([ColourSpace, '_ellipsoid_params_arash.mat'], 'ColourEllipsoids', 'RGBTitles');
end

end

function ColourEllipsoid = DoColour(PosGroundTruth, ColourPoints, ColourIndex, ColourName, plotme)

inds = PosGroundTruth(:, :, ColourIndex) > 0;
inds(:, :, 2) = inds(:, :, 1);
inds(:, :, 3) = inds(:, :, 1);

PositivePoints = ColourPoints(inds);
PositivePoints = reshape(PositivePoints, size(PositivePoints, 1) / 3, 3);

if plotme
  if ~isempty(PositivePoints)
    plot3(PositivePoints(:, 1), PositivePoints(:, 2), PositivePoints(:, 3), '.', 'Color', name2rgb(ColourName));
  end
end

if size(PositivePoints, 1) > 1
  initial = [mean(PositivePoints), std(PositivePoints), 0, 0, 0];
else
  initial = [PositivePoints, 10, 10, 10, 0, 0, 0];
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

RSS(1) = ColourEllipsoidFitting(initial, ColourPoints, PosGroundTruth(:, :, ColourIndex));
[ColourEllipsoid, RSS(2), exitflag, output] = fmincon(@(x) ColourEllipsoidFitting(x, ColourPoints, PosGroundTruth(:, :, ColourIndex)), initial, [], [], [], [], lb, ub, [], options);

disp ('================================================================');
disp (['         Colour category: ', ColourName]);
disp ('================================================================');
PrintFittingResults(output, ColourEllipsoid, RSS, exitflag, initial(4:6));

if plotme
  DrawEllipsoid(ColourEllipsoid, 'FaceColor', [1, 1, 1], 'EdgeColor', name2rgb(ColourName), 'FaceAlpha', 0.5);
end

end

function RSS = ColourEllipsoidFitting(x, ColourPoints, PosGroundTruth)

if ~isempty(ColourPoints)
  [belonging, ~] = EllipsoidEvaluateBelonging(ColourPoints, x);
  RSS = sum(sum(abs(PosGroundTruth - belonging)));
else
  RSS = 0;
end

end

function [WcsColourTable, PosGroundTruth] = SatfacesData()

SatfacesMat = load('satfaces.mat');
WcsColourTable = [];
FieldNames = fieldnames(SatfacesMat.ColourPoints);
for i = 1:length(FieldNames)
  WcsColourTable = [WcsColourTable; SatfacesMat.ColourPoints.(FieldNames{i})]; %#ok
end

nColourPoints = size(WcsColourTable, 1);
PosGroundTruth = zeros(nColourPoints, 1, 11);
LastIndex = 1;
for i = 1:length(FieldNames)
  nCurrentPoints = size(SatfacesMat.ColourPoints.(FieldNames{i}), 1);
  
  if nCurrentPoints > 0
    switch FieldNames{i}
      case {'g', 'green', 'darkgreen', 'lightgreen'}
        PosGroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 1) = 1;
      case {'b', 'blue', 'navyblue', 'darkblue', 'darkteal', 'teal', 'lightblue', 'cyan', 'skyblue'}
        PosGroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 2) = 1;
      case {'pp', 'purple', 'darkpurple', 'magenta'}
        PosGroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 3) = 1;
      case {'pk', 'pink'}
        PosGroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 4) = 1;
      case {'r', 'red', 'maroon', 'darkred'}
        PosGroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 5) = 1;
      case {'o', 'orange'}
        PosGroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 6) = 1;
      case {'y', 'yellow', 'gold', 'mustard', 'limegreen'}
        PosGroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 7) = 1;
      case {'br', 'brown', 'darkbrown', 'olive'}
        PosGroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 8) = 1;
      case {'gr', 'grey'}
        PosGroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 9) = 1;
      case {'w', 'white'}
        PosGroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 10) = 1;
      case {'bl', 'black'}
        PosGroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 11) = 1;
      otherwise
        disp(FieldNames{i});
    end
    
    LastIndex = LastIndex + nCurrentPoints;
  end
end
WcsColourTable = uint8(WcsColourTable);

WcsColourTable = reshape(WcsColourTable, 512, 384, 3);
PosGroundTruth = reshape(PosGroundTruth, 512, 384, 11);

end

