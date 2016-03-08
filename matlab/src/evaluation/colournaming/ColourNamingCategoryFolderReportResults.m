function ErrorMatCategory = ColourNamingCategoryFolderReportResults(DirPath, method, CompareOrder)
%ColourNamingTestFolderAllCategories Summary of this function goes here
%   Detailed explanation goes here

if nargin < 3
  DirPath = '/home/arash/Software/Repositories/neurobit/data/dataset/ColourNameDataset/ColorNamingYuanliu/Small_object/';
  method = 'ourlab';
  CompareOrder = false;
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

ErrorMatCategory = zeros(nimages, 2);
parfor i = 1:nimages
  MaskPath = [GtsPath, lower(ImageFiles(i).name(1:end - 3)), 'mat'];
  GtMat = load(MaskPath);
  BelongingImageGt = GtMat.BelongingImageGt;
  [rows, cols, chns] = size(BelongingImageGt);
  BelongingImageGt = reshape(BelongingImageGt, rows * cols, chns);
  NegativeIndeces = BelongingImageGt == 0;
  BelongingImageGt(all(NegativeIndeces, 2), :) = [];
  
  ResultMatFile = load([ResultDirectory, 'res_prob', ImageFiles(i).name(1:end - 3), 'mat']);
  BelongingImage = ResultMatFile.BelongingImage;
  BelongingImage = reshape(BelongingImage, rows * cols, chns);
  BelongingImage(all(NegativeIndeces, 2), :) = [];
  
  if CompareOrder
    [gtv, gti] = sort(BelongingImageGt, 2);
    [~, ali] = sort(BelongingImage, 2);
    algt = gti(gtv > 0) == ali(gtv > 0);
    tp = sum(algt(:));
    fn = size(algt, 1) - tp;
  else
    NamingImageGt = bsxfun(@eq, BelongingImageGt, max(BelongingImageGt, [], 2));
    NamingImage = bsxfun(@eq, BelongingImage, max(BelongingImage, [], 2));
    tp = NamingImage & NamingImageGt;
    tp = sum(tp(:));
    fn = size(BelongingImage, 1) - tp;
  end
  
  ErrorRate = tp / (tp + fn);
  
  ErrorMatCategory(i, :) = [tp, fn];
  disp([ImageFiles(i).name, ' ', num2str(ErrorRate)]);
end

tpfn = sum(ErrorMatCategory, 1);
FinalErrorRate = tpfn(1) / (tpfn(1) + tpfn(2));
disp(['All ', num2str(FinalErrorRate)]);

if CompareOrder
  save([ResultDirectory, 'ErrorMatsCategoryOrder.mat'], 'ErrorMatCategory');
else
  save([ResultDirectory, 'ErrorMatsCategory.mat'], 'ErrorMatCategory');
end

end
