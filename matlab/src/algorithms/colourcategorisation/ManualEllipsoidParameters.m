function ColourEllipsoids = ManualEllipsoidParameters()
%ManualEllipsoidParameters Summary of this function goes here
%   Detailed explanation goes here

ColourEllipsoids = ...
  [
  % green
  63.50,   1.00,  38.00,   4.40,   3.50,  40.00,   0.00,   0.00,   0.00,  0;
  
  % blue
  53.50,  44.00,  25.00,   7.00,  35.00,  55.00,   0.15,   0.05,   0.10,  0;
  
  % purple
  68.50,  35.00,  11.00,   7.00,  21.00,  38.00,   0.00,   3.00,   0.00,  0;
  
  % pink
  76.00,  13.00,  36.00,   6.00,   9.50,  40.00,   0.00,   3.03,   0.00,  0;
  
  % red
  82.00,   3.15,  15.00,   5.50,   5.00,  19.00,   0.00,   2.90,   0.00,  0;
  
  % orange
  76.00,   2.00,  40.00,   7.00,   3.25,  20.00,   0.00,   3.00,   0.00,  0;
  
  % yellow
  67.25,   1.70,  65.00,   2.50,   2.00,  36.00,   0.00,   3.11,   0.00,  0;
  
  % brown
  74.67,   0.85,   0.00,  11.00,   0.50,  19.00,   0.00,   0.00,   0.00,  0;
  
  % grey
  65.73,   6.46,  42.50,   2.25,   2.75,  35.00,   0.00,   0.00,   0.00,  0;
  
  % white
  65.73,   6.46,  95.00,   2.25,   2.75,  25.00,   0.00,   0.00,   0.00,  0;
  
  % black
  65.73,   6.46,   0.00,   2.25,   2.75,   5.00,   0.00,   0.00,   0.00,  0;
  ];

RGBTitles = {'G', 'B', 'Pp', 'Pk', 'R', 'O', 'Y', 'Br', 'Gr', 'W', 'Bl'}; %#ok
save('2014_ellipsoid_params_arash.mat', 'ColourEllipsoids', 'RGBTitles');

end
