function MetamerColourNameReport = ReportColourNamingResults(MetamerPairs, CurrentNames)
%ReportColourNamingResults Summary of this function goes here
%   Detailed explanation goes here

DiffColourName = CurrentNames(MetamerPairs(:, 1), :) - CurrentNames(MetamerPairs(:, 2), :);

MetamerColourNameReport = sum(abs(DiffColourName), 2) > 0;

end
