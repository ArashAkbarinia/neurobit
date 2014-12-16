function [CartFocals, PolarFocals] = FocalColours()
%FocalColours Summary of this function goes here
%   Detailed explanation goes here

% TODO: add other luminances here

CartFocals = struct();

%% black

CartFocals.black = ...
  [
  0,  0,  0;
  ];

%% blue

blue58 = ...
  [
  58  -3.410  -48.08;  % B&K
  58  -9.610  -18.44;  % B&O
  58  -16.44  -30.00;  % B&V
  58  -12.92  -27.22;  % S&W
  ];

CartFocals.blue = ...
  [
  25,  -2,   -32;
  36,  -5,   -30;  % B&V
  47,  -8,   -30;
  mean(blue58);
  70,  -15,  -25;
  81,  -20,  -20;  % B&V
  ];


%% brown

brown36 = ...
  [
  36  18.18  30.27;  % B&K
  36  14.81  21.60;  % B&O
  36  20.00  40.00;  % B&V
  36  23.33  50.00;  % B&V
  36  25.00  45.00;  % B&V
  36  13.07  33.61;  % S&W
  ];

CartFocals.brown = ...
  [
  25,  14,  50;
  mean(brown36);
  47,  24,  30;
  ];

%% green

green58 = ...
  [
  58  -52.69  9.700;  % B&K
  58  -22.60  24.65;  % B&O
  58  -21.41  14.72;  % B&V
  58  -38.09  22.89;  % S&W
  ];

CartFocals.green = ...
  [
  25,  -40.00,  23.00;
  36,  -38.09,  22.89;  % B&V
  47,  -36.50,  21.00;
  mean(green58);
  70,  -27.00,  20.50;
  81,  -20.00,  20.00;  % B&V
  ];

%% grey

CartFocals.grey = ...
  [
  25,  0,  0;
  36,  0,  0;
  47,  0,  0;
  58,  0,  0;
  70,  0,  0;
  81,  0,  0;
  ];

%% orange

orange58 = ...
  [
  58  44.69  79.79;  % B&K
  58  33.30  43.67;  % B&O
  58  25.00  35.00;  % B&V
  58  31.50  57.28;  % S&W
  ];

orange81 = ...
  [
  81  33.30  45.00;  % B&V
  81  35.00  50.00;  % B&V
  ];

CartFocals.orange = ...
  [
  mean(orange58);
  70, 34, 50;
  mean(orange81);
  ];

%% pink

pink36 = ...
  [
  36  43  -7;  % B&V
  36  45  -8;  % B&V
  ];

pink58 = ...
  [
  58  30  -3;  % B&V
  58  42  -5;  % B&V
  ];

pink81 = ...
  [
  81  37   7;  % B&V
  81  50  10;  % B&V
  ];

CartFocals.pink = ...
  [
  mean(pink36);
  47, 44, -5;
  mean(pink58);
  70, 45, -6;
  mean(pink81);
  ];

%% purple

purple36 = ...
  [
  36  23  -40;  % B&V
  36  20  -33;  % B&V
  ];

purple58 = ...
  [
  58  20  -30;  % B&V
  58  30  -40;  % B&V
  ];

purple81 = ...
  [
  81  20  -25;  % B&V
  81  25  -27;  % B&V
  ];

CartFocals.purple = ...
  [
  25, 22.0, -37.0;
  mean(purple36);
  47, 23.0, -35.5;
  mean(purple58);
  70, 23.5, -31.0;
  mean(purple81);
  ];

%% red

red36 = ...
  [
  36  59.51  30.17;  % B&K
  36  40.58  15.46;  % B&O
  36  45.00  15.00;  % B&V
  36  49.53  28.41;  % S&W
  ];

red58 = ...
  [
  58  44.54  21.50;  % B&V
  58  49.53  22.00;  % B&V
  ];

CartFocals.red = ...
  [
  25, 47, 23;
  mean(red36);
  47, 48, 22;
  mean(red58);
  ];

%% white

CartFocals.white = ...
  [
  100,  0,  0;
  ];

%% yellow

yellow81 = ...
  [
  81  7.28  109.12;  %  Yellow  B&K
  81  3.35  56.360;  %  Yellow  B&O
  81  2.00  50.000;  %  Yellow  B&V
  81  0.00  46.000;  %  Yellow  B&V
  81  1.65  72.030;  %  Yellow  S&W
  ];

CartFocals.yellow = ...
  [
  58,  3.00,  50;  % B&V
  70,  2.92,  58;
  mean(yellow81);
  ];

%% converting them to polar

PolarFocals = struct();
ColourNames = fieldnames(CartFocals);
for i = 1:numel(ColourNames)
  PolarFocals.(ColourNames{i}) = cart2pol3([CartFocals.(ColourNames{i})(:, 2:3), CartFocals.(ColourNames{i})(:, 1)]);
end

end
