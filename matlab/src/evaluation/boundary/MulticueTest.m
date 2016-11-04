function MulticueTest(FolderPath, TestName, TypeName)

if nargin < 1
  FolderPath = '/home/arash/Software/Repositories/neurobit/data/dataset/multicue/';
end
if nargin < 2
  TestName = 'tmp';
end
if nargin < 3
  TypeName = 'boundaries';
end

doedge = true;
dothresh = true;

ImageDirectory = [FolderPath, 'images/'];
ResultDirectory = [FolderPath, 'results/', TypeName, '/', TestName];
if ~exist(ResultDirectory, 'dir')
  mkdir(ResultDirectory);
end

ImageList = dir([ImageDirectory, '*left*.png']);
nfiles = length(ImageList);

tic;
if doedge
  parfor i = 1:nfiles
    disp(['processing ', ImageList(i).name]);
    CurrentFileName = ImageList(i).name;
    ImagePath = [ImageDirectory, '/', CurrentFileName];
    CurrentImage = imread(ImagePath);
    CurrentImage = double(CurrentImage) ./ 255;
    
    EdgeImage = SurroundModulationEdgeDetector(CurrentImage);
    ResultName = CurrentFileName(1:end-4);
    imwrite(EdgeImage, [ResultDirectory, '/', ResultName, '.png']);
  end
end
toc;

% boundary benchmark for results stored as contour images

GroundtruthDirectory = [FolderPath, 'ground-truth/images/', TypeName];
PlotsDirectory = [FolderPath, 'plot/', TypeName, '/', TestName];
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

plot_eval(PlotsDirectory, '-mx', 'isoF.fig');

end
