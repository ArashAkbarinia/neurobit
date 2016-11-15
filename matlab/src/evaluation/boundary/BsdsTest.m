function BsdsTest(FolderPath, TestName, SubFolderName, doedge, dothresh, TestFolder, GreyFlag)

if nargin < 7
  GreyFlag = false;
end
if nargin < 6
  TestFolder = 'others';
end
if nargin < 5
  dothresh = true;
end
if nargin < 4
  doedge = true;
end
if nargin < 3
  SubFolderName = 'test';
end
if nargin < 2
  TestName = 'tmp';
end
if nargin < 1
  FolderPath = '/home/arash/Software/Repositories/neurobit/data/dataset/BSR/';
end

if strcmpi(SubFolderName, 'test')
  ResultFolder = 'results/';
  PlotsFolder = 'plots/';
elseif strcmpi(SubFolderName, 'val')
  ResultFolder = 'results300/';
  PlotsFolder = 'plots300/';
end

if GreyFlag
  TestFolder = [TestFolder, '/grey/', TestName];
else
  TestFolder = [TestFolder, '/colour/', TestName];
end

ImageDirectory = [FolderPath, 'BSDS500/data/images/', SubFolderName];
ResultDirectory = [FolderPath, 'BSDS500/', ResultFolder, TestFolder];
if ~exist(ResultDirectory, 'dir')
  mkdir(ResultDirectory);
end

ImageList = dir([ImageDirectory, '/*.jpg']);
nfiles = length(ImageList);

tic;
if doedge
  parfor i = 1:nfiles
    disp(['processing ', ImageList(i).name]);
    CurrentFileName = ImageList(i).name;
    ImagePath = [ImageDirectory, '/', CurrentFileName];
    CurrentImage = imread(ImagePath);
    if GreyFlag
      CurrentImage = rgb2gray(CurrentImage);
    end
    CurrentImage = double(CurrentImage) ./ 255;
    
    if strcmpi(TestName, 'sco')
      EdgeImage = SCOBoundary(CurrentImage, 1.1, 6, -0.7, 5);
    elseif strcmpi(TestName, 'co')
      EdgeImage = SCOBoundary(CurrentImage, 1.1, 6, -0.7, 0);
    elseif strcmpi(TestName, 'canny')
      EdgeImage = pbCannyColour(CurrentImage);
    elseif strcmpi(TestName, 'mci')
      EdgeImage = MCIContour(CurrentImage);
    else
      EdgeImage = SurroundModulationEdgeDetector(CurrentImage);
    end
    
    ResultName = CurrentFileName(1:end-4);
    imwrite(EdgeImage, [ResultDirectory, '/', ResultName, '.png']);
  end
end
toc;

% boundary benchmark for results stored as contour images

GroundtruthDirectory = [FolderPath, 'BSDS500/data/groundTruth/', SubFolderName];
PlotsDirectory = [FolderPath, 'BSDS500/', PlotsFolder, TestFolder];
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

plot_eval(PlotsDirectory, '-mx', 'isoF-b.fig');

end
