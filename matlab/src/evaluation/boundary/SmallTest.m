function [OptimisedParams, RSS, exitflag, output] = SmallTest(dooptimise)

if nargin < 1
  dooptimise = false;
end

if dooptimise
  
  lb = ...
    [
    0, 0, 0, 0, 0, 0, 0, 0
    ];
  ub = ...
    [
    1, 1, 1, 1, 1, 1, 1, 1
    ];
  options = optimoptions(@fmincon,'Algorithm', 'sqp', 'Display', 'notify-detailed', 'MaxIter', 10, 'TolFun', 1e-10, 'MaxFunEvals', 1e10);
  
  initial = [0.2, 0.4, 0.3, 0.4, 0.2, 0.3, 0.2, 0.3];
  [OptimisedParams, RSS, exitflag, output] = fmincon(@(x) OptimiseEdgeDetector(x), initial, [], [], [], [], lb, ub, @optimiseconst, options);
  
else
  OptimisedParams = [];
  RSS = [];
  exitflag = [];
  output = [];
  
  doedge = true;
  dothresh = true;
  doplot = true;
  x = [0.2, 0.4, 0.3, 0.4, 0.2, 0.3, 0.2, 0.3];
  ApplyEdgeDetector(doedge, dothresh, doplot, x);
end

end

function [c,ceq] = optimiseconst(x)

c(1) = x(1) - x(2);
c(2) = x(3) - x(4);
c(3) = x(5) - x(6);
c(4) = x(7) - x(8);
ceq = [];

end

function fmeasure = OptimiseEdgeDetector(x)

fmeasure = ApplyEdgeDetector(true, true, false, x);

end

function fmeasure = ApplyEdgeDetector(doedge, dothresh, doplot, x)

TestName = 'tmp';

if nargin < 4
  doedge = true;
  dothresh = true;
  doplot = false;
  x = [0.2, 0.4, 0.3, 0.4, 0.2, 0.3, 0.2, 0.3];
end

FOLDERPATH = '/home/arash/Software/Repositories/neurobit/data/dataset/BSR/bench/';
% FOLDERPATH = '/home/arash/Software/Repositories/neurobit/data/dataset/ContourImageDatabase/';

ImageDirectory = [FOLDERPATH, 'data/images'];
ResultDirectory = [FOLDERPATH, 'results/', TestName];
if ~exist(ResultDirectory, 'dir')
  mkdir(ResultDirectory);
end

ImageList = dir([ImageDirectory, '/*.jpg']);
ImageList = [ImageList; dir([ImageDirectory,'/*.pgm'])];
nfiles = length(ImageList);

% load 'svmmdl.mat';

tic;
if doedge
  parfor i = 1:nfiles
    disp(['processing ', ImageList(i).name]);
    CurrentFileName = ImageList(i).name;
    ImagePath = [ImageDirectory, '/', CurrentFileName];
    CurrentImage = imread(ImagePath);
    CurrentImage = double(CurrentImage) ./ 255;
       
%     EdgeImage = SCOBoundary(CurrentImage, 1.1, 8, -0.7, 5);
    EdgeImage = SurroundModulationEdgeDetector(CurrentImage);
    
    ResultName = CurrentFileName(1:end-4);
    imwrite(EdgeImage, [ResultDirectory, '/', ResultName, '.png']);

%     FeatureImage = Features_SurroundModulationEdgeDetector(CurrentImage);
%     [rows, cols, chns] = size(FeatureImage);
%     FeatureImage = reshape(FeatureImage, rows * cols, chns);
%     
%     [labels, scores] = predict(svmmdl, FeatureImage);
%     arashscores = max(max(scores(:, 1))) - scores(:, 1);
%     arashscores = arashscores ./ max(arashscores(:));
%     
%     ResultName = CurrentFileName(1:end-4);
%     EdgeImage = reshape(arashscores, rows, cols);
%     imwrite(EdgeImage, [ResultDirectory, '/', ResultName, '.png']);
  end
end
toc;

% boundary benchmark for results stored as contour images

GroundtruthDirectory = [FOLDERPATH, 'data/groundTruth'];
PlotsDirectory = [FOLDERPATH, 'plots/', TestName];
ResultDirectory = [FOLDERPATH, 'results/', TestName];
nthresh = 15;

tic;
if dothresh
  if exist(PlotsDirectory, 'dir')
    rmdir(PlotsDirectory, 's');
  end
  mkdir(PlotsDirectory);
  boundaryBench(ImageDirectory, GroundtruthDirectory, ResultDirectory, PlotsDirectory, nthresh);
end
toc;

if doplot
  plot_eval(PlotsDirectory, '-mx', 'isoF-s.fig');
end

evalRes = dlmread(fullfile(PlotsDirectory,'eval_bdry.txt'));
fmeasure = 1.00 - evalRes(4);

end
