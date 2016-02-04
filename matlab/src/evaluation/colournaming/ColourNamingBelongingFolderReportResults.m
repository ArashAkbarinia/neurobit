function ProbabilityDiffs = ColourNamingBelongingFolderReportResults(DirPath, method, quantise, normalise)
%ColourNamingTestFolderAllCategories Summary of this function goes here
%   Detailed explanation goes here

if nargin < 4
  DirPath = '/home/arash/Software/Repositories/neurobit/data/dataset/ColourNameDataset/ColorNamingYuanliu/Small_object/';
  method = 'ourlab';
  quantise = false;
  normalise = true;
end

method = lower(method);
disp(['Reporting results of method ', method]);

ResultDirectory = [DirPath, method, '_results/'];

ImagesPath = [DirPath, 'Images/'];
ImageFiles = dir([ImagesPath, '*.tif']);
ImageFiles = [ImageFiles; dir([ImagesPath,'*.bmp'])];
ImageFiles = [ImageFiles; dir([ImagesPath,'*.jpg'])];
nimages = length(ImageFiles);

GtsPath = [DirPath, 'AnnotationsBelonging/'];
MaskFiles = dir([GtsPath, '*.mat']);
if nimages ~= length(MaskFiles)
  warning(['Directory ', DirPath, ' does not have same number of pictures and gts.']);
  return;
end

ProbabilityDiffs = zeros(nimages, 2);
for i = 1:nimages
  ResultMatFile = load([ResultDirectory, 'res_prob', ImageFiles(i).name(1:end - 3), 'mat']);
  BelongingImage = ResultMatFile.BelongingImage;
  [rows, cols, chns] = size(BelongingImage);
  BelongingImage = reshape(BelongingImage, rows * cols, chns);
  
  if normalise
    BelongingImage = bsxfun(@rdivide, BelongingImage, sum(BelongingImage, 2));
  end
  
  if quantise
    BelongingImage(BelongingImage >= 0.875) = 1.0;
    BelongingImage(BelongingImage < 0.875 & BelongingImage >= 0.625) = 0.75;
    BelongingImage(BelongingImage < 0.625 & BelongingImage >= 0.375) = 0.50;
    BelongingImage(BelongingImage < 0.375 & BelongingImage >= 0.125) = 0.25;
  end
  
  MaskPath = [GtsPath, lower(ImageFiles(i).name(1:end - 3)), 'mat'];
  GtMat = load(MaskPath);
  BelongingImageGt = GtMat.BelongingImageGt;
  BelongingImageGt = reshape(BelongingImageGt, rows * cols, chns);
  
  diff = abs(BelongingImageGt(BelongingImageGt > 0) - BelongingImage(BelongingImageGt > 0));
  ProbabilityDiffs(i, :) = [mean(diff), length(diff)];
  disp(['[', num2str(i), '] ', ImageFiles(i).name, ' - probability diffs ', num2str(ProbabilityDiffs(i, 1))]);
end

FinalError = ProbabilityDiffs(:, 1) .* ProbabilityDiffs(:, 2);
FinalError = sum(FinalError, 1) ./ sum(ProbabilityDiffs(:, 2), 1);
disp(['Mean - probability diffs ', num2str(FinalError)]);

if quantise
  save([ResultDirectory, 'ErrorMatsBelongingRounded.mat'], 'ProbabilityDiffs');
elseif normalise
  save([ResultDirectory, 'ErrorMatsBelongingNormalised.mat'], 'ProbabilityDiffs');
else
  save([ResultDirectory, 'ErrorMatsBelonging.mat'], 'ProbabilityDiffs');
end

end
