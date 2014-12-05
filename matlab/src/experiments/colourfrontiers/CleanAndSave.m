function [] = CleanAndSave(junkpalette, y_DingDong, Fs_DingDong, resultsdir, SubjectName, ExperimentType, expjunk, endexppause)

crsPaletteSet(junkpalette);
crsSetDisplayPage(4);

audioplayer(y_DingDong, Fs_DingDong);
audioplayer(y_DingDong, Fs_DingDong);
audioplayer(y_DingDong, Fs_DingDong);

if ~exist(char(strcat(resultsdir, SubjectName, '\')), 'dir');
  mkdir(char(strcat(resultsdir, SubjectName, '\')));
end
pathname1 = strcat(resultsdir, SubjectName, '\');
filename1 = strcat(lower('Colour Categorization Experiment'), ExperimentType, '_', datestr(now, 'yyyy-mm-dd_HH.MM.SS'));
save(char(strcat(pathname1, filename1, '.mat')), 'expjunk', 'rawjunk');

warning off MATLAB:xlswrite:AddSheet;
[~, ~] = xlswrite(char(strcat(pathname1, filename1, '.xls')), [expjunk.expresults], 'final_angles');
[~, ~] = xlswrite(char(strcat(pathname1, filename1, '.xls')), [expjunk.radioes],    'radios');
[~, ~] = xlswrite(char(strcat(pathname1, filename1, '.xls')), [expjunk.times],      'elapsed_times');
[~, ~] = xlswrite(char(strcat(pathname1, filename1, '.xls')), [expjunk.conditions], 'presentation_order');

hold off;
pause(endexppause)
junkpalette = zeros(3, 256);
crsPaletteSet(junkpalette);
disp('Ended OK');

end
