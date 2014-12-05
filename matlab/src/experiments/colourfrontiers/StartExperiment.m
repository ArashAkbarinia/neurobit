function SubjectName = StartExperiment(blackpalette, CRS, Black_palette_name, answer, darkadaptation, junkpalette)

disp('Experiment starting...');

crsPaletteSet(blackpalette);
crsSetDrawPage(CRS.VIDEOPAGE, 2, Black_palette_name);
crsDrawString([0, 0], 'Experiment starting...');
crsSetDrawPage(CRS.VIDEOPAGE, 3, Black_palette_name);
crsDrawString([0, 0], 'Experiment updating...');
crsSetDrawPage(CRS.VIDEOPAGE, 4, Black_palette_name);
crsDrawString([0, 0], 'Experiment finished...');
crsSetDisplayPage(2);

promptstr = {'Enter Subject�s name'};
if isempty(answer)
  inistr = {'Nobody'};
else
  inistr = {answer{1}};
end
titlestr = 'Subject info';
nlines = 1;
ok2 = false;
while ok2 == false
  answer = inputdlg(promptstr, titlestr, nlines, inistr);
  if isempty(answer)
    ButtonName = questdlg('You will lose data. Are u sure?', 'Exit now?', 'Immediately!', 'No thanks', 'No thanks');
    if strcmp(ButtonName, 'Immediately!')
      error('Experiment cancelled');
    end
  else
    SubjectName = answer{1};
    pause(darkadaptation);
    crsPaletteSet(junkpalette);
    disp(['Subject name: ', SubjectName]);
    ok2 = true;
  end
end

end
