function [OutColourProbabilities, OutColourPoints, GroundTruth] = ReplaceColourProbabilities(ColourProbabilities, ColourPoints, GroundTruthNames)
%ReplaceColourProbabilities  replaces the segmented colour probabilities
%                            with  values of ground truth.
%
%

OutColourProbabilities = ColourProbabilities;
OutColourPoints = ColourPoints;

WcsColourTable = WcsChart();
GroundTruth = WcsResults(GroundTruthNames);

GroundTruthBinary = GroundTruth;
nColourCategories = size(GroundTruthBinary, 3);
parfor c = 1:nColourCategories
  CurrentChannel = GroundTruthBinary(:, :, c);
  CurrentChannel(CurrentChannel > 0) = 1;
  GroundTruthBinary(:, :, c) = CurrentChannel;
end

nGts = numel(GroundTruthNames);
[rows, cols, ~] = size(WcsColourTable);
for i = 1:rows
  for j = 1:cols
    rgb = reshape(WcsColourTable(i, j, :), 1, 3);
    founds = ismember(ColourPoints, rgb, 'rows');
    if sum(founds) > 0
      OutColourProbabilities(founds, 1, :) = GroundTruthBinary(i, j, :);
      GroundTruth(i, j, :) = (GroundTruth(i, j, :) * nGts + ColourProbabilities(founds, 1, :)) ./ (nGts + 1);
    else
      OutColourProbabilities(end + 1, :) = GroundTruthBinary(i, j, :); %#ok
      OutColourPoints(end + 1, :) = rgb; %#ok
    end
  end
end

end
