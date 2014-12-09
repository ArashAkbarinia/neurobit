function FrontierTableArchs = NeighbourArchs(ExperimentParameters, PolarFocals, FrontierTable)

crs = ExperimentParameters.CRS;

[rows, cols] = size(FrontierTable);
FrontierTableArchs = cell(rows, cols + 1);

for i = 1:rows
  colour1 = lower(FrontierTable{i, 2});
  colour2 = lower(FrontierTable{i, 3});
  luminan = lower(FrontierTable{i, 1});
  MaxRadiusAllowed = find_max_rad_allowed(crs, PolarFocals.(colour1)(1, 1), PolarFocals.(colour2)(1, 1), str2double(luminan));
  % adding the sixth column and the allowed radius
  FrontierTableArchs(i, :) = {FrontierTable{i, :}, min(MaxRadiusAllowed, ExperimentParameters.maxradius)};
end

end
