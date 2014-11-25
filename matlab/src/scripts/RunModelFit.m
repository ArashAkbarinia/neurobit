function ellipsoids = RunModelFit(WhichColours, plotme, saveme)

if nargin < 1
  WhichColours = {'a'};
end
if nargin < 2
  plotme = 1;
  saveme = 0;
end

if strcmpi(WhichColours{1}, 'a')
  WhichColours = {'G', 'B', 'Pp', 'Pk', 'R', 'O', 'Y', 'Br', 'Gr'};
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

%frontiers_2014;
lsYFrontiers = organize_frontiers('rawdata_Lab.mat');
% lsY_limits;
%load('CRT_gamut_all');
WhichColours = lower(WhichColours);
ellipses = zeros(9, 7);
RSSes = zeros(9, 2);
tested = [];
if plotme
  figure;
end
% D65 XYZ cordinates calculated according to the CIE Judd-Vos corrected
% Colour Matching Functions
JV_D65 = [116.5366244	124.6721208	125.456254];
levelsXYZ = [Lab2XYZ([36, 0, 0], JV_D65); Lab2XYZ([58, 0, 0], JV_D65); Lab2XYZ([81, 0, 0], JV_D65)];
FittingData = struct();
FittingData.Y_level36 = levelsXYZ(1, 2);
FittingData.Y_level58 = levelsXYZ(2, 2);
FittingData.Y_level81 = levelsXYZ(3, 2);
options = optimset('MaxIter', 1e6, 'TolFun', 1e-10, 'MaxFunEvals', 1e6);

%========================= generate results ================================
for pp = 1:length(WhichColours)
  switch WhichColours{pp}
    case {'g', 'green'}
      FittingData.category = 'green';
      FittingData.kolor = G;
      FittingData.data36 = [lsYFrontiers.lsY_36_G_B; lsYFrontiers.lsY_36_Br_G; lsYFrontiers.lsY_36_W_G];
      FittingData.data58 = [lsYFrontiers.lsY_58_G_B; lsYFrontiers.lsY_58_Y_G;  lsYFrontiers.lsY_58_W_G];
      FittingData.data81 = [lsYFrontiers.lsY_81_G_B; lsYFrontiers.lsY_81_Y_G;  lsYFrontiers.lsY_81_W_G];
      FittingData.allstd = std([FittingData.data36; FittingData.data58; FittingData.data81]);
      FittingData.allstd(3) = 100;
      FittingData.allmeans = mean([FittingData.data36; FittingData.data58; FittingData.data81]);
      W_centre_l = 0.60; %allmeans(1);
      W_centre_s = 0.00; %allmeans(2);
      W_centre_Y = FittingData.allmeans(3);
      W_axis_l   = 4 * FittingData.allstd(1);
      W_axis_s   = 5 * FittingData.allstd(2);
      W_axis_Y   = FittingData.allstd(3);
      W_axis_rotation = 40; %(*) in degrees counterclockwise
      W_axis_rotation = deg2rad(W_axis_rotation);
      initial = [W_centre_l, W_centre_s, W_centre_Y, W_axis_l, W_axis_s, W_axis_Y, W_axis_rotation];
      [ellipses(1, :), RSSes(1, :)] = DoColour(FittingData, initial, options, plotme);
      tested = [tested, 1];
    case {'b', 'blue'}
      FittingData.category = 'blue';
      FittingData.kolor = B;
      FittingData.data36 = [lsYFrontiers.lsY_36_G_B; lsYFrontiers.lsY_36_B_Pp; lsYFrontiers.lsY_36_W_B];
      FittingData.data58 = [lsYFrontiers.lsY_58_G_B; lsYFrontiers.lsY_58_B_Pp; lsYFrontiers.lsY_58_W_B];
      FittingData.data81 = [lsYFrontiers.lsY_81_G_B; lsYFrontiers.lsY_81_B_Pp; lsYFrontiers.lsY_81_W_B];
      FittingData.allstd = std([FittingData.data36; FittingData.data58; FittingData.data81]);
      FittingData.allstd(3) = 200;
      FittingData.allmeans = mean([FittingData.data36; FittingData.data58; FittingData.data81]);
      W_centre_l = 0.58; %0.6; %allmeans(1);
      W_centre_s = 0.25; %0.15; %allmeans(2);
      W_centre_Y = 100;  %allmeans(3);
      W_axis_l   = 2 * FittingData.allstd(1);
      W_axis_s   = 11 * FittingData.allstd(2);
      W_axis_Y   = FittingData.allstd(3);
      W_axis_rotation = 18; %(*) in degrees counterclockwise
      W_axis_rotation = deg2rad(W_axis_rotation);
      initial = [W_centre_l, W_centre_s, W_centre_Y, W_axis_l, W_axis_s, W_axis_Y, W_axis_rotation];
      [ellipses(2, :), RSSes(2, :)] = DoColour(FittingData, initial, options, plotme);
      tested = [tested, 2];
    case {'pp', 'purple'}
      FittingData.category = 'purple';
      FittingData.kolor = Pp;
      FittingData.data36 = [lsYFrontiers.lsY_36_B_Pp; lsYFrontiers.lsY_36_Pp_Pk; lsYFrontiers.lsY_36_W_Pp];
      FittingData.data58 = [lsYFrontiers.lsY_58_B_Pp; lsYFrontiers.lsY_58_Pp_Pk; lsYFrontiers.lsY_58_W_Pp];
      FittingData.data81 = [lsYFrontiers.lsY_81_B_Pp; lsYFrontiers.lsY_81_Pp_Pk; lsYFrontiers.lsY_81_W_Pp];
      FittingData.allstd = std([FittingData.data36; FittingData.data58; FittingData.data81]);
      FittingData.allstd(3) = 100;
      FittingData.allmeans = mean([FittingData.data36; FittingData.data58; FittingData.data81]);
      W_centre_l =  0.68; %allmeans(1);
      W_centre_s =  0.20; %allmeans(2);
      W_centre_Y = FittingData.allmeans(3);
      W_axis_l   = 4*FittingData.allstd(1);
      W_axis_s   = 7*FittingData.allstd(2);
      W_axis_Y   = FittingData.allstd(3);
      W_axis_rotation= -10; %(*) in degrees counterclockwise
      W_axis_rotation = deg2rad(W_axis_rotation);
      initial = [W_centre_l, W_centre_s, W_centre_Y, W_axis_l, W_axis_s, W_axis_Y, W_axis_rotation];
      [ellipses(3, :), RSSes(3, :)] = DoColour(FittingData, initial, options, plotme);
      tested = [tested, 3];
    case {'pk', 'pink'}
      FittingData.category = 'pink';
      FittingData.kolor = Pk;
      FittingData.data36 = [lsYFrontiers.lsY_36_Pp_Pk; lsYFrontiers.lsY_36_Pk_R; lsYFrontiers.lsY_36_W_Pk];
      FittingData.data58 = [lsYFrontiers.lsY_58_Pp_Pk; lsYFrontiers.lsY_58_Pk_R; lsYFrontiers.lsY_58_W_Pk];
      FittingData.data81 = [lsYFrontiers.lsY_81_Pp_Pk; lsYFrontiers.lsY_81_Pk_O; lsYFrontiers.lsY_81_W_Pk];
      FittingData.allstd = std([FittingData.data36; FittingData.data58; FittingData.data81]);
      FittingData.allstd(3) = 100;
      FittingData.allmeans = mean([FittingData.data36; FittingData.data58; FittingData.data81]);
      W_centre_l = 0.8;%allmeans(1);
      W_centre_s = 0.1 ;%allmeans(2);
      W_centre_Y = FittingData.allmeans(3);
      W_axis_l   = 5*FittingData.allstd(1);
      W_axis_s   = 3*FittingData.allstd(2);
      W_axis_Y   = FittingData.allstd(3);
      W_axis_rotation= 10; %(*) in degrees counterclockwise
      W_axis_rotation = deg2rad(W_axis_rotation);
      initial = [W_centre_l, W_centre_s, W_centre_Y, W_axis_l, W_axis_s, W_axis_Y, W_axis_rotation];
      [ellipses(4, :), RSSes(4, :)] = DoColour(FittingData, initial, options, plotme);
      tested = [tested, 4];
    case {'r', 'red'}
      FittingData.category = 'red';
      FittingData.kolor = R;
      FittingData.data36 = [lsYFrontiers.lsY_36_Pk_R; lsYFrontiers.lsY_36_R_Br;  lsYFrontiers.lsY_36_W_R];
      FittingData.data58 = [lsYFrontiers.lsY_58_Pk_R; lsYFrontiers.lsY_58_R_O;   lsYFrontiers.lsY_58_W_R];
      FittingData.data81 = [];
      FittingData.allstd = std([FittingData.data36;FittingData.data58;FittingData.data81]);
      FittingData.allstd(3) = 50;
      FittingData.allmeans = mean([FittingData.data36;FittingData.data58;FittingData.data81]);
      W_centre_l = 0.8;%FittingData.allmeans(1);
      W_centre_s = 0.025;%FittingData.allmeans(2);
      W_centre_Y = 0;%FittingData.allmeans(3);
      W_axis_l   = 5*FittingData.allstd(1);
      W_axis_s   = 1.5*FittingData.allstd(2);
      W_axis_Y   = FittingData.allstd(3);
      W_axis_rotation= -15; %(*) in degrees counterclockwise
      W_axis_rotation = deg2rad(W_axis_rotation);
      initial = [W_centre_l, W_centre_s, W_centre_Y, W_axis_l, W_axis_s, W_axis_Y, W_axis_rotation];
      [ellipses(5, :), RSSes(5, :)] = DoColour(FittingData, initial, options, plotme);
      tested = [tested, 5];
    case {'o', 'orange'}
      FittingData.category = 'orange';
      FittingData.kolor = O;
      FittingData.data36 = [];
      FittingData.data58 = [lsYFrontiers.lsY_58_R_O;  lsYFrontiers.lsY_58_O_Y; lsYFrontiers.lsY_58_W_O];
      FittingData.data81 = [lsYFrontiers.lsY_81_Pk_O; lsYFrontiers.lsY_81_O_Y; lsYFrontiers.lsY_81_W_O];
      FittingData.allstd = std([FittingData.data36; FittingData.data58; FittingData.data81]);
      FittingData.allstd(3) = 90;%150;
      FittingData.allmeans = mean([FittingData.data36; FittingData.data58; FittingData.data81]);
      W_centre_l = 0.74;%FittingData.allmeans(1);
      W_centre_s = 0.00;%FittingData.allmeans(2);
      W_centre_Y = 100;%FittingData.allmeans(3);
      W_axis_l   = 2*FittingData.allstd(1);
      W_axis_s   = 10*FittingData.allstd(2);
      W_axis_Y   = FittingData.allstd(3);
      W_axis_rotation= 53; %(*) in degrees counterclockwise
      W_axis_rotation = deg2rad(W_axis_rotation);
      initial = [W_centre_l, W_centre_s, W_centre_Y, W_axis_l, W_axis_s, W_axis_Y, W_axis_rotation];
      [ellipses(6, :), RSSes(6, :)] = DoColour(FittingData, initial, options, plotme);
      tested = [tested, 6];
    case {'y', 'yellow'}
      FittingData.category = 'yellow';
      FittingData.kolor = Y;
      FittingData.data36 = [];
      FittingData.data58 = [lsYFrontiers.lsY_58_O_Y; lsYFrontiers.lsY_58_Y_G; lsYFrontiers.lsY_58_W_Y];
      FittingData.data81 = [lsYFrontiers.lsY_81_O_Y; lsYFrontiers.lsY_81_Y_G; lsYFrontiers.lsY_81_W_Y];
      FittingData.allstd = std([FittingData.data36; FittingData.data58; FittingData.data81]);
      FittingData.allstd(3) = 90;
      FittingData.allmeans = mean([FittingData.data36; FittingData.data58; FittingData.data81]);
      W_centre_l =  0.68;%FittingData.allmeans(1);
      W_centre_s =  0.01;%FittingData.allmeans(2);
      W_centre_Y = 100; %FittingData.allmeans(3);
      W_axis_l   = 1.5*FittingData.allstd(1);
      W_axis_s   = 5*FittingData.allstd(2);
      W_axis_Y   = FittingData.allstd(3);
      W_axis_rotation= 25; %(*) in degrees counterclockwise
      W_axis_rotation = deg2rad(W_axis_rotation);
      initial = [W_centre_l, W_centre_s, W_centre_Y, W_axis_l, W_axis_s, W_axis_Y, W_axis_rotation];
      [ellipses(7, :), RSSes(7, :)] = DoColour(FittingData, initial, options, plotme);
      tested = [tested, 7];
    case {'br', 'brown'}
      FittingData.category = 'brown';
      FittingData.kolor = Br;
      FittingData.data36 = [lsYFrontiers.lsY_36_R_Br; lsYFrontiers.lsY_36_Br_G; lsYFrontiers.lsY_36_W_Br];
      FittingData.data58 = [];
      FittingData.data81 = [];
      FittingData.allstd = std([FittingData.data36; FittingData.data58; FittingData.data81]);
      FittingData.allstd(3) = 55;
      FittingData.allmeans = mean([FittingData.data36; FittingData.data58; FittingData.data81]);
      W_centre_l = 0.73; %FittingData.allmeans(1);
      W_centre_s = 0.00; %FittingData.allmeans(2);
      W_centre_Y = 0; %FittingData.allmeans(3);
      W_axis_l   = FittingData.allstd(1);
      W_axis_s   = 4*FittingData.allstd(2);
      W_axis_Y   = FittingData.allstd(3);
      W_axis_rotation= 57; %(*) in degrees counterclockwise
      W_axis_rotation = deg2rad(W_axis_rotation);
      initial = [W_centre_l, W_centre_s, W_centre_Y, W_axis_l, W_axis_s, W_axis_Y, W_axis_rotation];
      [ellipses(8, :), RSSes(8, :)] = DoColour(FittingData, initial, options, plotme);
      tested = [tested, 8];
    case {'gr', 'grey'}
      FittingData.category = 'grey';
      FittingData.kolor = Gr;
      FittingData.data36 = [lsYFrontiers.lsY_36_W_G; lsYFrontiers.lsY_36_W_B; lsYFrontiers.lsY_36_W_Pp; lsYFrontiers.lsY_36_W_Pk; lsYFrontiers.lsY_36_W_R; lsYFrontiers.lsY_36_W_Br];
      FittingData.data58 = [lsYFrontiers.lsY_58_W_G; lsYFrontiers.lsY_58_W_B; lsYFrontiers.lsY_58_W_Pp; lsYFrontiers.lsY_58_W_Pk; lsYFrontiers.lsY_58_W_R; lsYFrontiers.lsY_58_W_O; lsYFrontiers.lsY_58_W_Y];
      FittingData.data81 = [lsYFrontiers.lsY_81_W_G; lsYFrontiers.lsY_81_W_B; lsYFrontiers.lsY_81_W_Pp; lsYFrontiers.lsY_81_W_Pk; lsYFrontiers.lsY_81_W_O; lsYFrontiers.lsY_81_W_Y];
      FittingData.allstd = std([FittingData.data36; FittingData.data58; FittingData.data81]);
      FittingData.allstd(3) = 200;
      FittingData.allmeans = mean([FittingData.data36; FittingData.data58; FittingData.data81]);
      W_centre_l =  0.65;%	FittingData.allmeans(1);
      W_centre_s =  0.059;%FittingData.allmeans(2);
      W_centre_Y = FittingData.allmeans(3);
      W_axis_l   = FittingData.allstd(1);
      W_axis_s   = FittingData.allstd(2);
      W_axis_Y   = FittingData.allstd(3);
      W_axis_rotation= 45; %(*) in degrees counterclockwise
      W_axis_rotation = deg2rad(W_axis_rotation);
      initial = [W_centre_l, W_centre_s, W_centre_Y, W_axis_l, W_axis_s, W_axis_Y, W_axis_rotation];
      [ellipses(9, :), RSSes(9, :)] = DoColour(FittingData, initial, options, plotme);
      tested = [tested, 9]; %#ok<*AGROW>
    otherwise
      disp('Wrong category, quitting...');
      return;
  end
end

ellipsoids = [ellipses, RSSes(:, 2)];

if saveme
  RGBValues = [G; B; Pp; Pk; R; O; Y; Br; Gr];
  % TODO: remove LUM as it's not one of the ellipsoids
  RGBTitles = {'G', 'B', 'Pp', 'Pk', 'R', 'O', 'Y', 'Br', 'Gr', 'Lum'};
  save('2014_ellipsoid_params.mat', 'ellipsoids', 'RGBValues', 'RGBTitles');
end


%=========================generate mesh ===================================

if plotme
  RGB = [G; B; Pp; Pk; R; O; Y; Br; Gr; W];
  W_axis_orient = [0, 0, 1];
  PlotEllipsoids(ellipses, RGB, tested, W_axis_orient, WhichColours);
end

end

function [ellipsoid, RSS] = DoColour(FittingData, initial, options, plotme)

if plotme
  if ~isempty(FittingData.data36)
    plot3(FittingData.data36(:, 1), FittingData.data36(:, 2), FittingData.data36(:, 3), '.', 'Color', FittingData.kolor * 0.36); hold on;
  end
  if ~isempty(FittingData.data58)
    plot3(FittingData.data58(:, 1), FittingData.data58(:, 2), FittingData.data58(:, 3), '.', 'Color', FittingData.kolor * 0.58); hold on;
  end
  if ~isempty(FittingData.data81)
    plot3(FittingData.data81(:, 1), FittingData.data81(:, 2), FittingData.data81(:, 3), '.', 'Color', FittingData.kolor * 0.81); hold on;
  end
end

RSS(1) = alej_fit_ellipsoid_optplot(initial, 0, 0, FittingData); % if you need to edit, do it below!
[ellipsoid, RSS(2), exitflag, output] = fminsearch(@(x) alej_fit_ellipsoid_optplot(x, 0, 0, FittingData), initial, options);

disp ('================================================================');
disp (['         Colour category: ', FittingData.category]);
disp ('================================================================');
showme_results(output, ellipsoid, RSS, exitflag, FittingData);

end

function PlotEllipsoids(ellipses, RGB, tested, W_axis_orient, WhichColours)

for kk = tested
  [x, y, z] = alej_ellipsoid(ellipses(kk, 1:3), ellipses(kk, 4:6), W_axis_orient, rad2deg(ellipses(kk, 7)), ellipses(kk, 1:3));
  mesh(x, y, z,'EdgeColor', RGB(kk, :)); alpha(0.4); hold on;
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
        cateq = [cateq, 'achromatic, '];
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
