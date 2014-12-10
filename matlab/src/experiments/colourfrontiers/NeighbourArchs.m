function FrontierTableArchs = NeighbourArchs(ExperimentParameters, PolarFocals, FrontierTable)

crs = ExperimentParameters.CRS;

[rows, cols] = size(FrontierTable);
FrontierTableArchs = cell(rows, cols + 1);

for i = 1:rows
  labplane = str2double(lower(FrontierTable{i, 1}));
  ColourA = lower(FrontierTable{i, 2});
  ColourB = lower(FrontierTable{i, 3});
  PoloarColourA = PolarFocals.(ColourA)((PolarFocals.(ColourA)(:, 3) == labplane), :);
  PoloarColourB = PolarFocals.(ColourB)((PolarFocals.(ColourB)(:, 3) == labplane), :);
  MaxRadiusAllowed = find_max_rad_allowed(crs, PoloarColourA(1), PoloarColourB(1), labplane);
  % adding the sixth column and the allowed radius
  FrontierTableArchs(i, :) = {FrontierTable{i, :}, min(MaxRadiusAllowed, ExperimentParameters.maxradius)};
end

end
