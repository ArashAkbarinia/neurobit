function [] = ColourNamingTestDataset(DirPath, method, ContrastDependant)

if nargin < 2
  DirPath = '/home/arash/Software/Repositories/neurobit/data/dataset/ColourNameDataset/ebay/';
  method = 'ourlab';
  ContrastDependant = false;
end

SubFolders = GetSubFolders(DirPath);

for j = 1:length(SubFolders)
  DirPathJ = [DirPath, SubFolders{j}, '/'];
  
  SubSubFolders = GetSubFolders(DirPathJ);
  for k = 1:length(SubSubFolders)
    DirPathJK = [DirPathJ, SubSubFolders{k}, '/'];
    ColourNamingTestFolder(DirPathJK, method, true, SubSubFolders{k}, 2, ContrastDependant);
  end
end

end
