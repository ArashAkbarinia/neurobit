function [radioes, start_ang, end_ang, labplane, ColourA, ColourB] = ...
  ArchColour(frontier, PolarFocals, ExperimentParameters, FigurePlanes)
%ArchColour Summary of this function goes here
%   Detailed explanation goes here

ColourA = lower(frontier{2});
ColourB = lower(frontier{3});
labplane = str2double(frontier{1});

% FIXME: n is baed on 36, 58, 81
if labplane == 36
  n = 1;
elseif labplane == 58
  n = 2;
elseif labplane == 81
  n = 3;
end

disp(['luminance: ', frontier{1}, ', ', ColourA, '-', ColourB, ' border selected']);
radius_pn = frontier{6};
radioes = ExperimentParameters.minradius + (radius_pn - ExperimentParameters.minradius) * rand(1, 1);
start_ang = PolarFocals.(ColourA)(n, 1);
end_ang = PolarFocals.(ColourB)(n, 1);

if ExperimentParameters.plotresults
  FigureIndex = ~cellfun('isempty', strfind(FigurePlanes(:, 1), frontier{1}));
  h = FigurePlanes{FigureIndex, 2};
  figure(h);
  hold on;
  
  pp = pol2cart3([start_ang, radius_pn]);
  plot([pp(1), 0], [pp(2), 0], 'r');
  text(pp(1), pp(2), ColourA, 'color', 'r');
  
  pp = pol2cart3([end_ang, radius_pn]);
  plot([pp(1), 0], [pp(2), 0], 'r');
  text(pp(1), pp(2), ColourB, 'color','r');
  
  axis([-50, 50, -50, 50]);
  refresh;
end

end
