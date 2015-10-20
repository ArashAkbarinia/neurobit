% addpath benchmarks

%clear all;close all;clc;
TestName = 'centre-0.5-10-16'; %centre-0.5-10-16

doedge = true;
dothresh = true;

FOLDERPATH = '/home/arash/Software/Repositories/neurobit/data/dataset/BSR/bench/';

ImageDirectory = [FOLDERPATH, 'data/images'];
ResultDirectory = [FOLDERPATH, 'results/', TestName];
mkdir(ResultDirectory);

ImageList = dir([ImageDirectory, '/*.jpg']);
nfiles = length(ImageList);
tic;
if doedge
  parfor i = 1:nfiles
    disp(['processing ', ImageList(i).name]);
    CurrentFileName = ImageList(i).name;
    CurrentImage = imread([ImageDirectory, '/', CurrentFileName]);
    CurrentImage = double(CurrentImage) ./ 255;
    
%     EdgeImage = SCOBoundary(CurrentImage, 1.1);
    EdgeImage = SCOBoundaryContrast(CurrentImage, 0.5);
    
    ResultName = CurrentFileName(1:end-4);
    imwrite(EdgeImage, [ResultDirectory, '/', ResultName, '.png']);
  end
end
toc;

%% boundary benchmark for results stored as contour images

GroundtruthDirectory = [FOLDERPATH, 'data/groundTruth'];
PlotsDirectory = [FOLDERPATH, 'plots/', TestName];
ResultDirectory = [FOLDERPATH, 'results/', TestName];
nthresh = 99;

tic;
if dothresh
  if exist(PlotsDirectory, 'dir')
    rmdir(PlotsDirectory, 's');
  end
  mkdir(PlotsDirectory);
  boundaryBench(ImageDirectory, GroundtruthDirectory, ResultDirectory, PlotsDirectory, nthresh);
end
toc;

plot_eval(PlotsDirectory);
