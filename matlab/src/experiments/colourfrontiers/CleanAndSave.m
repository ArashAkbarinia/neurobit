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
pathname1 = strcat(ExperimentParameters.resultsdir, SubjectName, '\');
filename1 = strcat(lower('Colour Categorization Experiment'), ExperimentParameters.ExperimentType, '_', datestr(now, 'yyyy-mm-dd_HH.MM.SS'));
% FIXME: which variables do we really need to save.
save(char(strcat(pathname1, filename1, '.mat')), 'expjunk', 'rawjunk');

warning off MATLAB:xlswrite:AddSheet;
[~, ~] = xlswrite(char(strcat(pathname1, filename1, '.xls')), [expjunk.expresults], 'final_angles');
[~, ~] = xlswrite(char(strcat(pathname1, filename1, '.xls')), [expjunk.radioes],    'radios');
[~, ~] = xlswrite(char(strcat(pathname1, filename1, '.xls')), [expjunk.times],      'elapsed_times');
[~, ~] = xlswrite(char(strcat(pathname1, filename1, '.xls')), [expjunk.conditions], 'presentation_order');

hold off;
pause(ExperimentParameters.endexppause)
junkpalette = zeros(3, 256);
crsPaletteSet(junkpalette);
disp('Ended OK');

end
