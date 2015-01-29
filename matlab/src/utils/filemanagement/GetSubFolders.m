function SubFolders = GetSubFolders(DirPath)
%GetSubFolders Summary of this function goes here
%   Detailed explanation goes here

folder = dir(DirPath);
isub = [folder(:).isdir];
SubFolders = {folder(isub).name}';
SubFolders(ismember(SubFolders,{'.', '..'})) = [];

end
