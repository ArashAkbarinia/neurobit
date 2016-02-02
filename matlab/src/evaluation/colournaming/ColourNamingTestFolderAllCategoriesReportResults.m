function ProbabilityDiffs = ColourNamingTestFolderAllCategoriesReportResults(DirPath, method)
%ColourNamingTestFolderAllCategories Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
  DirPath = '/home/arash/Software/Repositories/neurobit/data/dataset/ColourNameDataset/ColorNamingYuanliu/Small_object/';
  method = 'ourlab';
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

ProbabilityDiffs = zeros(nimages, 1);
parfor i = 1:nimages
  ResultMatFile = load([ResultDirectory, 'res_prob', ImageFiles(i).name(1:end - 3), 'mat']);
  BelongingImage = ResultMatFile.BelongingImage;
  
  MaskPath = [GtsPath, lower(ImageFiles(i).name(1:end - 3)), 'mat'];
  GtMat = load(MaskPath);
  BelongingImageGt = GtMat.BelongingImageGt;
  
  diff = BelongingImageGt - BelongingImage;
  diff = diff(:);
  diff = mean(diff(diff > 0));
  ProbabilityDiffs(i, 1) = diff;
  disp(['[', num2str(i), '] ', ImageFiles(i).name, ' - probability diffs ', num2str(ProbabilityDiffs(i, 1))]);
end

disp(['Mean - probability diffs ', num2str(mean(ProbabilityDiffs))]);

save([ResultDirectory, 'ErrorMatsBelonging.mat'], 'ProbabilityDiffs');

end
