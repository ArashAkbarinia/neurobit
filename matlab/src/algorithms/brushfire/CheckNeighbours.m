function PixelGradient = CheckNeighbours(MapGrid, pixel, connectivity)
%CheckNeighbours  calculating the distance towards closest obstace.
%   Finds neighbours of one pixel and checks their distance towards
%   obstacle, based on those distances you can set the distance of current
%   pixel.
%
% Inputs
%   map_grid      the matrix of map.
%   pixel         current pixel.
%   connectivity  4 or 8 neighborhood.
%
% Outputs
%   PixelGradient  the minimum value of its neighbours plus one.
%

[rows, cols] = size(MapGrid);

% Extracting information for current pixel.
i = pixel(1);
j = pixel(2);

PixelGradient = MapGrid(i, j);

if PixelGradient == 0
  PixelGradient = rows * cols;
end

% Getting the neighborus of current position.
neighbours = GetNeighbours(MapGrid, pixel, connectivity);

% Going through all th neighborus.
for k = 1 : size(neighbours, 2)
  % If neighboru is valid.
  if neighbours(1, k) ~= 0
    temp = neighbours(:, k);
    TempGradient = MapGrid(temp(1), temp(2));
    
    % If the distance of neighboru towards obstacle is lower than the
    % previously calculated distance.
    if TempGradient < PixelGradient && TempGradient ~= 0
      PixelGradient = TempGradient;
    end
  end
end

% The distance towards obstacle if one more than minimum of neighbours
% distances.
if MapGrid(i, j) == 0 || MapGrid(i, j) > PixelGradient
  PixelGradient = PixelGradient + 1;
end

end
