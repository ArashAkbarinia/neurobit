function [ColourBoxesImage, GroundTruthImage] = SegmentedColourProbabilities(DirPath, nLimistPoitns, quantize, ContrastDependant)

if nargin < 1
  DirPath = '/home/arash/Software/Repositories/neurobit/data/dataset/ColourNameDataset/ebay/';
end
if nargin < 4
  ContrastDependant = false;
end

if isempty(strfind(DirPath, '.mat'))
  if nargin < 2
    nLimistPoitns = 1000;
  end
  [rgbs, gts] = SegmentedColourPoints(DirPath, nLimistPoitns, ContrastDependant);
else
  [rgbs, gts] = SegmentedColourPoints(DirPath);
end

if nargin < 3
  quantize = 1;
end
rgbs = floor(double(rgbs) ./ quantize) + 1;

% finding unique rgbs
[ColourBoxesImage, ~, IndUniqes] = unique(rgbs, 'rows');
ColourBoxesImage = uint8(ColourBoxesImage .* quantize - 1);

UniqueDimension = size(ColourBoxesImage, 1);
GroundTruthImage = zeros(UniqueDimension, 11);
% summing the ground truth values of unique rgbs
for i = 1: 11
  GroundTruthImage(:, i) = accumarray(IndUniqes, gts(:, i));
end

GroundTruthImage = reshape(GroundTruthImage, size(GroundTruthImage, 1), 1, size(GroundTruthImage, 2));
GroundTruthCount = sum(GroundTruthImage, 3);
save('EbayPixelPoints.mat', 'ColourBoxesImage', 'GroundTruthCount', 'GroundTruthImage');

for i = 1:UniqueDimension
  GroundTruthImage(i, 1, :) = GroundTruthImage(i, 1, :) ./ GroundTruthCount(i);
end

end
