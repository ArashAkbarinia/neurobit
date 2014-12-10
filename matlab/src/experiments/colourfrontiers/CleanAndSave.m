function [] = CleanAndSave(ExperimentParameters, SubjectName, expjunk)

junkpalette = ExperimentParameters.junkpalette;
crsPaletteSet(junkpalette);
crsSetDisplayPage(4);

audioplayer(ExperimentParameters.y_DingDong, ExperimentParameters.Fs_DingDong);
audioplayer(ExperimentParameters.y_DingDong, ExperimentParameters.Fs_DingDong);
audioplayer(ExperimentParameters.y_DingDong, ExperimentParameters.Fs_DingDong);

if ~exist(char(strcat(ExperimentParameters.resultsdir, SubjectName, '\')), 'dir');
  mkdir(char(strcat(ExperimentParameters.resultsdir, SubjectName, '\')));
end
pathname = strcat(ExperimentParameters.resultsdir, SubjectName, '\');
filename = strcat(lower('Colour Frontiers Experiment_'), ExperimentParameters.ExperimentType, '_', datestr(now, 'yyyy-mm-dd_HH.MM.SS'));
% TODO: which variables do we really need to save.
save(char(strcat(pathname, filename, '.mat')), 'expjunk');

warning off MATLAB:xlswrite:AddSheet;
[~, ~] = xlswrite(char(strcat(pathname, filename, '.xls')), [expjunk.final_angles], 'final_angles');
[~, ~] = xlswrite(char(strcat(pathname, filename, '.xls')), [expjunk.radioes],      'radios');
[~, ~] = xlswrite(char(strcat(pathname, filename, '.xls')), [expjunk.times],        'elapsed_times');
[~, ~] = xlswrite(char(strcat(pathname, filename, '.xls')), [expjunk.conditions],   'presentation_order');

hold off;
pause(ExperimentParameters.endexppause)
crsPaletteSet(zeros(3, ExperimentParameters.SquareSize));
disp('Ended OK');

end
