% addpath benchmarks

%clear all;close all;clc;
TestName = 'arash';
FOLDERPATH = '/home/arash/Software/Repositories/neurobit/data/dataset/BSR/';

ImageDirectory = [FOLDERPATH, 'BSDS500/data/images/test'];
ResultDirectory = [FOLDERPATH, 'BSDS500/results/', TestName];
mkdir(ResultDirectory);

ImageList = dir([ImageDirectory, '/*.jpg']);
nfiles = length(ImageList);
tic;
parfor i = 1:nfiles
  disp(['processing ', ImageList(i).name]);
  CurrentFileName = ImageList(i).name;
  CurrentImage = imread([ImageDirectory, '/', CurrentFileName]);
  CurrentImage = double(CurrentImage) ./ 255;
  
% %   ConfigsMat = load('/home/arash/Software/Repositories/neurobit/lab_ellipsoid_params_new');
% %   ConfigsMat.ColourEllipsoids(:, 10) = 0.01;
% %   BelongingImage = rgb2belonging(CurrentImage, ConfigsMat, false, []);
%   
%   CurrentImage = double(rgb2gray(CurrentImage));
%   CurrentImage = CurrentImage ./ 255;
%   EdgeImage = SurroundModulationEdgeDetector(CurrentImage);
% %   EdgeImage = zeros(size(BelongingImage));
% %   for j = 1:11
% %     EdgeImage(:, :, j) = pbCanny(BelongingImage(:, :, j));
% %   end
% %   EdgeImage = pbCannyColour(CurrentImage);
% %   EdgeImage = sum(EdgeImage, 3);
%   EdgeImage = uint8(NormaliseChannel(EdgeImage, 0, 255, [], []));

  EdgeImage = SCOBoundary(CurrentImage, 0.5);
%   EdgeImage = SurroundModulationEdgeDetector(CurrentImage);

  ResultName = CurrentFileName(1:end-4);
  imwrite(EdgeImage, [ResultDirectory, '/', ResultName, '.png']);
end
toc;

%% boundary benchmark for results stored as contour images

FOLDERPATH = '/home/arash/Software/Repositories/neurobit/data/dataset/BSR/';

GroundtruthDirectory = [FOLDERPATH, 'BSDS500/data/groundTruth/test'];
PlotsDirectory = [FOLDERPATH, 'BSDS500/plots/', TestName];
ResultDirectory = [FOLDERPATH, 'BSDS500/results/', TestName];
ImageDirectory = [FOLDERPATH, 'BSDS500/data/images/test'];
mkdir(PlotsDirectory);
nthresh = 99;

tic;
boundaryBench(ImageDirectory, GroundtruthDirectory, ResultDirectory, PlotsDirectory, nthresh);
toc;

plot_eval(PlotsDirectory);
