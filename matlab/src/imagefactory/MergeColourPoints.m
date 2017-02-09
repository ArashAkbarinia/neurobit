function [WcsColourTable, GroundTruth] = MergeColourPoints(MatPaths)
%MergeColourPoints Summary of this function goes here
%   Detailed explanation goes here

rgbs = [];
gts = [];
for i = 1:numel(MatPaths)
  CurrentMat = load(MatPaths{i});
  rgbs = [rgbs; CurrentMat.ColourBoxesImage]; %#ok
  TmpGts = CurrentMat.GroundTruthImage;
  TmpGts = reshape(TmpGts, size(TmpGts, 1), size(TmpGts, 3));
  gts = [gts; TmpGts]; %#ok
end

[WcsColourTable, GroundTruth] = UnifiedRgbs(rgbs, gts);
GroundTruth = reshape(GroundTruth, size(GroundTruth, 1), 1, size(GroundTruth, 2));
GroundTruthCount = sum(GroundTruth, 3);
for i = 1:size(WcsColourTable, 1)
  GroundTruth(i, 1, :) = GroundTruth(i, 1, :) ./ GroundTruthCount(i);
end

end

function [rgbs, gts] = UnifiedRgbs(ColourBoxesImage, GroundTruthImage)

[rgbs, ~, IndUniqes] = unique(ColourBoxesImage, 'rows');

gts = zeros(size(rgbs, 1), 11);
for i = 1: 11
  gts(:, i) = accumarray(IndUniqes, GroundTruthImage(:, i));
end

end
