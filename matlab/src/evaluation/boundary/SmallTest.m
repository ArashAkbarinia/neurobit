% addpath benchmarks

%clear all;close all;clc;
TestName = 'tmp';
% FOLDERPATH = '/home/arash/Software/Repositories/neurobit/data/dataset/BSR/BSDS500/';
FOLDERPATH = '/home/arash/Software/Repositories/neurobit/data/dataset/BSR/bench/';

ImageDirectory = [FOLDERPATH, 'data/images'];
ResultDirectory = [FOLDERPATH, 'results/', TestName];
mkdir(ResultDirectory);

ImageList = dir([ImageDirectory, '/*.jpg']);
nfiles = length(ImageList);
tic;
parfor i = 1:nfiles
  disp(['processing ', ImageList(i).name]);
  CurrentFileName = ImageList(i).name;
  CurrentImage = imread([ImageDirectory, '/', CurrentFileName]);
  CurrentImage = double(CurrentImage) ./ 255;
  
  EdgeImage = SCOBoundary(CurrentImage, 0.5);
  
  ResultName = CurrentFileName(1:end-4);
  imwrite(EdgeImage, [ResultDirectory, '/', ResultName, '.png']);
end
toc;

%% boundary benchmark for results stored as contour images

% FOLDERPATH = '/home/arash/Software/Repositories/neurobit/data/dataset/BSR/';

GroundtruthDirectory = [FOLDERPATH, 'data/groundTruth'];
PlotsDirectory = [FOLDERPATH, 'plots/', TestName];
ResultDirectory = [FOLDERPATH, 'results/', TestName];
% ImageDirectory = [FOLDERPATH, 'data/images/test'];
mkdir(PlotsDirectory);
nthresh = 99;

tic;
boundaryBench(ImageDirectory, GroundtruthDirectory, ResultDirectory, PlotsDirectory, nthresh);
toc;

plot_eval(PlotsDirectory);

