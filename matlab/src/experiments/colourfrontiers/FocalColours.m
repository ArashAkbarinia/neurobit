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
  mean(brown36);
  47,  14,  21;  % B&O
  58,   3,  50;  % B&V
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
  36,  -38,  22;  % B&V
  47,  -38,  22;  % S&W
  mean(green58);
  70,  -22,  24;  % B&O
  81,  -20,  20;  % B&V
  86,  -20,  20;
  91,  -20,  20;
  ];

%% grey

CartFocals.grey = ...
  [
  36,  0,  0;
  47,  0,  0;
  58,  0,  0;
  70,  0,  0;
  81,  0,  0;
  86,  0,  0;
  91,  0,  0;
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
  70,  31,  57;  % S&W
  mean(orange81);
  86,  35,  60;
  91,  44,  80;
  ];

%% pink

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
  mean(purple36);
  47, 23.0, -35.5;
  mean(purple58);
  70, 23.5, -31.0;
  mean(purple81);
  ];

%% red

red58 = ...
  [
  58  44.54  21.50;  % B&V
  58  49.53  22.00;  % B&V
  ];

CartFocals.red = ...
  [
  36,  46,  14;
  47,  44,  20;
  mean(red58);
  ];

%% white

CartFocals.white = ...
  [
  100,  0,  0;
  ];

%% yellow

CartFocals.yellow = ...
  [
  81,  -6,  48;
  86,  -6,  48;
  91,  -6,  48;
  ];

%% converting them to polar

PolarFocals = struct();
ColourNames = fieldnames(CartFocals);
for i = 1:numel(ColourNames)
  PolarFocals.(ColourNames{i}) = cart2pol3([CartFocals.(ColourNames{i})(:, 2:3), CartFocals.(ColourNames{i})(:, 1)]);
end

end
