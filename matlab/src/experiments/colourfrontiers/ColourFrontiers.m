function [FrontierNames, FrontierAngles, DesaturatedFrontiers] = ColourFrontiers()
%ColourFrontiers Summary of this function goes here
%   Detailed explanation goes here

FrontierNames = ...
  {
  '1'   '36'	'Green'     'Blue';
  '2' 	'36'	'Blue'      'Purple';
  '3' 	'36'	'Purple'    'Pink';
  '4' 	'36'	'Pink'      'Red';
  '5' 	'36'	'Red'       'Brown';
  '6' 	'36'	'Brown'     'Green';
  '7' 	'58'	'Green'     'Blue';
  '8' 	'58'	'Blue'      'Purple';
  '9' 	'58'	'Purple'    'Pink';
  '10'	'58'	'Pink'      'Red';
  '11'	'58'	'Red'       'Orange';
  '12'	'58'	'Orange'    'Yellow';
  '13'	'58'	'Yellow'    'Green';
  '14'	'81'	'Green'     'Blue';
  '15'	'81'	'Blue'      'Purple';
  '16'	'81'	'Purple'    'Pink';
  '17'	'81'	'Pink'      'Orange';
  '18'	'81'	'Orange'    'Yellow';
  '19'	'81'	'Yellow'    'Green';
  };

FrontierAngles = ...
  [% w/contex and wo/context
  3.619422689,  3.498391118;
  4.934799618,	4.951908395;
  5.825916375,	5.764518826;
  6.410524778,	6.428999015;
  0.629245673,	0.624122655;
  1.814186927,	1.699024360;
  3.497584341,	3.415861832;
  4.911725724,	4.947604147;
  5.745765196,	5.723958150;
  6.487972025,	6.505966666;
  0.604454375,	0.604126142;
  1.331458929,	1.258743082;
  1.850395271,	1.842067225;
  3.426219373,	3.344970199;
  4.831389697,	4.901483523;
  5.655103896,	5.682502729;
  0.516980892,	0.516793913;
  1.304555370,	1.281320273;
  2.011381327,	2.029197077;
  ];

DesaturatedFrontiers = ...
  {
  '1'   '36'	'Green';
  '2' 	'36'	'Blue';
  '3' 	'36'	'Purple';
  '4' 	'36'	'Pink';
  '5' 	'36'	'Red';
  '6' 	'36'	'Brown';
  '7' 	'58'	'Green';
  '8' 	'58'	'Blue';
  '9' 	'58'	'Purple';
  '10'	'58'	'Pink';
  '11'	'58'	'Red';
  '12'	'58'	'Orange';
  '13'	'58'	'Yellow';
  '14'	'81'	'Green';
  '15'	'81'	'Blue';
  '16'	'81'	'Purple';
  '17'	'81'	'Pink';
  '18'	'81'	'Orange';
  '19'	'81'	'Yellow';
  };

end
