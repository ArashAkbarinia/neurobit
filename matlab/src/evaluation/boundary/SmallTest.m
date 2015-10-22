function [OptimisedParams, RSS, exitflag, output] = SmallTest()

lb = ...
  [
  +0.50, +0.50, -0.75, -0.75, -0.15, -0.15
  ];
ub = ...
  [
  +1.00, +1.00, +0.75, +0.75, +0.15, +0.15
  ];
options = optimoptions(@fmincon,'Algorithm', 'sqp', 'Display', 'notify', 'MaxIter', 10, 'TolFun', 1e-10, 'MaxFunEvals', 1e10);

initial = [0.50, 1.00, -0.75, +0.75, -0.15, +0.15];
[OptimisedParams, RSS, exitflag, output] = fmincon(@(x) ApplyEdgeDetector(x), initial, [], [], [], [], lb, ub, @optimiseconst, options);

% weights1 = [0.50, 1.00, -0.75, +0.75, -0.15, 0.15];
% fmeasure = ApplyEdgeDetector(weights1);

end

function [c,ceq] = optimiseconst(x)

c(1) = x(1) - x(2);
c(2) = x(3) - x(4);
c(3) = x(5) - x(6);
c(4) = abs(x(3) / 2) - x(1);
c(5) = abs(x(5)) - x(1);
c(6) = x(3) - x(5);
c(7) = x(6) - x(4);
ceq = [];

end

function fmeasure = ApplyEdgeDetector(weights1)
TestName = 'tmp'; %centre-0.5-10-16

doedge = true;
dothresh = true;
doplot = false;

FOLDERPATH = '/home/arash/Software/Repositories/neurobit/data/dataset/BSR/bench/';

ImageDirectory = [FOLDERPATH, 'data/images'];
ResultDirectory = [FOLDERPATH, 'results/', TestName];
% mkdir(ResultDirectory);

ImageList = dir([ImageDirectory, '/*.jpg']);
nfiles = length(ImageList);
% weights1 = [0.50, 1.00, -0.75, +0.75, -0.15, 0.15];

tic;
if doedge
  parfor i = 1:nfiles
    disp(['processing ', ImageList(i).name]);
    CurrentFileName = ImageList(i).name;
    ImagePath = [ImageDirectory, '/', CurrentFileName];
    CurrentImage = imread(ImagePath);
    CurrentImage = double(CurrentImage) ./ 255;
    
    %     EdgeImage = SCOBoundary(CurrentImage, 1.1);
    EdgeImage = SCOBoundaryContrast(CurrentImage, 1.1, 8, 5, ImagePath, weights1);
    
    ResultName = CurrentFileName(1:end-4);
    imwrite(EdgeImage, [ResultDirectory, '/', ResultName, '.png']);
  end
end
toc;

% boundary benchmark for results stored as contour images

GroundtruthDirectory = [FOLDERPATH, 'data/groundTruth'];
PlotsDirectory = [FOLDERPATH, 'plots/', TestName];
ResultDirectory = [FOLDERPATH, 'results/', TestName];
nthresh = 5;

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
  plot_eval(PlotsDirectory);
end

evalRes = dlmread(fullfile(PlotsDirectory,'eval_bdry.txt'));
fmeasure = 1.00 - evalRes(4);

end
