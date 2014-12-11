function FrontierTable = LuminanceFrontiers()
%LuminanceFrontiers the luminance frontiers of the experiment
%   New borders can be added to this table, the experiment generates
%   borders based on the values in this table.
%
% Inputs
%
% Outputs
%   FrontierTable  each row contains one frontier to be tested.
%

FrontierTable = ...
  {
  %colour1    colour2      a       b       lum1     lum2
  'Grey',     'White',     0.5,    0.5,    0.50,    1.00;
  'Black',    'Grey',      0.5,    0.5,    0.00,    0.50;
  'Brown',    'Yellow',    0.5,    1.0,    0.10,    1.00;
  'Red',      'Brown',     0.5,    1.0,    0.00,    0.10;
  'Red',      'Orange',    1.0,    1.0,    0.50,    1.00;
  'Red',      'Pink',      1.0,    0.5,    0.00,    0.50;
  'Pink',     'Purple',    1.0,    0.5,    0.50,    0.75;
  };

end
