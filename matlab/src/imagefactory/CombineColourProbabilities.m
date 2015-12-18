function [ColourBoxesImage, GroundTruthImage] = CombineColourProbabilities(ColourProbabilities, ColourPoints)

rgbs = ColourPoints;
gts = ColourProbabilities;

[ColourBoxesImage, ~, IndUniqes] = unique(rgbs, 'rows');

OriginalDimension = size(rgbs, 1);
UniqueDimension = size(ColourBoxesImage, 1);
GroundTruthImage = zeros(UniqueDimension, 1, 11);

for i = 1:OriginalDimension
  GroundTruthImage(IndUniqes(i), 1, :) = GroundTruthImage(IndUniqes(i), 1, :) + gts(i, 1, :);
end

SumProbs = sum(GroundTruthImage, 3);
for i = 1:UniqueDimension
  if SumProbs(i) ~= 0
    GroundTruthImage(i, 1, :) = GroundTruthImage(i, 1, :) ./ SumProbs(i);
  else
    GroundTruthImage(i, 1, :) = 0;
  end
end

end
