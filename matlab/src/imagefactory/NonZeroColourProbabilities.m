function [ColourBoxesImage, GroundTruthImage] = NonZeroColourProbabilities(DirPaths, nLimistPoitns, quantize)
%NonZeroColourProbabilities Summary of this function goes here
%   Detailed explanation goes here

if nargin < 1
  OuterPath = '/home/arash/Software/Repositories/neurobit/data/dataset/ColourNameDataset/ColorNamingYuanliu/';
  DirPaths = {[OuterPath, 'Small_object/'], [OuterPath, 'Car/'], [OuterPath, 'MCN/']};
end
if nargin < 2
  nLimistPoitns = inf;
end

rgbs = [];
gts = [];

for d = 1:numel(DirPaths)
  DirPath = DirPaths{d};
  
  ImagesPath = [DirPath, 'Images/'];
  ImageFiles = dir([ImagesPath, '*.tif']);
  ImageFiles = [ImageFiles; dir([ImagesPath,'*.bmp'])]; %#ok
  ImageFiles = [ImageFiles; dir([ImagesPath,'*.jpg'])]; %#ok
  nimages = length(ImageFiles);
  
  GtsPath = [DirPath, 'AnnotationsBelonging/'];
  MaskFiles = dir([GtsPath, '*.mat']);
  if nimages ~= length(MaskFiles)
    warning(['Directory ', DirPath, ' does not have same number of pictures and gts.']);
    continue;
  end
  
  for i = 1:nimages
    ImageRGB = imread([ImagesPath, ImageFiles(i).name]);
    
    MaskPath = [GtsPath, lower(ImageFiles(i).name(1:end - 3)), 'mat'];
    GtMat = load(MaskPath);
    BelongingImageGt = GtMat.BelongingImageGt;
    [rows, cols, chns] = size(BelongingImageGt);
    
    ImageRGB = reshape(ImageRGB, rows * cols, 3);
    BelongingImageGt = reshape(BelongingImageGt, rows * cols, chns);
    
    ImageRGB(all(BelongingImageGt == 0, 2), :) = [];
    BelongingImageGt(all(BelongingImageGt == 0, 2), :) = [];
    
    nCurrentPoitns = size(BelongingImageGt, 1);
    if nCurrentPoitns > nLimistPoitns
      RandomPoints = randi(nCurrentPoitns, [nLimistPoitns, 1]);
      BelongingImageGt = BelongingImageGt(RandomPoints, :);
      ImageRGB = ImageRGB(RandomPoints, :);
    end
    
    rgbs = [rgbs; ImageRGB]; %#ok
    gts = [gts; BelongingImageGt]; %#ok
  end
  
end

gts = reshape(gts, size(gts, 1), 1, size(gts, 2));

if nargin < 3
  quantize = 1;
end
rgbs = floor(double(rgbs) ./ quantize) + 1;

[ColourBoxesImage, ~, IndUniqes] = unique(rgbs, 'rows');
ColourBoxesImage = uint8(ColourBoxesImage .* quantize - 1);

OriginalDimension = size(rgbs, 1);
UniqueDimension = size(ColourBoxesImage, 1);
GroundTruthImage = zeros(UniqueDimension, 1, 11);
GroundTruthCount = zeros(UniqueDimension, 1, 11);

for i = 1:OriginalDimension
  GroundTruthImage(IndUniqes(i), 1, :) = GroundTruthImage(IndUniqes(i), 1, :) + gts(i, 1, :);
  GroundTruthCount(IndUniqes(i), 1, :) = GroundTruthCount(IndUniqes(i), 1, :) + 1;
end

for i = 1:UniqueDimension
  GroundTruthImage(i, 1, :) = GroundTruthImage(i, 1, :) ./ GroundTruthCount(i, 1, :);
end

end
