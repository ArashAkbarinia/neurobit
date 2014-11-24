function ellipsoids = RunModelFit(varargin)

FittingData = struct();

if nargin < 1
  varargin{1} = 'a';
end

if strcmp(varargin{1}, 'a')
  varargin = {'G' 'B' 'Pp' 'Pk' 'R' 'O' 'Y' 'Br' 'Gr'};
  mynargin = 9;
else
  mynargin = nargin;
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
RGB = [G; B; Pp; Pk; R; O; Y; Br; Gr; W];
RGBValues = [G; B; Pp; Pk; R; O; Y; Br; Gr];
RGBTitles = {'G', 'B', 'Pp', 'Pk', 'R', 'O', 'Y', 'Br', 'Gr', 'Lum'};

%frontiers_2014;
lsYFrontiers = organize_frontiers('rawdata_Lab.mat');
% lsY_limits;
%load('CRT_gamut_all');
varargin = lower(varargin);
myxx = zeros(9, 7);
myRSS = zeros(9, 2);
tested = [];
figure;
% D65 XYZ cordinates calculated according to the CIE Judd-Vos corrected
% Colour Matching Functions
JV_D65 = [116.5366244	124.6721208	125.456254];
levelsXYZ = [Lab2XYZ([36, 0, 0], JV_D65); Lab2XYZ([58, 0, 0], JV_D65); Lab2XYZ([81, 0, 0], JV_D65)];
FittingData.Y_level36 = levelsXYZ(1, 2);
FittingData.Y_level58 = levelsXYZ(2, 2);
FittingData.Y_level81 = levelsXYZ(3, 2);
W_axis_orient = [0 0 1];
options = optimset('MaxIter', 1e6,'TolFun', 1e-10, 'MaxFunEvals', 1e6);

%========================= generate results ================================
for pp = 1:mynargin
  switch varargin{pp}
    case {'g', 'green'}
      FittingData.category = 'green';
      kolor = G;
      FittingData.data36 = [lsYFrontiers.lsY_36_G_B; lsYFrontiers.lsY_36_Br_G; lsYFrontiers.lsY_36_W_G];
      FittingData.data58 = [lsYFrontiers.lsY_58_G_B; lsYFrontiers.lsY_58_Y_G;  lsYFrontiers.lsY_58_W_G];
      FittingData.data81 = [lsYFrontiers.lsY_81_G_B; lsYFrontiers.lsY_81_Y_G;  lsYFrontiers.lsY_81_W_G];
      plot3(FittingData.data36(:, 1), FittingData.data36(:, 2), FittingData.data36(:, 3), '.', 'Color', kolor * 0.36); hold on;
      plot3(FittingData.data58(:, 1), FittingData.data58(:, 2), FittingData.data58(:, 3), '.', 'Color', kolor * 0.58); hold on;
      plot3(FittingData.data81(:, 1), FittingData.data81(:, 2), FittingData.data81(:, 3), '.', 'Color', kolor * 0.81); hold on;
      FittingData.allstd = std([FittingData.data36; FittingData.data58; FittingData.data81]); FittingData.allstd(3) = 100;
      FittingData.allmeans = mean([FittingData.data36; FittingData.data58; FittingData.data81]);
      W_centre_l = 0.60; %allmeans(1);
      W_centre_s = 0.00; %allmeans(2);
      W_centre_Y = FittingData.allmeans(3);
      W_axis_l   = 4 * FittingData.allstd(1);
      W_axis_s   = 5 * FittingData.allstd(2);
      W_axis_Y   = FittingData.allstd(3);
      W_axis_rotation = 40; %(*) in degrees counterclockwise
      W_axis_rotation = deg2rad(W_axis_rotation);
      xx = [W_centre_l, W_centre_s, W_centre_Y, W_axis_l, W_axis_s, W_axis_Y, W_axis_rotation];
      myRSS(1, 1) = alej_fit_ellipsoid_optplot(xx, 0, 0, FittingData); % if you need to edit, do it below!
      [myxx(1,:), myRSS(1,2), exitflag, output] = fminsearch(@(x) alej_fit_ellipsoid_optplot(x, 0, 0, FittingData), xx, options);
      %RSS2=alej_fit_ellipsoid_optplot(myxx(1,:), 1));
      disp ('================================================================');
      disp (['         Colour category: ',FittingData.category]);
      disp ('================================================================');
      showme_results(output, myxx(1,:), myRSS(1,:), exitflag, FittingData);
      tested = [tested, 1];
    case {'b', 'blue'}
      FittingData.category = 'blue';
      kolor = B;
      FittingData.data36 = [lsYFrontiers.lsY_36_G_B; lsYFrontiers.lsY_36_B_Pp; lsYFrontiers.lsY_36_W_B];
      FittingData.data58 = [lsYFrontiers.lsY_58_G_B; lsYFrontiers.lsY_58_B_Pp; lsYFrontiers.lsY_58_W_B];
      FittingData.data81 = [lsYFrontiers.lsY_81_G_B; lsYFrontiers.lsY_81_B_Pp; lsYFrontiers.lsY_81_W_B];
      plot3(FittingData.data36(:, 1), FittingData.data36(:, 2), FittingData.data36(:, 3), '.', 'Color', kolor * 0.36); hold on;
      plot3(FittingData.data58(:, 1), FittingData.data58(:, 2), FittingData.data58(:, 3), '.', 'Color', kolor * 0.58); hold on;
      plot3(FittingData.data81(:, 1), FittingData.data81(:, 2), FittingData.data81(:, 3), '.', 'Color', kolor * 0.81); hold on;
      FittingData.allstd = std([FittingData.data36; FittingData.data58;FittingData.data81]); FittingData.allstd(3) = 200;
      FittingData.allmeans = mean([FittingData.data36; FittingData.data58;FittingData.data81]);
      W_centre_l = 0.58; %0.6; %allmeans(1);
      W_centre_s = 0.25; %0.15; %allmeans(2);
      W_centre_Y = 100;  %allmeans(3);
      W_axis_l   = 2 * FittingData.allstd(1);
      W_axis_s   = 11 * FittingData.allstd(2);
      W_axis_Y   = FittingData.allstd(3);
      W_axis_rotation = 18; %(*) in degrees counterclockwise
      W_axis_rotation = deg2rad(W_axis_rotation);
      xx = [W_centre_l, W_centre_s, W_centre_Y, W_axis_l, W_axis_s, W_axis_Y, W_axis_rotation];
      myRSS(2, 1) = alej_fit_ellipsoid_optplot(xx, 0, 0, FittingData);% if you need to edit, do it below!
      [myxx(2, :), myRSS(2, 2), exitflag, output] = fminsearch(@(x) alej_fit_ellipsoid_optplot(x, 0, 0, FittingData), xx, options);
      %RSS2=alej_fit_ellipsoid_optplot(myxx(2,:), 1);
      disp ('================================================================');
      disp (['         Colour category: ', FittingData.category]);
      disp ('================================================================');
      showme_results(output, myxx(2,:), myRSS(2,:), exitflag, FittingData);
      tested = [tested, 2];
    case {'pp', 'purple'}
      FittingData.category = 'purple';
      kolor = Pp;
      FittingData.data36 = [lsYFrontiers.lsY_36_B_Pp; lsYFrontiers.lsY_36_Pp_Pk; lsYFrontiers.lsY_36_W_Pp];
      FittingData.data58 = [lsYFrontiers.lsY_58_B_Pp; lsYFrontiers.lsY_58_Pp_Pk; lsYFrontiers.lsY_58_W_Pp];
      FittingData.data81 = [lsYFrontiers.lsY_81_B_Pp; lsYFrontiers.lsY_81_Pp_Pk; lsYFrontiers.lsY_81_W_Pp];
      plot3(FittingData.data36(:,1), FittingData.data36(:,2), FittingData.data36(:,3), '.', 'Color', kolor * 0.36); hold on;
      plot3(FittingData.data58(:,1), FittingData.data58(:,2), FittingData.data58(:,3), '.', 'Color', kolor * 0.58); hold on;
      plot3(FittingData.data81(:,1), FittingData.data81(:,2), FittingData.data81(:,3), '.', 'Color', kolor * 0.81); hold on;
      FittingData.allstd = std([FittingData.data36;FittingData.data58;FittingData.data81]); FittingData.allstd(3) = 100;
      FittingData.allmeans = mean([FittingData.data36;FittingData.data58;FittingData.data81]);
      W_centre_l =  0.68; %allmeans(1);
      W_centre_s =  0.20; %allmeans(2);
      W_centre_Y = FittingData.allmeans(3);
      W_axis_l   = 4*FittingData.allstd(1);
      W_axis_s   = 7*FittingData.allstd(2);
      W_axis_Y   = FittingData.allstd(3);
      W_axis_rotation= -10; %(*) in degrees counterclockwise
      W_axis_rotation = deg2rad(W_axis_rotation);
      xx = [W_centre_l, W_centre_s, W_centre_Y, W_axis_l, W_axis_s, W_axis_Y, W_axis_rotation];
      myRSS(3,1) = alej_fit_ellipsoid_optplot(xx, 0, 0, FittingData);% if you need to edit, do it below!
      [myxx(3,:), myRSS(3,2), exitflag, output]  = fminsearch(@(x) alej_fit_ellipsoid_optplot(x, 0, 0, FittingData), xx, options);
      %RSS2=alej_fit_ellipsoid_optplot(myxx(3,:), 1);
      disp ('================================================================');
      disp (['         Colour category: ',FittingData.category]);
      disp ('================================================================');
      showme_results(output, myxx(3,:), myRSS(3,:), exitflag, FittingData);
      tested = [tested, 3];
    case {'pk', 'pink'}
      FittingData.category = 'pink';
      kolor = Pk;
      FittingData.data36 = [lsYFrontiers.lsY_36_Pp_Pk; lsYFrontiers.lsY_36_Pk_R;  lsYFrontiers.lsY_36_W_Pk];
      FittingData.data58 = [lsYFrontiers.lsY_58_Pp_Pk; lsYFrontiers.lsY_58_Pk_R;  lsYFrontiers.lsY_58_W_Pk];
      FittingData.data81 = [lsYFrontiers.lsY_81_Pp_Pk; lsYFrontiers.lsY_81_Pk_O;  lsYFrontiers.lsY_81_W_Pk];
      plot3(FittingData.data36(:,1), FittingData.data36(:,2), FittingData.data36(:,3), '.', 'Color', kolor * 0.36); hold on;
      plot3(FittingData.data58(:,1), FittingData.data58(:,2), FittingData.data58(:,3), '.', 'Color', kolor * 0.58); hold on;
      plot3(FittingData.data81(:,1), FittingData.data81(:,2), FittingData.data81(:,3), '.', 'Color', kolor * 0.81); hold on;
      FittingData.allstd = std([FittingData.data36;FittingData.data58;FittingData.data81]); FittingData.allstd(3) = 100;
      FittingData.allmeans = mean([FittingData.data36;FittingData.data58;FittingData.data81]);
      W_centre_l = 0.8;%allmeans(1);
      W_centre_s = 0.1 ;%allmeans(2);
      W_centre_Y = FittingData.allmeans(3);
      W_axis_l   = 5*FittingData.allstd(1);
      W_axis_s   = 3*FittingData.allstd(2);
      W_axis_Y   = FittingData.allstd(3);
      W_axis_rotation= 10; %(*) in degrees counterclockwise
      W_axis_rotation = deg2rad(W_axis_rotation);
      xx = [W_centre_l, W_centre_s, W_centre_Y, W_axis_l, W_axis_s, W_axis_Y, W_axis_rotation];
      myRSS(4,1) = alej_fit_ellipsoid_optplot(xx, 0, 0, FittingData);
      [myxx(4,:), myRSS(4,2), exitflag, output]  = fminsearch(@(x) alej_fit_ellipsoid_optplot(x, 0, 0, FittingData), xx, options);
      %RSS2=alej_fit_ellipsoid_optplot(myxx(4,:), 1));
      disp ('================================================================');
      disp (['         Colour category: ',FittingData.category]);
      disp ('================================================================');
      showme_results(output, myxx(4,:), myRSS(4,:), exitflag, FittingData);
      tested = [tested, 4];
    case {'r', 'red'}
      FittingData.category = 'red';
      kolor = R;
      FittingData.data36 = [lsYFrontiers.lsY_36_Pk_R; lsYFrontiers.lsY_36_R_Br;  lsYFrontiers.lsY_36_W_R];
      FittingData.data58 = [lsYFrontiers.lsY_58_Pk_R; lsYFrontiers.lsY_58_R_O;   lsYFrontiers.lsY_58_W_R];
      FittingData.data81 = [];
      plot3(FittingData.data36(:,1), FittingData.data36(:,2), FittingData.data36(:,3), '.', 'Color', kolor * 0.36); hold on;
      plot3(FittingData.data58(:,1), FittingData.data58(:,2), FittingData.data58(:,3), '.', 'Color', kolor * 0.58); hold on;
      FittingData.allstd = std([FittingData.data36;FittingData.data58;FittingData.data81]); FittingData.allstd(3) = 50;
      FittingData.allmeans = mean([FittingData.data36;FittingData.data58;FittingData.data81]);
      W_centre_l = 0.8;%FittingData.allmeans(1);
      W_centre_s = 0.025;%FittingData.allmeans(2);
      W_centre_Y = 0;%FittingData.allmeans(3);
      W_axis_l   = 5*FittingData.allstd(1);
      W_axis_s   = 1.5*FittingData.allstd(2);
      W_axis_Y   = FittingData.allstd(3);
      W_axis_rotation= -15; %(*) in degrees counterclockwise
      W_axis_rotation = deg2rad(W_axis_rotation);
      xx = [W_centre_l, W_centre_s, W_centre_Y, W_axis_l, W_axis_s, W_axis_Y, W_axis_rotation];
      myRSS(5,1) = alej_fit_ellipsoid_optplot(xx, 0, 0, FittingData);% if you need to edit, do it below!
      [myxx(5,:), myRSS(5,2), exitflag, output]  = fminsearch(@(x) alej_fit_ellipsoid_optplot(x, 0, 0, FittingData), xx, options);
      %RSS2=alej_fit_ellipsoid_optplot(myxx(5,:), 1);
      disp ('================================================================');
      disp (['         Colour category: ',FittingData.category]);
      disp ('================================================================');
      showme_results(output, myxx(5,:), myRSS(5,:), exitflag, FittingData);
      tested = [tested, 5];
    case {'o', 'orange'}
      FittingData.category = 'orange';
      kolor = O;
      FittingData.data36 = [];
      FittingData.data58 = [lsYFrontiers.lsY_58_R_O;  lsYFrontiers.lsY_58_O_Y;  lsYFrontiers.lsY_58_W_O];
      FittingData.data81 = [lsYFrontiers.lsY_81_Pk_O; lsYFrontiers.lsY_81_O_Y;  lsYFrontiers.lsY_81_W_O];
      plot3(FittingData.data58(:,1), FittingData.data58(:,2), FittingData.data58(:,3), '.', 'Color', kolor * 0.58); hold on;
      plot3(FittingData.data81(:,1), FittingData.data81(:,2), FittingData.data81(:,3), '.', 'Color', kolor * 0.81); hold on;
      FittingData.allstd = std([FittingData.data36;FittingData.data58;FittingData.data81]);  FittingData.allstd(3) = 90;%150;
      FittingData.allmeans = mean([FittingData.data36;FittingData.data58;FittingData.data81]);
      W_centre_l = 0.74;%FittingData.allmeans(1);
      W_centre_s = 0.00;%FittingData.allmeans(2);
      W_centre_Y = 100;%FittingData.allmeans(3);
      W_axis_l   = 2*FittingData.allstd(1);
      W_axis_s   = 10*FittingData.allstd(2);
      W_axis_Y   = FittingData.allstd(3);
      W_axis_rotation= 53; %(*) in degrees counterclockwise
      W_axis_rotation = deg2rad(W_axis_rotation);
      xx = [W_centre_l, W_centre_s, W_centre_Y, W_axis_l, W_axis_s, W_axis_Y, W_axis_rotation];
      myRSS(6,1) = alej_fit_ellipsoid_optplot(xx, 0, 0, FittingData);% if you need to edit, do it below!
      [myxx(6,:), myRSS(6,2), exitflag, output]  = fminsearch(@(x) alej_fit_ellipsoid_optplot(x, 0, 0, FittingData), xx, options);
      %RSS2=alej_fit_ellipsoid_optplot(myxx(6,:), 1);
      disp ('================================================================');
      disp (['         Colour category: ',FittingData.category]);
      disp ('================================================================');
      showme_results(output, myxx(6,:), myRSS(6,:), exitflag, FittingData);
      tested = [tested, 6];
    case {'y', 'yellow'}
      FittingData.category = 'yellow';
      kolor = Y;
      FittingData.data36 = [];
      FittingData.data58 = [lsYFrontiers.lsY_58_O_Y; lsYFrontiers.lsY_58_Y_G;   lsYFrontiers.lsY_58_W_Y];
      FittingData.data81 = [lsYFrontiers.lsY_81_O_Y; lsYFrontiers.lsY_81_Y_G;   lsYFrontiers.lsY_81_W_Y];
      plot3(FittingData.data58(:,1), FittingData.data58(:,2), FittingData.data58(:,3), '.', 'Color', kolor * 0.58); hold on;
      plot3(FittingData.data81(:,1), FittingData.data81(:,2), FittingData.data81(:,3), '.', 'Color', kolor * 0.81); hold on;
      FittingData.allstd = std([FittingData.data36;FittingData.data58;FittingData.data81]); FittingData.allstd(3) = 90;
      FittingData.allmeans = mean([FittingData.data36;FittingData.data58;FittingData.data81]);
      W_centre_l =  0.68;%FittingData.allmeans(1);
      W_centre_s =  0.01;%FittingData.allmeans(2);
      W_centre_Y = 100; %FittingData.allmeans(3);
      W_axis_l   = 1.5*FittingData.allstd(1);
      W_axis_s   = 5*FittingData.allstd(2);
      W_axis_Y   = FittingData.allstd(3);
      W_axis_rotation= 25; %(*) in degrees counterclockwise
      W_axis_rotation = deg2rad(W_axis_rotation);
      xx = [W_centre_l, W_centre_s, W_centre_Y, W_axis_l, W_axis_s, W_axis_Y, W_axis_rotation];
      myRSS(7,1) = alej_fit_ellipsoid_optplot(xx, 0, 0, FittingData);% if you need to edit, do it below!
      [myxx(7,:), myRSS(7,2), exitflag, output]  = fminsearch(@(x) alej_fit_ellipsoid_optplot(x, 0, 0, FittingData), xx, options);
      %RSS2=alej_fit_ellipsoid_optplot(myxx(7,:), 1);
      disp ('================================================================');
      disp (['         Colour category: ',FittingData.category]);
      disp ('================================================================');
      showme_results(output, myxx(7,:), myRSS(7,:), exitflag, FittingData);
      tested = [tested, 7];
    case {'br', 'brown'}
      FittingData.category = 'brown';
      kolor = Br;
      FittingData.data36 = [lsYFrontiers.lsY_36_R_Br; lsYFrontiers.lsY_36_Br_G; lsYFrontiers.lsY_36_W_Br];
      FittingData.data58 = [];
      FittingData.data81 = [];
      plot3(FittingData.data36(:,1), FittingData.data36(:,2), FittingData.data36(:,3), '.', 'Color', kolor * 0.36); hold on;
      FittingData.allstd = std([FittingData.data36;FittingData.data58;FittingData.data81]); FittingData.allstd(3) = 55;
      FittingData.allmeans = mean([FittingData.data36;FittingData.data58;FittingData.data81]);
      W_centre_l = 0.73; %FittingData.allmeans(1);
      W_centre_s = 0.00; %FittingData.allmeans(2);
      W_centre_Y = 0; %FittingData.allmeans(3);
      W_axis_l   = FittingData.allstd(1);
      W_axis_s   = 4*FittingData.allstd(2);
      W_axis_Y   = FittingData.allstd(3);
      W_axis_rotation= 57; %(*) in degrees counterclockwise
      W_axis_rotation = deg2rad(W_axis_rotation);
      xx = [W_centre_l, W_centre_s, W_centre_Y, W_axis_l, W_axis_s, W_axis_Y, W_axis_rotation];
      myRSS(8,1) = alej_fit_ellipsoid_optplot(xx, 0, 0, FittingData);% if you need to edit, do it below!
      [myxx(8,:), myRSS(8,2), exitflag, output]  = fminsearch(@(x) alej_fit_ellipsoid_optplot(x, 0, 0, FittingData), xx, options);
      %RSS2=alej_fit_ellipsoid_optplot(myxx(8,:), 1);
      disp ('================================================================');
      disp (['         Colour category: ',FittingData.category]);
      disp ('================================================================');
      showme_results(output, myxx(8,:), myRSS(8,:), exitflag, FittingData);
      tested = [tested, 8];
    case {'gr', 'grey'}
      FittingData.category = 'grey';
      kolor = Gr;
      FittingData.data36 = [lsYFrontiers.lsY_36_W_G; lsYFrontiers.lsY_36_W_B; lsYFrontiers.lsY_36_W_Pp; lsYFrontiers.lsY_36_W_Pk; lsYFrontiers.lsY_36_W_R; lsYFrontiers.lsY_36_W_Br];
      FittingData.data58 = [lsYFrontiers.lsY_58_W_G; lsYFrontiers.lsY_58_W_B; lsYFrontiers.lsY_58_W_Pp; lsYFrontiers.lsY_58_W_Pk; lsYFrontiers.lsY_58_W_R; lsYFrontiers.lsY_58_W_O; lsYFrontiers.lsY_58_W_Y];
      FittingData.data81 = [lsYFrontiers.lsY_81_W_G; lsYFrontiers.lsY_81_W_B; lsYFrontiers.lsY_81_W_Pp; lsYFrontiers.lsY_81_W_Pk; lsYFrontiers.lsY_81_W_O; lsYFrontiers.lsY_81_W_Y];
      plot3(FittingData.data36(:,1), FittingData.data36(:,2), FittingData.data36(:,3), '.', 'Color', kolor * 0.36); hold on;
      plot3(FittingData.data58(:,1), FittingData.data58(:,2), FittingData.data58(:,3), '.', 'Color', kolor * 0.58); hold on;
      plot3(FittingData.data81(:,1), FittingData.data81(:,2), FittingData.data81(:,3), '.', 'Color', kolor * 0.81); hold on;
      FittingData.allstd = std([FittingData.data36;FittingData.data58;FittingData.data81]); FittingData.allstd(3) = 200;
      FittingData.allmeans = mean([FittingData.data36;FittingData.data58;FittingData.data81]);
      W_centre_l =  0.65;%	FittingData.allmeans(1);
      W_centre_s =  0.059;%FittingData.allmeans(2);
      W_centre_Y = FittingData.allmeans(3);
      W_axis_l   = FittingData.allstd(1);
      W_axis_s   = FittingData.allstd(2);
      W_axis_Y   = FittingData.allstd(3);
      W_axis_rotation= 45; %(*) in degrees counterclockwise
      W_axis_rotation = deg2rad(W_axis_rotation);
      xx = [W_centre_l, W_centre_s, W_centre_Y, W_axis_l, W_axis_s, W_axis_Y, W_axis_rotation];
      myRSS(9,1) = alej_fit_ellipsoid_optplot(xx, 0, 0, FittingData);% if you need to edit, do it below!
      [myxx(9,:), myRSS(9,2), exitflag, output]  = fminsearch(@(x) alej_fit_ellipsoid_optplot(x, 0, 0, FittingData), xx, options);
      %RSS2=alej_fit_ellipsoid_optplot(myxx(9,:), 1);
      %             decay_width = sqrt(myRSS(9,2));
      %             testxx=[myxx(9,1),myxx(9,2),myxx(9,3),myxx(9,4)+decay_width,myxx(9,5)+decay_width,myxx(9,6),myxx(9,7)];
      %             alej_fit_ellipsoid_optplot(testxx, 1);hold on;
      %             testxx=[myxx(9,1),myxx(9,2),myxx(9,3),myxx(9,4)-decay_width,myxx(9,5)-decay_width,myxx(9,6),myxx(9,7)];
      %             alej_fit_ellipsoid_optplot(testxx, 1);
      disp ('================================================================');
      disp (['         Colour category: ',FittingData.category]);
      disp ('================================================================');
      showme_results(output, myxx(9,:), myRSS(9,:), exitflag, FittingData);
      tested = [tested, 9]; %#ok<*AGROW>
    otherwise
      disp('Wrong category, quitting...');
      return;
  end
end

%    plot3([Viewsonic(1:3,1);Viewsonic(1,1)], [Viewsonic(1:3,2);Viewsonic(1,2)], [0;0;0;0],'k','LineWidth',2);
%  plot3([Viewsonic(1:3,1);Viewsonic(1,1)], [Viewsonic(1:3,2);Viewsonic(1,2)], [Viewsonic(1:3,3);Viewsonic(1,3)]);
%  Draw_CRT_Gamut(Points_XYZ_Viewsonic,'lsy');
ellipsoids = [myxx, myRSS(:, 2)];

if mynargin == 9
  save('2014_ellipsoid_params.mat', 'ellipsoids', 'RGBValues', 'RGBTitles');
end


%=========================generate mesh ===================================

for kk = tested
  [x, y, z] = alej_ellipsoid(myxx(kk, 1:3), myxx(kk, 4:6), W_axis_orient, rad2deg(myxx(kk, 7)), myxx(kk, 1:3));
  mesh(x, y, z,'EdgeColor', RGB(kk,:)); alpha(0.4); hold on;
end
if mynargin == 9
  cateq = 'all categories';
elseif mynargin > 1
  cateq = [];
  for pq = 1:mynargin
    switch varargin{pq}
      case {'g','green'}
        cateq = [cateq, 'green, '];
      case {'b','blue'}
        cateq = [cateq, 'blue, '];
      case {'pp','purple'}
        cateq = [cateq, 'purple, '];
      case {'pk','pink'}
        cateq = [cateq, 'pink, '];
      case {'r','red'}
        cateq = [cateq, 'red, '];
      case {'o','orange'}
        cateq = [cateq, 'orange, '];
      case {'y','yellow'}
        cateq = [cateq, 'yellow, '];
      case {'br','brown'}
        cateq = [cateq, 'brown, '];
      case {'gr','grey'}
        cateq = [cateq, 'achromatic, '];
    end
  end
  cateq(size(cateq,2)) = '';
  cateq(size(cateq,2)) = '';
else
  cateq = FittingData.category;
end

title(['Category boundaries (', cateq, ') - best elipsod fits']);
xlabel('l');
ylabel('s');
zlabel('Y');
view(-19,54);
grid on;
set(gcf,'color',[1 1 1]);
hold off;

end
