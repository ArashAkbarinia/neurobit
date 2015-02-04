function ColourPoints = satfaces()
%SATFACES Summary of this function goes here
%   http://blog.xkcd.com/2010/05/03/color-survey-results/

FunctionLocalPath = 'matlab/src/experiments/wcs/satfaces';
FunctionPath = mfilename('fullpath');
FilePath = strrep(FunctionPath, FunctionLocalPath, 'data/ColourNaming/satfaces.txt');

ColourPoints = struct();
ColourPoints.green = [];
ColourPoints.blue = [];
ColourPoints.purple = [];
ColourPoints.pink = [];
ColourPoints.red = [];
ColourPoints.orange = [];
ColourPoints.yellow = [];
ColourPoints.brown = [];
ColourPoints.grey = [];
ColourPoints.white = [];
ColourPoints.black = [];

fid = fopen(FilePath);
tline = fgets(fid);
while ischar(tline)
  tline = strrep(tline, '[', '');
  tline = strrep(tline, ']', '');
  tline = strrep(tline, ',', '');
  LineSplitted = strsplit(tline, ' ');
  rgb = str2double(LineSplitted(1:3));
  ColourName = lower(LineSplitted{4});
  ColourName = strtrim(ColourName);
  if iscell(ColourName)
    ColourName = cell2mat(ColourName);
  end
  
  if isfield(ColourPoints, ColourName)
    ColourPoints.(ColourName) = [ColourPoints.(ColourName); rgb];
  else
    disp(ColourName);
    ColourPoints.(ColourName) = rgb;
  end
  
  tline = fgets(fid);
end

fclose(fid);

end
