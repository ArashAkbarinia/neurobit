function [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
  ArchColour(archs, PolarFocals, startcolourname, endcolourname, plotresults, labplane, minradius, h, n)
%ArchColour Summary of this function goes here
%   Detailed explanation goes here

disp(['level: ', num2str(n), ', ', startcolourname, '-', endcolourname, ' border selected']);
col1 = lower(startcolourname);
col2 = lower(endcolourname);
radius_pn = archs.([col1, '_', col2, '_radius_p', num2str(n)]);
radioes = minradius + (radius_pn - minradius) * rand(1, 1);
start_ang = PolarFocals.(col1)(n, 1);
end_ang = PolarFocals.(col2)(n, 1);
theplane = labplane;
if plotresults
  figure(h);
  pp = pol2cart3([start_ang, radius_pn]);
  plot([pp(1), 0], [pp(2), 0], 'r');
  hold on;
  text(pp(1), pp(2), startcolourname, 'color', 'r');
  hold on;
  pp = pol2cart3([end_ang, radius_pn]);
  plot([pp(1), 0], [pp(2), 0], 'r');
  text(pp(1), pp(2), endcolourname, 'color','r');
  hold on;
  axis([-50, 50, -50, 50]);
  refresh;
end

end