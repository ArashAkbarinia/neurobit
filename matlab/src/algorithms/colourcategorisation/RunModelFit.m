function ellipsoids = RunModelFit(WhichColours, plotme, saveme)

if nargin < 1
  WhichColours = {'a'};
end
if nargin < 2
  plotme = 1;
  saveme = 0;
end

if strcmpi(WhichColours{1}, 'a')
  WhichColours = {'G', 'B', 'Pp', 'Pk', 'R', 'O', 'Y', 'Br', 'Gr', 'W', 'Bl'};
end

global doproperdistance;
doproperdistance = 1;

R  = [1.0, 0.0, 0.0];
G  = [0.0, 1.0, 0.0];
B  = [0.0, 0.0, 1.0];
Y  = [1.0, 1.0, 0.0];
Pp = [0.7, 0.0, 0.7];
O  = [1.0, 0.5, 0.0];
Pk = [1.0, 0.0, 1.0];
Br = [1.0, 0.5, 0.0] * 0.75;
W  = [1.0, 1.0, 1.0];
Gr = [0.5, 0.5, 0.5];
Bl  = [0.0, 0.0, 0.0];

lsYFrontiers = organize_frontiers('rawdata_Lab.mat');
% lsY_limits;
%load('CRT_gamut_all');
WhichColours = lower(WhichColours);
ncolours = length(WhichColours);
ellipses = zeros(ncolours, 9);
RSSes = zeros(ncolours, 2);
tested = [];
if plotme
  figure;
end

FittingData = struct();
if doproperdistance
  options = optimset('MaxIter', 1e6, 'TolFun', 1e-10, 'MaxFunEvals', 1e6);
else
  options = optimoptions(@fmincon,'Algorithm', 'sqp', 'Display', 'off', 'MaxIter', 1e6, 'TolFun', 1e-10, 'MaxFunEvals', 1e6);
end

%========================= generate results ================================
for pp = 1:ncolours
  switch WhichColours{pp}
    case {'g', 'green'}
      FittingData.category = 'green';
      FittingParams = ColourEllipsoidFittingParams(lsYFrontiers.(FittingData.category));
      FittingParams.AxesDeviation = [10, 10, 10];
      FittingParams.EstimatedAxes = [4, 5, 1];
      FittingParams.MaxAxes = [inf, inf, inf];
      FittingParams.CentreDeviation = [1, 1, 1];
      FittingParams.EstimatedCentre = [0.6, 0, inf];
      FittingParams.EstimatedAngles = deg2rad([0, 0, 40]);
      FittingParams.AllStd = 100;
      
      [ellipses(1, :), RSSes(1, :)] = DoColour(FittingParams, FittingData, options, plotme);
      tested = [tested, 1];
    case {'b', 'blue'}
      FittingData.category = 'blue';
      FittingParams = ColourEllipsoidFittingParams(lsYFrontiers.(FittingData.category));
      FittingParams.AxesDeviation = [100, 100, 100];
      FittingParams.EstimatedAxes = [2, 11, 1];
      FittingParams.MaxAxes = [inf, inf, inf];
      FittingParams.CentreDeviation = [1, 1, 1];
      FittingParams.EstimatedCentre = [0.58, 0.25, 100];
      FittingParams.EstimatedAngles = deg2rad([0, 0, 18]);
      FittingParams.AllStd = 200;
      
      [ellipses(2, :), RSSes(2, :)] = DoColour(FittingParams, FittingData, options, plotme);
      tested = [tested, 2];
    case {'pp', 'purple'}
      FittingData.category = 'purple';
      FittingParams = ColourEllipsoidFittingParams(lsYFrontiers.(FittingData.category));
      FittingParams.AxesDeviation = [20, 20, 20];
      FittingParams.EstimatedAxes = [4, 7, 1];
      FittingParams.MaxAxes = [inf, inf, inf];
      FittingParams.CentreDeviation = [0.5, 0.5, 0.5];
      FittingParams.EstimatedCentre = [0.68, 0.20, inf];
      FittingParams.EstimatedAngles = deg2rad([0, 0, -10]);
      FittingParams.AllStd = 100;
      
      [ellipses(3, :), RSSes(3, :)] = DoColour(FittingParams, FittingData, options, plotme);
      tested = [tested, 3];
    case {'pk', 'pink'}
      FittingData.category = 'pink';
      FittingParams = ColourEllipsoidFittingParams(lsYFrontiers.(FittingData.category));
      FittingParams.AxesDeviation = [10, 10, 10];
      FittingParams.EstimatedAxes = [5, 3, 1];
      FittingParams.MaxAxes = [inf, inf, inf];
      FittingParams.CentreDeviation = [1, 1, 1];
      FittingParams.EstimatedCentre = [0.8, 0.1, inf];
      FittingParams.EstimatedAngles = deg2rad([0, 0, 10]);
      FittingParams.AllStd = 100;
      
      [ellipses(4, :), RSSes(4, :)] = DoColour(FittingParams, FittingData, options, plotme);
      tested = [tested, 4];
    case {'r', 'red'}
      FittingData.category = 'red';
      FittingParams = ColourEllipsoidFittingParams(lsYFrontiers.(FittingData.category));
      FittingParams.AxesDeviation = [10, 10, 10];
      FittingParams.EstimatedAxes = [5, 1.5, 1];
      FittingParams.MaxAxes = [inf, inf, 80];
      FittingParams.CentreDeviation = [0.5, 0.5, 0.5];
      FittingParams.EstimatedCentre = [0.800, 0.025, 0.000];
      FittingParams.EstimatedAngles = deg2rad([0, 0, -15]);
      FittingParams.AllStd = 50;
      
      [ellipses(5, :), RSSes(5, :)] = DoColour(FittingParams, FittingData, options, plotme);
      tested = [tested, 5];
    case {'o', 'orange'}
      FittingData.category = 'orange';
      FittingParams = ColourEllipsoidFittingParams(lsYFrontiers.(FittingData.category));
      FittingParams.AxesDeviation = [10, 10, 10];
      FittingParams.EstimatedAxes = [2, 10, 1];
      FittingParams.MaxAxes = [inf, inf, 100];
      FittingParams.CentreDeviation = [10, 10, 10];
      FittingParams.EstimatedCentre = [0.74, 0.00, 100];
      FittingParams.EstimatedAngles = deg2rad([0, 0, 53]);
      FittingParams.AllStd = 90;
      
      [ellipses(6, :), RSSes(6, :)] = DoColour(FittingParams, FittingData, options, plotme);
      tested = [tested, 6];
    case {'y', 'yellow'}
      FittingData.category = 'yellow';
      FittingParams = ColourEllipsoidFittingParams(lsYFrontiers.(FittingData.category));
      FittingParams.AxesDeviation = [5, 5, 5];
      FittingParams.EstimatedAxes = [1.5, 5, 1];
      FittingParams.MaxAxes = [inf, inf, 100];
      FittingParams.CentreDeviation = [1, 1, 1];
      FittingParams.EstimatedCentre = [0.68, 0.01, 100];
      FittingParams.EstimatedAngles = deg2rad([0, 0, 25]);
      FittingParams.AllStd = 90;
      
      [ellipses(7, :), RSSes(7, :)] = DoColour(FittingParams, FittingData, options, plotme);
      tested = [tested, 7];
    case {'br', 'brown'}
      FittingData.category = 'brown';
      FittingParams = ColourEllipsoidFittingParams(lsYFrontiers.(FittingData.category));
      FittingParams.AxesDeviation = [5, 5, 5];
      FittingParams.EstimatedAxes = [1, 4, 1];
      FittingParams.MaxAxes = [inf, inf, inf];
      FittingParams.CentreDeviation = [5, 5, 5];
      FittingParams.EstimatedCentre = [0.73, 0.00, 0.00];
      FittingParams.EstimatedAngles = deg2rad([0, 0, 57]);
      FittingParams.AllStd = 55;
      
      [ellipses(8, :), RSSes(8, :)] = DoColour(FittingParams, FittingData, options, plotme);
      tested = [tested, 8];
    case {'gr', 'grey'}
      FittingData.category = 'grey';
      FittingParams = ColourEllipsoidFittingParams(lsYFrontiers.(FittingData.category));
      FittingParams.AxesDeviation = [10, 10, 10];
      FittingParams.EstimatedAxes = [1, 1, 1];
      FittingParams.MaxAxes = [inf, inf, inf];
      FittingParams.CentreDeviation = [10, 10, 10];
      FittingParams.EstimatedCentre = [0.650, 0.059, inf];
      FittingParams.EstimatedAngles = deg2rad([0, 0, 45]);
      FittingParams.AllStd = 200;
      
      [ellipses(9, :), RSSes(9, :)] = DoColour(FittingParams, FittingData, options, plotme);
      tested = [tested, 9]; %#ok<*AGROW>
    case {'w', 'white'}
      FittingData.category = 'white';
      points = lsYFrontiers.(FittingData.category).GetAllBorders();
      ellipses(10, :) = [mean(points), 0.1, 0.1, std(points(:, 3)), 0, 0, 0];
      RSSes(10, :) = norm(DistanceEllipsoid(points, ellipses(10, :)), 'fro') .^ 2;
      tested = [tested, 10]; %#ok<*AGROW>
    case {'bl', 'black'}
      FittingData.category = 'black';
      points = lsYFrontiers.(FittingData.category).GetAllBorders();
      ellipses(11, :) = [mean(points), 0.1, 0.1, std(points(:, 3)), 0, 0, 0];
      RSSes(11, :) = norm(DistanceEllipsoid(points, ellipses(11, :)), 'fro') .^ 2;
      tested = [tested, 11]; %#ok<*AGROW>
    otherwise
      disp('Wrong category, quitting...');
      return;
  end
end

ellipsoids = [ellipses, RSSes(:, 2)];

if saveme
  RGBValues = [G; B; Pp; Pk; R; O; Y; Br; Gr; W; Bl]; %#ok
  RGBTitles = {'G', 'B', 'Pp', 'Pk', 'R', 'O', 'Y', 'Br', 'Gr', 'W', 'Bl'}; %#ok
  save('2014_ellipsoid_params_arash.mat', 'ellipsoids', 'RGBValues', 'RGBTitles');
end


if plotme
  RGB = [G; B; Pp; Pk; R; O; Y; Br; Gr; W; Bl];
  PlotEllipsoids(ellipses, RGB, tested, WhichColours);
end

end

function [ellipsoid, RSS] = DoColour(FittingParams, FittingData, options, plotme)

% FIXME; make it dynamic
borders = [25, 36, 47, 58, 70, 81];
% D65 XYZ cordinates calculated according to the CIE Judd-Vos corrected
% Colour Matching Functions
JV_D65 = [116.5366244	124.6721208	125.456254];
FittingData.borders = [];
for i = borders
  levelsXYZ = Lab2XYZ([i, 0, 0], JV_D65);
  FittingData.(['data', num2str(i)]) = FittingParams.colour.GetBorder(i);
  FittingData.(['ylevel', num2str(i)]) = levelsXYZ;
  FittingData.borders = [FittingData.borders; FittingData.(['data', num2str(i)])];
end

FittingData.allstd = std(FittingData.borders);
FittingData.allstd(3) = FittingParams.AllStd;
FittingData.allmeans = mean(FittingData.borders);
W_centre_l = FittingParams.EstimatedCentre(1);
W_centre_s = FittingParams.EstimatedCentre(2);
if FittingParams.EstimatedCentre(3) == inf
  W_centre_Y = FittingData.allmeans(3);
else
  W_centre_Y = FittingParams.EstimatedCentre(3);
end
W_axis_l = FittingParams.EstimatedAxes(1) * FittingData.allstd(1);
W_axis_s = FittingParams.EstimatedAxes(2) * FittingData.allstd(2);
W_axis_Y = FittingParams.EstimatedAxes(3) * FittingData.allstd(3);
W_axis_rotation = FittingParams.EstimatedAngles(3);
initial = [W_centre_l, W_centre_s, W_centre_Y, W_axis_l, W_axis_s, W_axis_Y, W_axis_rotation];

if plotme
  if ~isempty(FittingData.borders)
    plot3(FittingData.borders(:, 1), FittingData.borders(:, 2), FittingData.borders(:, 3), '.', 'Color', FittingParams.colour.rgb);
    hold on;
  end
end

global doproperdistance;
if doproperdistance
  RSS(1) = alej_fit_ellipsoid_optplot(initial, 0, 0, FittingData, FittingParams); % if you need to edit, do it below!
  [tmpellips, RSS(2), exitflag, output] = fminsearch(@(x) alej_fit_ellipsoid_optplot(x, 0, 0, FittingData, FittingParams), initial, options);
  ellipsoid = [tmpellips(1:6), 0, 0, tmpellips(7)];
else
  fs = std([FittingData.data36; FittingData.data58; FittingData.data81]);
  fm = mean([FittingData.data36; FittingData.data58; FittingData.data81]);
  %   initial = [initial(1:6), 0, 0, initial(7)];
  initial = [fm, fs, 0, 0, 0];
  RSS(1) = alej_fit_ellipsoid_optplot(initial, 0, 0, FittingData, FittingParams); % if you need to edit, do it below!
  lb = [fm - fs, 0, 0, 0, 0, 0, 0];
  ub = [fm - fs, 10 * fs, 0, 0, 0];
  %   [ellipsoid, RSS(2), exitflag, output] = fminsearch(@(x) alej_fit_ellipsoid_optplot(x, 0, 0, FittingData), initial, options);
  [ellipsoid, RSS(2), exitflag, output] = fmincon(@(x) alej_fit_ellipsoid_optplot(x, 0, 0, FittingData, FittingParams), initial, [], [], [], [], lb, ub, @EllipsoidEq, options);
end

disp ('================================================================');
disp (['         Colour category: ', FittingData.category]);
disp ('================================================================');
showme_results(output, ellipsoid, RSS, exitflag, FittingData);

end

function [c, ceq] = EllipsoidEq(x)

c = [];
x = x .^ 2;
ceq = x(1) / x(4) + x(2) / x(5) + x(3) / x(6) - 1;
ceq = [];

end

function PlotEllipsoids(ellipses, RGB, tested, WhichColours)

for i = tested
  DrawEllipsoid(ellipses(i, :), 'FaceColor', [1, 1, 1], 'EdgeColor', RGB(i, :), 'FaceAlpha', 0.3);
  hold on;
end

if length(WhichColours) == 9
  cateq = 'all categories';
else
  cateq = [];
  for pq = 1:length(WhichColours)
    switch WhichColours{pq}
      case {'g', 'green'}
        cateq = [cateq, 'green, '];
      case {'b', 'blue'}
        cateq = [cateq, 'blue, '];
      case {'pp', 'purple'}
        cateq = [cateq, 'purple, '];
      case {'pk', 'pink'}
        cateq = [cateq, 'pink, '];
      case {'r', 'red'}
        cateq = [cateq, 'red, '];
      case {'o', 'orange'}
        cateq = [cateq, 'orange, '];
      case {'y', 'yellow'}
        cateq = [cateq, 'yellow, '];
      case {'br', 'brown'}
        cateq = [cateq, 'brown, '];
      case {'gr', 'grey'}
        cateq = [cateq, 'grey, '];
      case {'w', 'white'}
        cateq = [cateq, 'white, '];
      case {'bl', 'black'}
        cateq = [cateq, 'black, '];
    end
  end
  cateq(size(cateq, 2)) = '';
  cateq(size(cateq, 2)) = '';
end

title(['Category boundaries (', cateq, ') - best elipsod fits']);
xlabel('l');
ylabel('s');
zlabel('Y');
view(-19, 54);
grid on;
set(gcf, 'color', [1, 1, 1]);
hold off;

end
