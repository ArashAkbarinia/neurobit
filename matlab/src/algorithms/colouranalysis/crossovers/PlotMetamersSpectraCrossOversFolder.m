function [AllCrossOvers, FigureHandler] = PlotMetamersSpectraCrossOversFolder(ResultsFolder, WhichLth, WhichUth, FigureName)
%PlotMetamersSpectraCrossOversFolder Summary of this function goes here
%   Detailed explanation goes here

MatList = dir([ResultsFolder, 'CrossOversReport*.mat']);
nfiles = length(MatList);
rows = round(sqrt(nfiles));
cols = ceil(sqrt(nfiles));

if nargin < 2
  WhichLth = {[]};
end
if nargin < 3
  WhichUth = {[]};
end
if nargin < 4 || isempty(FigureName)
  FigureName = 'CrossOversReport';
  isvisible = 'on';
else
  isvisible = 'off';
end

NormaliseByAllCrossOvers = true;

nlths = numel(WhichLth);
nuths = numel(WhichUth);

sw = 400;
step = 10;
ew = 709;
WavelengthRange = sw:step:ew;

FigPos = [0, 0, 50, 25];

FigureHandler = figure('name', FigureName, 'PaperUnits', 'centimeters', 'PaperPosition', FigPos, 'visible', isvisible);

AllCrossOvers = zeros(nfiles, size(WavelengthRange, 2));
for i = 1:nfiles
  CurrentFileName = MatList(i).name;
  MatPath = [ResultsFolder, CurrentFileName];
  CrossOversMat = load(MatPath);
  
  % subplot should be so PlotMetamersSpectraCrossOvers can plots it
  subplot(rows, cols, i);
  hold on;
  
  for l = 1:nlths
    for u = 1:nuths
      AllCrossOvers(i, :) = AllCrossOvers(i, :) + PlotMetamersSpectraCrossOvers(CrossOversMat.CrossOversReport, WhichLth{l}, WhichUth{u}, NormaliseByAllCrossOvers);
    end
  end
  
  if nlths > 1 || nuths > 1
    AllCrossOvers(i, :) = AllCrossOvers(i, :) ./ sum(AllCrossOvers(i, :));
    AllCrossOvers(isnan(AllCrossOvers)) = 0;
    
    plot(WavelengthRange, AllCrossOvers(i, :));
    xlim([WavelengthRange(1), WavelengthRange(end)]);
  end
  
  TilteName = strrep(CurrentFileName, 'CrossOversReport', '');
  TilteName = strrep(TilteName, '.mat', '');
  if isempty(TilteName)
    TilteName = 'all';
  end
  title(TilteName);
end

if strcmpi(isvisible, 'off')
  print(FigureHandler, [ResultsFolder, FigureName, '-CrossOvers.jpg'], '-djpeg', '-r0');
  close(FigureHandler);
end

end
