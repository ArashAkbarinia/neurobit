function labs = PlotColourFrontiersResults(FilePath)
%PlotColourFrontiersResults Summary of this function goes here
%   Detailed explanation goes here

MatFile = load(FilePath);
ExperimentResult = MatFile.ExperimentResults;

angles = ExperimentResult.angles;
radii = ExperimentResult.radii;
luminances = ExperimentResult.luminances;

nexperiments = length(angles);
labs = zeros(nexperiments, 3);
for i = 1:nexperiments
  labs(i, :) = pol2cart3([angles(i), radii(i), luminances(i)], 1);
end

figure('NumberTitle', 'Off', 'Name', ['Colour Frontiers - ', ExperimentResult.type]);
plot3(labs(:, 1), labs(:, 2), labs(:, 3), '*r');
grid on;

end
