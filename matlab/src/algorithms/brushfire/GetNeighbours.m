function neighbours = GetNeighbours(MapGrid, pixel, connectivity)
%GetNeighbours  returns the valid neighbours of a pixel.
%
% Inputs
%   MapGrid       the matrix of map.
%   pixel         the pixel that we want to get the neighborus.
%   connectivity  4 or 8 neighbourhood.
%
% Outputs
%   neighbours  list of neighbours. If x and y of one neighbour is 0, it
%   means       that neighboru is not valid.
%

[rows, cols] = size(MapGrid);

% Extracting information for current pixel.
i = pixel(1);
j = pixel(2);

% Check which neighborhood we have to use.
if connectivity == 4
  souroundings = [0, 1, 0, -1; -1, 0, 1, 0;];
elseif connectivity == 8
  souroundings = [0, 1, 0, -1, 1, 1, -1, -1; -1, 0, 1, 0, 1, -1, 1, -1;];
end

neighbours = zeros(2, connectivity);

for k = 1 : size(souroundings, 2)
  temp = [i; j] + souroundings(:, k);
  % If the neighbour is out of boundry we don't add it to list.
  if temp(1) <= 0
    temp(1) = rows;
  elseif temp(1) > rows
    temp(1) = 1;
  end
  if temp(2) <= 0
    temp(2) = cols;
  elseif temp(2) > cols
    temp(2) = 1;
  end
  neighbours(:, k) = temp;
end
