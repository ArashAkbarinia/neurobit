function archs = NeighbourArchs(PolarFocals, labplane1, labplane2, labplane3, maxradius)

archs.green_blue_radius_p1    = find_max_rad_allowed(PolarFocals.green(1, 1),  PolarFocals.blue(1, 1),   labplane1);
archs.blue_purple_radius_p1   = find_max_rad_allowed(PolarFocals.blue(1, 1),   PolarFocals.purple(1, 1), labplane1);
archs.purple_pink_radius_p1   = find_max_rad_allowed(PolarFocals.purple(1, 1), PolarFocals.pink(1, 1),   labplane1);
archs.pink_red_radius_p1      = find_max_rad_allowed(PolarFocals.pink(1, 1),   PolarFocals.red(1, 1),    labplane1);
archs.red_brown_radius_p1     = find_max_rad_allowed(PolarFocals.red(1, 1),    PolarFocals.brown(1, 1),  labplane1);
archs.brown_green_radius_p1   = find_max_rad_allowed(PolarFocals.brown(1, 1),  PolarFocals.green(1, 1),  labplane1);

archs.green_blue_radius_p2    = find_max_rad_allowed(PolarFocals.green(2, 1),  PolarFocals.blue(2, 1),   labplane2);
archs.blue_purple_radius_p2   = find_max_rad_allowed(PolarFocals.blue(2, 1),   PolarFocals.purple(2, 1), labplane2);
archs.purple_pink_radius_p2   = find_max_rad_allowed(PolarFocals.purple(2, 1), PolarFocals.pink(2, 1),   labplane2);
archs.pink_red_radius_p2      = find_max_rad_allowed(PolarFocals.pink(2, 1),   PolarFocals.red(2, 1),    labplane2);
archs.red_orange_radius_p2    = find_max_rad_allowed(PolarFocals.red(2, 1),    PolarFocals.orange(2, 1), labplane2);
archs.orange_yellow_radius_p2 = find_max_rad_allowed(PolarFocals.orange(2, 1), PolarFocals.yellow(2, 1), labplane2);
archs.yellow_green_radius_p2  = find_max_rad_allowed(PolarFocals.yellow(2, 1), PolarFocals.green(2, 1),  labplane2);

archs.green_blue_radius_p3    = find_max_rad_allowed(PolarFocals.green(3, 1),  PolarFocals.blue(3, 1),   labplane3);
archs.blue_purple_radius_p3   = find_max_rad_allowed(PolarFocals.blue(3, 1),   PolarFocals.purple(3, 1), labplane3);
archs.purple_pink_radius_p3   = find_max_rad_allowed(PolarFocals.purple(3, 1), PolarFocals.pink(3, 1),   labplane3);
archs.pink_orange_radius_p3   = find_max_rad_allowed(PolarFocals.pink(3, 1),   PolarFocals.orange(3, 1), labplane3);
archs.orange_yellow_radius_p3 = find_max_rad_allowed(PolarFocals.orange(3, 1), PolarFocals.yellow(3, 1), labplane3);
archs.yellow_green_radius_p3  = find_max_rad_allowed(PolarFocals.yellow(3, 1), PolarFocals.green(3, 1),  labplane3);

archnames = fieldnames(archs);
for i = 1:numel(archnames)
  archs.(archnames{i}) = min(archs.(archnames{i}), maxradius);
end

end
