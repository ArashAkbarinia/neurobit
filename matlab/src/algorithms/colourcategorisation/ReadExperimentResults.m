function [lsYFrontiers, borders] = ReadExperimentResults(FilePath, lsYFrontiers, borders)

if nargin < 3
  lsYFrontiers = struct();
  borders = {};
  
  % colour objects
  lsYFrontiers.black  = ColourCategory('black');
  lsYFrontiers.blue   = ColourCategory('blue');
  lsYFrontiers.brown  = ColourCategory('brown');
  lsYFrontiers.green  = ColourCategory('green');
  lsYFrontiers.grey   = ColourCategory('grey');
  lsYFrontiers.orange = ColourCategory('orange');
  lsYFrontiers.pink   = ColourCategory('pink');
  lsYFrontiers.purple = ColourCategory('purple');
  lsYFrontiers.red    = ColourCategory('red');
  lsYFrontiers.yellow = ColourCategory('yellow');
  lsYFrontiers.white  = ColourCategory('white');
end

MatFile = load(FilePath);
ExperimentResult = MatFile.ExperimentResults;

if strcmpi(ExperimentResult.type, 'arch') || strcmpi(ExperimentResult.type, 'centre')
  [lsYFrontiers, borders] = DoArchCentre(lsYFrontiers, borders, ExperimentResult);
elseif strcmpi(ExperimentResult.type, 'lum')
  % FIXME: how to integrate luminance
  [lsYFrontiers, borders] = DoLuminance(lsYFrontiers, borders, ExperimentResult);
end

end

% TODO: make this code more readable
function [lsYFrontiers, borders] = DoArchCentre(lsYFrontiers, borders, ExperimentResult)

angles = ExperimentResult.angles;
radii = ExperimentResult.radii;
luminances = ExperimentResult.luminances;
FrontierColours = ExperimentResult.FrontierColours;
WhiteReference = ExperimentResult.WhiteReference;
XYZ2lsYChoise = 'evenly_ditributed_stds';

nborders = length(unique(ExperimentResult.conditions));
nexperiments = length(angles);
nluminances = unique(luminances);
nconditions = floor(nexperiments / nborders);

% containts the points for different luminances
lsys = struct();
% counter for each luminance
lcounter = struct();
lsysnames = struct();

for i = 1:length(nluminances)
  LumName = ['lum', num2str(nluminances(i))];
  lsys.(LumName) = zeros(nconditions, 3);
  lcounter.(LumName) = 1;
  lsysnames.(LumName) = cell(nconditions, 2);
end

for i = 1:nexperiments
  lab = pol2cart3([angles(i), radii(i), luminances(i)], 1);
  LumName = ['lum', num2str(luminances(i))];
  lsys.(LumName)(lcounter.(LumName), :) = XYZ2lsY(Lab2XYZ(lab, WhiteReference), XYZ2lsYChoise);
  ColourA = lower(FrontierColours{i, 1});
  ColourB = lower(FrontierColours{i, 2});
  lsysnames.(LumName)(lcounter.(LumName), :) = {ColourA, ColourB};
  lcounter.(LumName) = lcounter.(LumName) + 1;
end

for i = 1:length(nluminances)
  LumName = ['lum', num2str(nluminances(i))];
  
  for k = 1:nconditions
    ColourA = lsysnames.(LumName){k, 1};
    ColourB = lsysnames.(LumName){k, 2};
    
    border = [];
    for j = 1:length(borders)
      colour1 = borders{j}.colour1.name;
      colour2 = borders{j}.colour2.name;
      if (strcmpi(colour1, ColourA) || strcmpi(colour1, ColourB)) && ...
          (strcmpi(colour2, ColourA) || strcmpi(colour2, ColourB))
        border = borders{j};
        border = border.AddPoints(lsys.(LumName)(k, :), nluminances(i));
        lsYFrontiers.(ColourA) = lsYFrontiers.(ColourA).SetBorder(border);
        lsYFrontiers.(ColourB) = lsYFrontiers.(ColourB).SetBorder(border);
        borders{j} = border;
        break;
      end
    end
    
    if isempty(border)
      border = ColourBorder(lsYFrontiers.(ColourA), lsYFrontiers.(ColourB), lsys.(LumName)(k, :), nluminances(i));
      lsYFrontiers.(ColourA) = lsYFrontiers.(ColourA).AddBorder(border);
      lsYFrontiers.(ColourB) = lsYFrontiers.(ColourB).AddBorder(border);
      borders{end + 1} = border; %#ok<AGROW>
    end
  end
end

end

function [lsYFrontiers, borders] = DoLuminance(lsYFrontiers, borders, ExperimentResult)

angles = ExperimentResult.angles;
radii = ExperimentResult.radii;
luminances = ExperimentResult.luminances;
FrontierColours = ExperimentResult.FrontierColours;
WhiteReference = ExperimentResult.WhiteReference;
XYZ2lsYChoise = 'evenly_ditributed_stds';

nexperiments = length(angles);

LumName = 0;

lsys = zeros(nexperiments, 3);
lsysnames = cell(nexperiments, 2);

for i = 1:nexperiments
  lab = pol2cart3([angles(i), radii(i), luminances(i)], 1);
  lsys(i, :) = XYZ2lsY(Lab2XYZ(lab, WhiteReference), XYZ2lsYChoise);
  ColourA = lower(FrontierColours{i, 1});
  ColourB = lower(FrontierColours{i, 2});
  lsysnames(i, :) = {ColourA, ColourB};
  
  border = [];
  for j = 1:length(borders)
    colour1 = borders{j}.colour1.name;
    colour2 = borders{j}.colour2.name;
    if (strcmpi(colour1, ColourA) || strcmpi(colour1, ColourB)) && ...
        (strcmpi(colour2, ColourA) || strcmpi(colour2, ColourB))
      border = borders{j};
      border = border.AddPoints(lsys(i, :), LumName);
      lsYFrontiers.(ColourA) = lsYFrontiers.(ColourA).SetBorder(border);
      lsYFrontiers.(ColourB) = lsYFrontiers.(ColourB).SetBorder(border);
      borders{j} = border;
      break;
    end
  end
  
  if isempty(border)
    border = ColourBorder(lsYFrontiers.(ColourA), lsYFrontiers.(ColourB), lsys(i, :), LumName);
    lsYFrontiers.(ColourA) = lsYFrontiers.(ColourA).AddBorder(border);
    lsYFrontiers.(ColourB) = lsYFrontiers.(ColourB).AddBorder(border);
    borders{end + 1} = border; %#ok<AGROW>
  end
end

end
