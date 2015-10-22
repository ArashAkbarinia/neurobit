% addpath benchmarks

%clear all;close all;clc;
TestName = 'centre-0.5-10-16'; % -surround-1.0-2-4

doedge = true;
dothresh = true;

FOLDERPATH = '/home/arash/Software/Repositories/neurobit/data/dataset/BSR/';

ImageDirectory = [FOLDERPATH, 'BSDS500/data/images/test'];
ResultDirectory = [FOLDERPATH, 'BSDS500/results/', TestName];
mkdir(ResultDirectory);

ImageList = dir([ImageDirectory, '/*.jpg']);
nfiles = length(ImageList);
tic;
if doedge
  parfor i = 1:nfiles
    disp(['processing ', ImageList(i).name]);
    CurrentFileName = ImageList(i).name;
    ImagePath = [ImageDirectory, '/', CurrentFileName];
    CurrentImage = imread(ImagePath);
    CurrentImage = double(CurrentImage) ./ 255;
    
%     EdgeImage = SCOBoundary(CurrentImage, 1.1);
    EdgeImage = SCOBoundaryContrast(CurrentImage, 1.1, 8, 5, ImagePath);
    
    ResultName = CurrentFileName(1:end-4);
    imwrite(EdgeImage, [ResultDirectory, '/', ResultName, '.png']);
  end
end
toc;

%% boundary benchmark for results stored as contour images

GroundtruthDirectory = [FOLDERPATH, 'BSDS500/data/groundTruth/test'];
PlotsDirectory = [FOLDERPATH, 'BSDS500/plots/', TestName];
ResultDirectory = [FOLDERPATH, 'BSDS500/results/', TestName];
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
