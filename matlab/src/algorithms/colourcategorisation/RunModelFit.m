function ColourEllipsoids = RunModelFit(WhichColours, plotme, saveme)

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

WhichColours = lower(WhichColours);
ncolours = length(WhichColours);
ellipses = zeros(11, 9);
RSSes = zeros(11, 2);

% for testing only one colour
GoodResult = load('2014_ellipsoid_params.mat');
ellipses(:, 1:9) = GoodResult.ColourEllipsoids(:, 1:9);
RSSes(:, 2) = GoodResult.ColourEllipsoids(:, 10);

tested = [];
if plotme
  figure;
end

FittingData = struct();
options = optimoptions(@fmincon,'Algorithm', 'sqp', 'Display', 'off', 'MaxIter', 1e6, 'TolFun', 1e-10, 'MaxFunEvals', 1e6);

%========================= generate results ================================
for pp = 1:ncolours
  switch WhichColours{pp}
    case {'g', 'green'}
      FittingData.category = 'green';
      FittingParams = ColourEllipsoidFittingParams(lsYFrontiers.(FittingData.category));
      FittingParams.EstimatedAxes = [0.0771, 0.1204, 251.7392];
      FittingParams.EstimatedCentre = [0.6, 0, 0];
      FittingParams.EstimatedAngles = deg2rad([0, 0, 40]);
      
      [ellipses(1, :), RSSes(1, :)] = DoColour(FittingParams, FittingData, options, plotme, []);
      tested = [tested, 1];
    case {'b', 'blue'}
      FittingData.category = 'blue';
      FittingParams = ColourEllipsoidFittingParams(lsYFrontiers.(FittingData.category));
      FittingParams.EstimatedAxes = [0.0993, 0.1866, 342.2729];
      FittingParams.EstimatedCentre = [0.58, 0.25, 0];
      FittingParams.EstimatedAngles = deg2rad([0, 0, 18]);
      
      [ellipses(2, :), RSSes(2, :)] = DoColour(FittingParams, FittingData, options, plotme, []);
      tested = [tested, 2];
    case {'pp', 'purple'}
      FittingData.category = 'purple';
      FittingParams = ColourEllipsoidFittingParams(lsYFrontiers.(FittingData.category));
      FittingParams.EstimatedAxes = [0.0589, 0.1128, 209.5232];
      FittingParams.EstimatedCentre = [0.68, 0.20, 72];
      FittingParams.EstimatedAngles = deg2rad([0, 0, 170]);
      
      [ellipses(3, :), RSSes(3, :)] = DoColour(FittingParams, FittingData, options, plotme, []);
      tested = [tested, 3];
    case {'pk', 'pink'}
      FittingData.category = 'pink';
      FittingParams = ColourEllipsoidFittingParams(lsYFrontiers.(FittingData.category));
      FittingParams.EstimatedAxes = [0.1125, 0.0582, 96.9293];
      FittingParams.EstimatedCentre = [0.8, 0.1, 63];
      FittingParams.EstimatedAngles = deg2rad([0, 0, 10]);
      
      [ellipses(4, :), RSSes(4, :)] = DoColour(FittingParams, FittingData, options, plotme, []);
      tested = [tested, 4];
    case {'r', 'red'}
      FittingData.category = 'red';
      FittingParams = ColourEllipsoidFittingParams(lsYFrontiers.(FittingData.category));
      FittingParams.EstimatedAxes = [0.1012, 0.0155, 79.9999];
      FittingParams.EstimatedCentre = [0.800, 0.025, 0.000];
      FittingParams.EstimatedAngles = deg2rad([0, 0, 165]);
      
      [ellipses(5, :), RSSes(5, :)] = DoColour(FittingParams, FittingData, options, plotme, []);
      tested = [tested, 5];
    case {'o', 'orange'}
      FittingData.category = 'orange';
      FittingParams = ColourEllipsoidFittingParams(lsYFrontiers.(FittingData.category));
      FittingParams.EstimatedAxes = [0.0247, 0.0785, 100.0000];
      FittingParams.EstimatedCentre = [0.74, 0.00, 100];
      FittingParams.EstimatedAngles = deg2rad([0, 0, 53]);
      
      [ellipses(6, :), RSSes(6, :)] = DoColour(FittingParams, FittingData, options, plotme, []);
      tested = [tested, 6];
    case {'y', 'yellow'}
      FittingData.category = 'yellow';
      FittingParams = ColourEllipsoidFittingParams(lsYFrontiers.(FittingData.category));
      FittingParams.EstimatedAxes = [0.0205, 0.0498, 100.0000];
      FittingParams.EstimatedCentre = [0.68, 0.01, 100];
      FittingParams.EstimatedAngles = deg2rad([0, 0, 25]);
      
      [ellipses(7, :), RSSes(7, :)] = DoColour(FittingParams, FittingData, options, plotme, []);
      tested = [tested, 7];
    case {'br', 'brown'}
      FittingData.category = 'brown';
      FittingParams = ColourEllipsoidFittingParams(lsYFrontiers.(FittingData.category));
      FittingParams.EstimatedAxes = [0.0246, 0.0512, 62.4239];
      FittingParams.EstimatedCentre = [0.73, 0.02, 0.00];
      FittingParams.EstimatedAngles = deg2rad([0, 0, 57]);
      
      [ellipses(8, :), RSSes(8, :)] = DoColour(FittingParams, FittingData, options, plotme, []);
      tested = [tested, 8];
    case {'gr', 'grey'}
      FittingData.category = 'grey';
      FittingParams = ColourEllipsoidFittingParams(lsYFrontiers.(FittingData.category));
      FittingParams.EstimatedAxes = [0.0145, 0.0243, 40];
      FittingParams.EstimatedCentre = [0.650, 0.059, 50];
      FittingParams.EstimatedAngles = deg2rad([0, 0, 45]);
      
      [ellipses(9, :), RSSes(9, :)] = DoColour(FittingParams, FittingData, options, plotme, []);
      ellipses(10, :) = ellipses(9, :);
      ellipses(10, 3) = 100;
      ellipses(10, 6) = 20;
      ellipses(11, :) = ellipses(9, :);
      ellipses(11, 3) = 0;
      ellipses(11, 6) = 20;
      tested = [tested, 9, 10, 11]; %#ok<*AGROW>
    case {'w', 'white'}
      %       FittingData.category = 'white';
      %       points = lsYFrontiers.(FittingData.category).GetAllBorders();
      %       ellipses(10, :) = [mean(points), 0.1, 0.1, std(points(:, 3)), 0, 0, 0];
      %       RSSes(10, :) = norm(DistanceEllipsoid(points, ellipses(10, :)), 'fro') .^ 2;
      %       tested = [tested, 10]; %#ok<*AGROW>
    case {'bl', 'black'}
      %       FittingData.category = 'black';
      %       points = lsYFrontiers.(FittingData.category).GetAllBorders();
      %       ellipses(11, :) = [mean(points), 0.1, 0.1, std(points(:, 3)), 0, 0, 0];
      %       RSSes(11, :) = norm(DistanceEllipsoid(points, ellipses(11, :)), 'fro') .^ 2;
      %       tested = [tested, 11]; %#ok<*AGROW>
    otherwise
      disp('Wrong category, quitting...');
      return;
  end
end

ColourEllipsoids = [ellipses, RSSes(:, 2)];

if saveme
  RGBTitles = {'G', 'B', 'Pp', 'Pk', 'R', 'O', 'Y', 'Br', 'Gr', 'W', 'Bl'}; %#ok
  save('2014_ellipsoid_params_arash.mat', 'ColourEllipsoids', 'RGBTitles');
end


if plotme
  RGB = [G; B; Pp; Pk; R; O; Y; Br; Gr; W; Bl];
  PlotEllipsoids(ellipses, RGB, tested, WhichColours);
end

end

function [ellipsoid, RSS] = DoColour(FittingParams, FittingData, options, plotme, initial)

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

if plotme
  if ~isempty(FittingData.borders)
    plot3(FittingData.borders(:, 1), FittingData.borders(:, 2), FittingData.borders(:, 3), '.', 'Color', FittingParams.colour.rgb);
    hold on;
  end
end

FittingData.allstd = std(FittingData.borders);
FittingData.allmeans = mean(FittingData.borders);

if isempty(initial)
  FittingParams.EstimatedCentre(1:2) = FittingParams.EstimatedCentre(1:2) * 100;
  FittingParams.EstimatedAxes(1:2) = FittingParams.EstimatedAxes(1:2) * 100;
  initial = [FittingParams.EstimatedCentre, FittingParams.EstimatedAxes, FittingParams.EstimatedAngles];
end
RSS(1) = ColourEllipsoidFitting(initial, FittingData);
FittingParams.MinCentre = initial(1:3) - 0.05 .* initial(1:3);
FittingParams.MaxCentre = initial(1:3) + 0.05 .* initial(1:3);
FittingParams.MinAxes = initial(4:6) .* 0.9;
FittingParams.MaxAxes = initial(4:6) .* 1.1;
FittingParams.MinAngle = initial(7:9) .* 0.9;
FittingParams.MaxAngle = initial(7:9) .* 1.1;
lb = ...
  [
  FittingParams.MinCentre, FittingParams.MinAxes, FittingParams.MinAngle
  ];
ub = ...
  [
  FittingParams.MaxCentre, FittingParams.MaxAxes, FittingParams.MaxAngle
  ];
[ellipsoid, RSS(2), exitflag, output] = fmincon(@(x) ColourEllipsoidFitting(x, FittingData), initial, [], [], [], [], lb, ub, [], options);

disp ('================================================================');
disp (['         Colour category: ', FittingData.category]);
disp ('================================================================');
PrintFittingResults(output, ellipsoid, RSS, exitflag, FittingData.allstd);

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

function RSS = ColourEllipsoidFitting(x, FittingData)
% Describe the function
% This function does the actual fitting of the three level datapoints
% obtained by variables data36 data58 and data81 and the 3D-ellipsoid.
% The datapoints correspond to the psychophysical results obtained through
% colour categorization experiments in the frontiers between colour names.
% The ellipsoid parameters are passed to the funtion though the variable x
% which contains the centre and the semi-axes of the 3D-ellipsoid to fit to
% the data. Imagine the ellipsoid as a rugby ball placed with its main axis
% vertically. It intersects the three horizontal dataplanes (at three
% luminance levels) forming three horizontal ellipses.
% The actual fitting is done considering the distance between each
% point in the luminance data plane and the closest point on the ellipse
% for each plane. The output of this function is the residual
% sum of squares (RSS) of these distances, added for the three planes.
% Since the data in the lowest luminance plane has the largest variance, it
% tends to bias the fitting. To counter this, we weighted the RSS
% corresponding to each luminance plane.

if ~isempty(FittingData.borders)
  distances = DistanceEllipsoid(FittingData.borders, x, 0);
  %  The Frobenius norm, sometimes also called the Euclidean norm (which may
  %  cause confusion with the vector L^2-norm which also sometimes known as
  %  the Euclidean norm), is matrix norm of an min matrix  A defined as the
  %  square root of the sum of the absolute squares of its elements
  %   RSS = norm(distances, 'fro');
  RSS = mean(distances);
else
  RSS = 0;
end

end
