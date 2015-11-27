function [] = ColourNamingContingencyTable(DirPath, method)

if nargin < 2
  DirPath = '/home/arash/Software/Repositories/neurobit/data/dataset/ColourNameDataset/ebay/';
  method = 'our';
end

method = lower(method);
disp(['Reading results for method ', method]);

SubFolders = GetSubFolders(DirPath);

nSubFolder = length(SubFolders);
ErrorMatsAll = zeros(nSubFolder, 8);
for j = 1:nSubFolder
  DirPathJ = [DirPath, SubFolders{j}, '/'];
  
  SubSubFolders = GetSubFolders(DirPathJ);
  nSubSubFolder = length(SubSubFolders);
  
  ErrorMatsCat = zeros(nSubSubFolder, 8);
  for k = 1:nSubSubFolder
    DirPathJK = [DirPathJ, SubSubFolders{k}, '/'];
    ResultDirectory = [DirPathJK, method, '_results/'];
    FolderResultMat = load([ResultDirectory, 'ErrorMats.mat']);
    nimages = length(FolderResultMat.ErrorMats);
    CurrentErrorMat = zeros(nimages, 8);
    for l = 1:nimages
      CurrentErrorMat(l, :) = struct2array(FolderResultMat.ErrorMats{l});
    end
    ErrorMatsCat(k, :) = mean(CurrentErrorMat, 1);
  end
  ErrorMatsAll(j, :) = mean(ErrorMatsCat, 1);
  fprintf('%s\t- Sensitivity: %0.2f Specificity %0.2f Positive predictive %0.2f Negative predictive %0.2f\n', SubFolders{j}, ErrorMatsAll(j, 1:4));
  SaveResults(DirPathJ, method, ErrorMatsCat);
end
SaveResults(DirPath, method, ErrorMatsAll);

fprintf('All average\t- Sensitivity: %0.2f Specificity %0.2f Positive predictive %0.2f Negative predictive %0.2f\n', mean(ErrorMatsAll(:, 1:4), 1));

PrintPixelAverage(ErrorMatsAll);

end

function [] = PrintPixelAverage(ErrorMatsAll)

sa = sum(ErrorMatsAll, 1);
tp = sa(1, 5);
fp = sa(1, 6);
fn = sa(1, 7);
tn = sa(1, 8);

sens = tp / (tp + fn);
if isnan(sens)
  sens = 0;
end
% specificity
spec = tn / (fp + tn);
if isnan(spec)
  spec = 0;
end
% positive predictive value
ppv = tp / (tp + fp);
if isnan(ppv)
  ppv = 0;
end
% negative predictive value
npv = tn / (fn + tn);
if isnan(npv)
  npv = 0;
end

fprintf('Pixel average\t- Sensitivity: %0.2f Specificity %0.2f Positive predictive %0.2f Negative predictive %0.2f\n', sens, spec, ppv, npv);

end

function [] = SaveResults(DirPathJ, method, ErrorMats) %#ok

save([DirPathJ, method, 'ErrorMats.mat'], 'ErrorMats');

end
