function rgb = name2rgb(ColourName)
%NAME2RGB map colour names to their RGB values for visualisation purposes.
%
% Inputs
%   ColourName  the colour name in characters
%
% Outputs
%   rgb  the RGB value of the colour name in row.
%

ColourName = lower(ColourName);

switch ColourName
  case {'bl', 'black'}
    rgb = [0.0, 0.0, 0.0];
  case {'b', 'blue'}
    rgb = [0.0, 0.0, 1.0];
  case {'br', 'brown'}
    rgb = [1.0, 0.5, 0.0] * 0.75;
  case {'g', 'green'}
    rgb = [0.0, 1.0, 0.0];
  case {'gr', 'grey'}
    rgb = [0.5, 0.5, 0.5];
  case {'o', 'orange'}
    rgb = [1.0, 0.5, 0.0];
  case {'pk', 'pink'}
    rgb = [1.0, 0.0, 1.0];
  case {'pp', 'purple'}
    rgb = [0.7, 0.0, 0.7];
  case {'r', 'red'}
    rgb = [1.0, 0.0, 0.0];
  case {'w', 'white'}
    rgb = [1.0, 1.0, 1.0];
  case {'y', 'yellow'}
    rgb = [1.0, 1.0, 0.0];
  otherwise
    warning('name2rgb:UnsupportedColour', ['Colour ', ColourName], ' is not supported, returnign black.');
    rgb = [0, 0, 0];
end
