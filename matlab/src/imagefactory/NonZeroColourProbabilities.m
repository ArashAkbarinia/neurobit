function [ColourBoxesImage, GroundTruthImage] = NonZeroColourProbabilities(DirPaths, nLimistPoitns, quantize, ContrastDependant)
%NonZeroColourProbabilities Summary of this function goes here
%   Detailed explanation goes here

if nargin < 1
  OuterPath = '/home/arash/Software/Repositories/neurobit/data/dataset/ColourNameDataset/ColorNamingYuanliu/';
  DirPaths = {[OuterPath, 'Small_object/'], [OuterPath, 'Car/'], [OuterPath, 'MCN/']};
end
if nargin < 2
  nLimistPoitns = inf;
end
if nargin < 4
  ContrastDependant = false;
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
    disp([ImagesPath, ImageFiles(i).name]);
    ImageRGB = imread([ImagesPath, ImageFiles(i).name]);
    
    ImageRGB = uint8(double(ImageRGB) ./ 65535 .* 255);
    ImageRGB = ApproximateToD65(ImageRGB);
    
    if ContrastDependant
      ImageRGB = double(ImageRGB) ./ 255;
      rfresponse = ContrastDependantGaussian(ImageRGB, 1.5);
      ImageRGB = uint8(rfresponse .* 255);
    end
    
    MaskPath = [GtsPath, lower(ImageFiles(i).name(1:end - 3)), 'mat'];
    GtMat = load(MaskPath);
    BelongingImageGt = GtMat.BelongingImageGt;
    [rows, cols, chns] = size(BelongingImageGt);
    
    ImageRGB = reshape(ImageRGB, rows * cols, 3);
    BelongingImageGt = reshape(BelongingImageGt, rows * cols, chns);
    
    ImageRGB(all(BelongingImageGt == 0, 2), :) = [];
    BelongingImageGt(all(BelongingImageGt == 0, 2), :) = [];
    % making th maximum as 1 and rest as 0
    BelongingImageGt = double(bsxfun(@eq, BelongingImageGt, max(BelongingImageGt, [], 2)));
    
    nCurrentPoitns = size(BelongingImageGt, 1);
    if nCurrentPoitns > nLimistPoitns
      RandomPoints = randi(nCurrentPoitns, [nLimistPoitns, 1]);
      BelongingImageGt = BelongingImageGt(RandomPoints, :);
      ImageRGB = ImageRGB(RandomPoints, :);
    end
    
    rgbs = [rgbs; ImageRGB]; %#ok
    gts = [gts; BelongingImageGt]; %#ok
    
    [rgbs, gts] = UnifiedRgbs(rgbs, gts);
  end
  
end

gts = reshape(gts, size(gts, 1), 1, size(gts, 2));

if nargin < 3
  quantize = 1;
end
rgbs = floor(double(rgbs) ./ quantize) + 1;

ColourBoxesImage = uint8(rgbs .* quantize - 1);
GroundTruthImage = gts;
GroundTruthCount = sum(GroundTruthImage, 3);
save('YuanliuPixelPoints.mat', 'ColourBoxesImage', 'GroundTruthCount', 'GroundTruthImage');

for i = 1:size(ColourBoxesImage, 1)
  GroundTruthImage(i, 1, :) = GroundTruthImage(i, 1, :) ./ GroundTruthCount(i);
end

end

function [rgbs, gts] = UnifiedRgbs(ColourBoxesImage, GroundTruthImage)

[rgbs, ~, IndUniqes] = unique(ColourBoxesImage, 'rows');

gts = zeros(size(rgbs, 1), 11);
for i = 1: 11
  gts(:, i) = accumarray(IndUniqes, GroundTruthImage(:, i));
end

end
