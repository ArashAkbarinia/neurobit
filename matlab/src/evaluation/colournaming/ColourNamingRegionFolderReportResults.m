function ErrorMats = ColourNamingRegionFolderReportResults(DirPath, method, BelongingPool)
%ColourNamingTestFolderAllCategories Summary of this function goes here
%   Detailed explanation goes here

if nargin < 3
  DirPath = '/home/arash/Software/Repositories/neurobit/data/dataset/ColourNameDataset/ColorNamingYuanliu/Small_object/';
  method = 'ourlab';
  BelongingPool = true;
end

method = lower(method);
disp(['Reporting results of method ', method]);

ResultDirectory = [DirPath, method, '_results/'];

ImagesPath = [DirPath, 'Images/'];
ImageFiles = dir([ImagesPath, '*.tif']);
ImageFiles = [ImageFiles; dir([ImagesPath,'*.bmp'])];
ImageFiles = [ImageFiles; dir([ImagesPath,'*.jpg'])];
nimages = length(ImageFiles);

GtsPath = [DirPath, 'Annotations/'];
MaskFiles = dir([GtsPath, '*.mat']);
if nimages ~= length(MaskFiles)
  warning(['Directory ', DirPath, ' does not have same number of pictures and gts.']);
  return;
end

EllipsoidDicMat = load('EllipsoidDic.mat');

ErrorMats = [];
parfor i = 1:nimages
  ResultMatFile = load([ResultDirectory, 'res_prob', ImageFiles(i).name(1:end - 3), 'mat']);
  BelongingImage = ResultMatFile.BelongingImage;
  NamingImage = belonging2naming(BelongingImage);
  
  MaskPath = [GtsPath, lower(ImageFiles(i).name(1:end - 3)), 'mat'];
  GtMat = load(MaskPath);
  nRegions = size(GtMat.colorprop, 1);
  ErrorMatsCat = zeros(nRegions, 2);
  for c = 1:nRegions
    NonZeroElements = find(GtMat.colorprop(c, :) > 0);
    if sum(NonZeroElements(:)) == 0
      continue;
    end
    
    ImageMask = GtMat.objmap;
    ImageMask = ImageMask == c;
    
    if BelongingPool
      RegionBelonging = zeros(1, 11);
      for b = 1:11
        CurrentChannel = BelongingImage(:, :, b);
        CurrentChannel = CurrentChannel(ImageMask);
        RegionBelonging(1, b) = mean(CurrentChannel(:));
      end
      RegionBelonging = RegionBelonging ./ sum(RegionBelonging(:));
      [~, RegionMaxInds] = max(RegionBelonging);
      
      MaxPercent = max(GtMat.colorprop(c, :));
      MaxInds = find(GtMat.colorprop(c, :) == MaxPercent);
      
      for m = 1:length(MaxInds)
        GroundTruthColour = EllipsoidDicMat.yuanliu2ellipsoid(MaxInds(m));
        if RegionMaxInds == GroundTruthColour
          ErrorMatsCat(c, 1) = 1;
        end
      end
      
      [~, SortedIndeces] = sort(RegionBelonging, 'descend');
      RegionBelonging(:) = 0;
      RegionBelonging(SortedIndeces(1:length(NonZeroElements))) = 1;
      comparison = RegionBelonging(1, EllipsoidDicMat.yuanliu2ellipsoid) & (GtMat.colorprop(c, :) > 0);
      tp = sum(comparison(:));
      fn = length(NonZeroElements) - tp;
      ErrorMatsCat(c, 2) = tp / (tp + fn);
    else
      RegionResult = NamingImage(ImageMask);
      UniqueRegions = unique(RegionResult);
      RegionHist = histc(RegionResult, UniqueRegions);
      RegionCount = max(RegionHist);
      RegionMaxInds = find(RegionHist == RegionCount);
      
      MaxPercent = max(GtMat.colorprop(c, :));
      MaxInds = find(GtMat.colorprop(c, :) == MaxPercent);
      
      for m = 1:length(MaxInds)
        GroundTruthColour = EllipsoidDicMat.yuanliu2ellipsoid(MaxInds(m));
        for r = 1:length(RegionMaxInds)
          if UniqueRegions(RegionMaxInds(r)) == GroundTruthColour
            ErrorMatsCat(c, 1) = 1;
          end
        end
      end
      
      [~, SortedIndeces] = sort(RegionHist, 'descend');
      RegionBelonging = zeros(1, 11);
      RegionBelonging(UniqueRegions(SortedIndeces(1:min(length(NonZeroElements), length(SortedIndeces))))) = 1;
      comparison = RegionBelonging(1, EllipsoidDicMat.yuanliu2ellipsoid) & (GtMat.colorprop(c, :) > 0);
      tp = sum(comparison(:));
      fn = length(NonZeroElements) - tp;
      ErrorMatsCat(c, 2) = tp / (tp + fn);
    end
    
    disp(['[', num2str(i), ',', num2str(c), '] ', ImageFiles(i).name, ' - region ', num2str(ErrorMatsCat(c, 1))]);
  end
  
  ErrorMats = [ErrorMats; ErrorMatsCat]; 
end

tp = sum(ErrorMats(:, 1));
fn = size(ErrorMats, 1) - tp;
ErrorRate = tp / (tp + fn);
disp(['Region accuracy ', num2str(ErrorRate)]);
disp(['Region order difference ', num2str(mean(ErrorMats(:, 2)))]);

if BelongingPool
  save([ResultDirectory, 'ErrorMatsRegionsBelongingPool.mat'], 'ErrorMats');
else
  save([ResultDirectory, 'ErrorMatsRegions.mat'], 'ErrorMats');
end

end
