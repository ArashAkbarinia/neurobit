function ChipsTable = SturgesWhitfielColourBoundries()
%SturgesWhitfielColourBoundries Summary of this function goes here
%   Detailed explanation goes here

FunctionPath = mfilename('fullpath');
ChipsTablePath = strrep(FunctionPath, 'matlab/src/experiments/wcs/SturgesWhitfielColourBoundries', 'matlab/data/mats/SturgesWhitfielColourBoundries.mat');
ChipsTableMat = load(ChipsTablePath);

ChipsTable = ChipsTableMat.ChipsTable();

% green
centre(1, 1:2) = [7, 19];

% blue
centre(2, 1:2) = [6, 30];

% purple
centre(3, 1:2) = [7, 35];

% pink
centre(4, 1:2) = [4, 40];

% red
centre(5, 1:2) = [7, 4];

% orange
centre(6, 1:2) = [5, 6];

% yellow
centre(7, 1:2) = [2, 11];

% brown
centre(8, 1:2) = [8, 9];

% grey
centre(5:6, 1, 9) = 1;

% white
centre(1, 1, 10) = 1;

% black
centre(10, 1, 11) = 1;

% calculating the distances
d = 0.1;

[rows, cols, ~] = size(ChipsTable);
for i = 1:8
  ChipsTable(centre(i, 1), centre(i, 2), i) = 1;
  for j = 1:rows
    for k = 1:cols
      if ChipsTable(j, k, i) == 2
        cx = centre(i, 1);
        dx = min(abs(j - cx), abs(j + rows - cx));
        cy = centre(i, 2);
        dy = min(abs(k - cy), abs(k + cols - cy));
        ChipsTable(j, k, i) = 1 - sqrt(dx ^ 2 + dy ^ 2) * d;
      end
    end
  end
end

end
