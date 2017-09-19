function [ColourPoints, GroundTruth] = showdata(ExperimentsNo)
%SHOWDATA Show the data stored in a log-file.
%
%   SHOWDATA(FILENAME)
%
%   Thorsten.Hansen@psychol.uni-giessen.de  2015-04-13

if nargin < 1
  AllExperiments = true;
else
  AllExperiments = false;
end

initmon;

ScriptPath = mfilename('fullpath');
% DirPath = strrep(ScriptPath, 'matlab/src/algorithms/colourcategorisation/OrganiseExperimentFrontiers', 'matlab/data/mats/results/experiments/colourfrontiers/real/');
DirPath = '../data/';

MatFiles = dir([DirPath, '*.log']);

ColourPointsAll = [];
GroundTruthAll = [];
for i = 1:length(MatFiles)
  filename = [DirPath, MatFiles(i).name];
  if AllExperiments
    [rgbs, gts] = DoOneFile(filename);
    ColourPointsAll = [ColourPointsAll; rgbs]; %#ok
    GroundTruthAll = [GroundTruthAll; gts]; %#ok
  elseif strcmpi(filename(9), ExperimentsNo)
    [rgbs, gts] = DoOneFile(filename);
    ColourPointsAll = [ColourPointsAll; rgbs]; %#ok
    GroundTruthAll = [GroundTruthAll; gts]; %#ok
  end
end

ColourPoints = uint8(ColourPointsAll .* 255);
[ColourPoints, ~, IndUniqes] = unique(ColourPoints, 'rows');

OriginalDimension = size(ColourPointsAll, 1);
UniqueDimension = size(ColourPoints, 1);
GroundTruth = zeros(UniqueDimension, 1, 11);

for i = 1:OriginalDimension
  GroundTruth(IndUniqes(i), 1, :) = GroundTruth(IndUniqes(i), 1, :) + GroundTruthAll(i, 1, :);
end

SumProbs = sum(GroundTruth, 3);
for i = 1:UniqueDimension
  if SumProbs(i) == 0
    GroundTruth(i, 1, :) = 0;
  else
    GroundTruth(i, 1, :) = GroundTruth(i, 1, :) ./ SumProbs(i);
  end
end

end

function [rgbs, gts] = DoOneFile(filename, plotme)

if nargin < 2
  plotme = false;
end

% .log files are the raw data files from the experiments
%
% Format of the filenames is as follows
%
% x : Exp. 1
% a : Exp. 2
% y : Exp. 3
% w : Exp. 4
% b : Exp. 5
% v : Exp. 6
%
% tu : tunnel (not used)
%
% Adaptation point in the isoluminant plane of DKL space (Lum == 0)
% The plane is normalized to the range -500, 500 in LM and S
%      Lum  LM    S
% 00 : 0     0    0
% 01 : 0   250    0
% 01 : 0  -250    0
% 01 : 0     0  250
% 01 : 0     0 -250
%
% v/n : (does not matter)
%
% xy : initials of subject
%
% 1, 2, 3, ... : number of trial
%

% read experimental data
[z, x, y, colorcategory, colorname] = textread(filename, '%d%d%d%d%s', 'commentstyle', 'matlab');
x = x ./ 500;
y = y ./ 500;

% x y z are the DKL coordinates of the color:
% x: L-M "red-green"
% y: S-(L+M) "blue-yellow"
% z: L+M "luminance", should be always 0 (isoluminant plane)


% colorcategory is the color category picked by the observer
% colorcategories are coded as
% 1 cyan
% 2 blue
% 3 purple
% 4 green
% 5 gray
% 6 red
% 7 yellow-green
% 8 yellow
% 9 orange



% define color values for plotting
cyan = [0  229  238]/255;
blue = [0 0 1];
purple = [0.6275 0.1255 0.9412];
green = [0 1 0];
gray = [0.7451 0.7451 0.7451];
red = [1 0 0];
yellowgreen = [0.4980 1 0];
yellow = [1 1 0];
orange = [1.0000 0.6471 0];

% the order is defined by the coding of colors in the experiment
% cyan = 1, blue = 2, ...
color = [cyan; blue; purple; green; gray; red; yellowgreen; yellow; orange];

if plotme
  figure;
  axis;
  hold on;
end

rgbs = zeros(numel(x), 3);
gts = zeros(numel(x), 1, 11);
for i=1:numel(x)
  %   plot(x(i), y(i), '.', 'Color', color(colorcategory(i), :))
  colouri = dklcart2rgb([z(i), x(i), y(i)]);
  colouri(colouri < -1) = -1;
  colouri(colouri >  1) = 1;
  colouri = NormaliseChannel(colouri, 0, 1, -1, 1);
  if plotme
    plot(x(i), y(i), '.', 'Color', colouri);
  end
  rgbs(i, :) = colouri';
  switch colorcategory(i)
    case 2
      gts(i, 1, 2) = 1;
    case 3
      gts(i, 1, 3) = 1;
    case 4
      gts(i, 1, 1) = 1;
    case 5
      gts(i, 1, 9) = 1;
    case 6
      gts(i, 1, 5) = 1;
    case 8
      gts(i, 1, 7) = 1;
    case 9
      gts(i, 1, 6) = 1;
    otherwise
  end
end
if plotme
  xlabel('L/M')
  ylabel('-S')
  title(filename)
end

end
