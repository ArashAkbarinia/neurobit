function [ColourFrontiers, borders] = ReadExperimentResults(FilePath, ColourFrontiers, borders)
%ReadExperimentResults  maps the colour frontiers result to its object.
%
% inputs
%   FilePath         the path to the mat file.
%   ColourFrontiers  previous list of colour frontiers, by default is empty,
%                    if it's not empty the new frontiers are added to this
%                    list.
%   borders          previous list of colour borders, by default is empty,
%                    if it's not empty the new borders are added to this
%                    list.
%
% outputs
%   ColourFrontiers  the updated list of colour frontiers.
%   borders          the updated list of borders.
%

if nargin < 3
  ColourFrontiers = struct();
  borders = {};
  
  % colour objects
  ColourFrontiers.black  = ColourCategory('black');
  ColourFrontiers.blue   = ColourCategory('blue');
  ColourFrontiers.brown  = ColourCategory('brown');
  ColourFrontiers.green  = ColourCategory('green');
  ColourFrontiers.grey   = ColourCategory('grey');
  ColourFrontiers.orange = ColourCategory('orange');
  ColourFrontiers.pink   = ColourCategory('pink');
  ColourFrontiers.purple = ColourCategory('purple');
  ColourFrontiers.red    = ColourCategory('red');
  ColourFrontiers.yellow = ColourCategory('yellow');
  ColourFrontiers.white  = ColourCategory('white');
end

MatFile = load(FilePath);
ExperimentResult = MatFile.ExperimentResults;

if strcmpi(ExperimentResult.type, 'arch') || strcmpi(ExperimentResult.type, 'centre')
  [ColourFrontiers, borders] = DoArchCentre(ColourFrontiers, borders, ExperimentResult);
elseif strcmpi(ExperimentResult.type, 'lum')
  % FIXME: how to integrate luminance
  [ColourFrontiers, borders] = DoLuminance(ColourFrontiers, borders, ExperimentResult);
end

end

% TODO: make this code more readable
function [ColourFrontiers, borders] = DoArchCentre(ColourFrontiers, borders, ExperimentResult)

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
        ColourFrontiers.(ColourA) = ColourFrontiers.(ColourA).SetBorder(border);
        ColourFrontiers.(ColourB) = ColourFrontiers.(ColourB).SetBorder(border);
        borders{j} = border;
        break;
      end
    end
    
    if isempty(border)
      border = ColourBorder(ColourFrontiers.(ColourA), ColourFrontiers.(ColourB), lsys.(LumName)(k, :), nluminances(i));
      ColourFrontiers.(ColourA) = ColourFrontiers.(ColourA).AddBorder(border);
      ColourFrontiers.(ColourB) = ColourFrontiers.(ColourB).AddBorder(border);
      borders{end + 1} = border; %#ok<AGROW>
    end
  end
end

end

function [ColourFrontiers, borders] = DoLuminance(ColourFrontiers, borders, ExperimentResult)

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
      ColourFrontiers.(ColourA) = ColourFrontiers.(ColourA).SetBorder(border);
      ColourFrontiers.(ColourB) = ColourFrontiers.(ColourB).SetBorder(border);
      borders{j} = border;
      break;
    end
  end
  
  if isempty(border)
    border = ColourBorder(ColourFrontiers.(ColourA), ColourFrontiers.(ColourB), lsys(i, :), LumName);
    ColourFrontiers.(ColourA) = ColourFrontiers.(ColourA).AddBorder(border);
    ColourFrontiers.(ColourB) = ColourFrontiers.(ColourB).AddBorder(border);
    borders{end + 1} = border; %#ok<AGROW>
  end
end

end
