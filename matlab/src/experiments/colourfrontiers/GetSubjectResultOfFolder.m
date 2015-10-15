function LabVals = GetSubjectResultOfFolder(FolderPath, condition, type)
%GetSubjectResultOfFolder  reads the results of experiment for one person.
%
% inputs
%   FolderPath  the path to the folder.
%   condition   the condition of the experiment.
%   type        string for 'Arch' or 'Centre'.
%
% outputs
%   LabVals     the lab values.
%

MatFiles = dir(fullfile(FolderPath, ['*', type, '*.mat']));

labs = [];
for i = 1:length(MatFiles)
  FilePath = [FolderPath, MatFiles(i).name];
  [~, tmps] = PlotColourFrontiersResults(FilePath, condition, [], false);
  labs = [labs; tmps]; %#ok
end

rows = size(labs, 1);
LabVals = zeros(rows, 3);
for i = 1:rows
  LabVals(i, :) = pol2cart3([labs(i, 1), labs(:, 2), labs(i, 3)], 1);
end

end
