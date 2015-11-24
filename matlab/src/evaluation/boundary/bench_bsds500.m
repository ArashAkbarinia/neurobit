function bench_bsds500()

TestName = 'tmp';

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
    
    EdgeImage = SurroundModulationEdgeDetector(CurrentImage);
%     EdgeImage = SCOBoundary(CurrentImage, 1.1, 6, -0.7, 5);
    
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

plot_eval(PlotsDirectory, '-mx', 'isoF-b.fig');

end
