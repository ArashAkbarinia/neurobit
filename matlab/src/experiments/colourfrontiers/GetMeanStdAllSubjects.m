function ms = GetMeanStdAllSubjects(condition, FolderPath)
%GetMeanStdAllSubjects  getting the std and mean of all subjects
%
% inputs
%   condition   the condition of the experiment.
%   FolderPath  the path to all the subjects.
%
% outputs
%   ms  the mean ans std of all subejcts in lab colour space.
%

folders = {'ameya', 'emilie', 'felix', 'itzel', 'lara', 'lovertte', 'marshall', 'rubi', 'uche'};
if nargin < 2
  FolderPath = '/home/arash/Dropbox/PhD/Results/experiments/ColourFrontiers/real/';
end

ms = zeros(numel(folders) * 2, 7);

for i = 1:numel(folders)
  labs = GetResultOfFolder([FolderPath, folders{i}, '/'], condition, 'Arch');
  ms(i, 1:3) = mean(labs);
  ms(i, 5:7) = ms(i, 1:3);
  ms(i + 9, 1:3) = std(labs);
  ms(i + 9, 5:7) = ms(i + 9, 1:3);
end

end
