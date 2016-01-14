function [] = ColourNamingContingencyTable(DirPath, method, GtIndex)

if nargin < 3
  DirPath = '/home/arash/Software/Repositories/neurobit/data/dataset/ColourNameDataset/ebay/';
  method = 'ourlab';
  GtIndex = 2;
end

method = lower(method);
disp(['Reading results for method ', method]);

SubFolders = GetSubFolders(DirPath);
if GtIndex == 1
  indeces = cellfun('isempty', strfind(SubFolders(:, 1), 'FruitsVegetablesFlowers'));
  SubFolders = SubFolders(indeces, :);
end

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
    FolderResultMat = load([ResultDirectory, 'ErrorMats', num2str(GtIndex), '.mat']);
    nimages = length(FolderResultMat.ErrorMats);
    CurrentErrorMat = zeros(nimages, 8);
    if strcmpi(SubFolders{j}, 'FruitsVegetablesFlowers')
      for l = 1:nimages
        CurrentErrorMat(l, :) = struct2array(FolderResultMat.ErrorMats{l});
      end
      ErrorMatsCat(k, :) = mean(CurrentErrorMat, 1);
    else
      for l = 1:10
        CurrentErrorMat(l, :) = struct2array(FolderResultMat.ErrorMats{l});
      end
      ErrorMatsCat(k, :) = mean(CurrentErrorMat(1:10, :), 1);
    end
  end
  ErrorMatsAll(j, :) = mean(ErrorMatsCat, 1);
  [acc, f1, er] = ReportResults(ErrorMatsAll(j, :));
  fprintf('%s\t- Accuracy %0.2f F1-Score %0.2f Error-Rate %0.2f \n', SubFolders{j}, acc, f1, er);
  SaveResults(DirPathJ, method, ErrorMatsCat, GtIndex);
end
SaveResults(DirPath, method, ErrorMatsAll, GtIndex);

[acc, f1, er] = ReportResults(sum(ErrorMatsAll, 1));
fprintf('Sum: Accuracy %0.2f F1-Score %0.2f Error-Rate %0.2f\n', acc, f1, er);

end

function [acc, f1, er] = ReportResults(ErrorMat)

tp = ErrorMat(1, 5);
fp = ErrorMat(1, 6);
fn = ErrorMat(1, 7);
tn = ErrorMat(1, 8);

acc = (tp + tn) / (tp + fp + fn + tn);
f1 = (2 * tp) / ((2 * tp) + fp + fn);
er = fn / (tp + fn);

end

function [] = SaveResults(DirPathJ, method, ErrorMats, GtIndex) %#ok

save([DirPathJ, method, 'ErrorMats', num2str(GtIndex), '.mat'], 'ErrorMats');

end
