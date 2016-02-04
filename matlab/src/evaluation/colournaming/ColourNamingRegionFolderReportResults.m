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
for i = 1:nimages
  ResultMatFile = load([ResultDirectory, 'res_prob', ImageFiles(i).name(1:end - 3), 'mat']);
  BelongingImage = ResultMatFile.BelongingImage;
  NamingImage = belonging2naming(BelongingImage);
  
  MaskPath = [GtsPath, lower(ImageFiles(i).name(1:end - 3)), 'mat'];
  GtMat = load(MaskPath);
  nRegions = size(GtMat.colorprop, 1);
  ErrorMatsCat = zeros(nRegions, 1);
  for c = 1:nRegions
    ImageMask = GtMat.objmap;
    ImageMask = ImageMask == c;
    
    if BelongingPool
      RegionBelonging = zeros(1, 11);
      for b = 1:11
        CurrentChannel = BelongingImage(:, :, b);
        CurrentChannel = CurrentChannel(ImageMask);
        RegionBelonging(1, b) = mean(CurrentChannel(:));
      end
      [~, RegionMaxInds] = max(RegionBelonging);
      
      MaxPercent = max(GtMat.colorprop(c, :));
      MaxInds = find(GtMat.colorprop(c, :) == MaxPercent);
      
      for m = 1:length(MaxInds)
        GroundTruthColour = EllipsoidDicMat.yuanliu2ellipsoid(MaxInds(m));
        if RegionMaxInds == GroundTruthColour
          ErrorMatsCat(c, 1) = 1;
        end
      end
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
    end
    
    disp(['[', num2str(i), ',', num2str(c), '] ', ImageFiles(i).name, ' - region ', num2str(ErrorMatsCat(c, 1))]);
  end
  
  ErrorMats = [ErrorMats; ErrorMatsCat]; %#ok
end

tp = sum(ErrorMats);
fn = size(ErrorMats, 1) - tp;
ErrorRate = tp / (tp + fn);
disp(['Region accuracy ', num2str(ErrorRate)]);

if BelongingPool
  save([ResultDirectory, 'ErrorMatsRegionsBelongingPool.mat'], 'ErrorMats');
else
  save([ResultDirectory, 'ErrorMatsRegions.mat'], 'ErrorMats');
end

end
