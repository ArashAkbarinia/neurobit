function [] = ColourNamingTestFolder(DirPath, method)

if nargin < 2
  DirPath = '/home/arash/Software/Repositories/neurobit/data/dataset/ColourNameDataset/ebay/';
  method = 'our';
end

if strcmpi(method, 'our')
  ConfigsMat = load('lab_ellipsoid_params');
  EllipsoidsTitles = ConfigsMat.RGBTitles;
  EllipsoidsRGBs = name2rgb(EllipsoidsTitles);
  MethodNumber = 1;
else
  EllipsoidDicMat = load('EllipsoidDic.mat');
  if strcmpi(method, 'joost')
    w2cmat = load('w2c.mat');
    ConfigsMat = w2cmat.w2c;
    ConversionMat = EllipsoidDicMat.joost2ellipsoid;
    MethodNumber = 2;
  else
    error(['Method ', method, ' is not supported']);
  end
end
method = lower(method);
disp(['Applying method of ', method]);

SubFolders = GetSubFolders(DirPath);

for j = 1:length(SubFolders)
  DirPathJ = [DirPath, SubFolders{j}, '/'];
  
  SubSubFolders = GetSubFolders(DirPathJ);
  for k = 1:length(SubSubFolders)
    DirPathJK = [DirPathJ, SubSubFolders{k}, '/'];
    ResultDirectory = [DirPathJK, method, '_results/'];
    if ~isdir(ResultDirectory)
      mkdir(ResultDirectory);
    end
    
    ImageFiles = dir([DirPathJK, '*.jpg']);
    MaskFiles = dir([DirPathJK, '*.png']);
    nimages = length(ImageFiles);
    if nimages ~= length(MaskFiles)
      warning(['Directory ', DirPathJK, ' does not have same number of pictures and gts.']);
      continue;
    end
    ErrorMats = zeros(nimages, 4);
    for i = 1:nimages
      ImagePath = [DirPathJK, ImageFiles(i).name];
      ImageRGB = imread(ImagePath);
      MaskPath = [DirPathJK, MaskFiles(i).name];
      ImageMask = im2bw(imread(MaskPath));
      switch MethodNumber
        case 1
          NamingImage = ApplyOurMethod(ImageRGB, ConfigsMat, ResultDirectory, ImageFiles(i).name, EllipsoidsTitles, EllipsoidsRGBs);
        case 2
          NamingImage = ApplyJoostMethod(ImageRGB, ConfigsMat, ConversionMat, ResultDirectory, ImageFiles(i).name);
      end
      ErrorMats(i, :) = ComputeError(ImageMask, NamingImage, SubSubFolders{k});
      fprintf('Sensitivity: %0.2f Specificity %0.2f Positive predictive %0.2f Negative predictive %0.2f\n', ErrorMats(i, :));
    end
    save([ResultDirectory, 'ErrorMats.mat'], 'ErrorMats');
  end
end

end

function NamingImage = ApplyOurMethod(ImageRGB, ConfigsMat, ResultDirectory, FileName, EllipsoidsTitles, EllipsoidsRGBs)

BelongingImage = rgb2belonging(ImageRGB, 'lab', ConfigsMat);
BelongingImage = PostProcessBelongingImage(ImageRGB, BelongingImage);
NamingImage = belonging2naming(BelongingImage);

figurei = PlotAllChannels(ImageRGB, BelongingImage, EllipsoidsTitles, EllipsoidsRGBs, 'Colour Categorisation - Colour Planes');
saveas(figurei, [ResultDirectory, 'res_', FileName]);
close(figurei);

end

function NamingImage = ApplyJoostMethod(ImageRGB, ConfigsMat, ConversionMat, ResultDirectory, FileName)

ImageRGB = double(ImageRGB);
NamingImage = im2c(ImageRGB, ConfigsMat, 0);

NamingImageTmp = NamingImage;
for i = 1:11
  NamingImage(NamingImageTmp == i) = ConversionMat(i);
end

figurei = figure('NumberTitle', 'Off', 'Name', 'Joost Colour Naming', 'visible', 'off');
imshow(ColourLabelImage(NamingImage));
saveas(figurei, [ResultDirectory, 'res_', FileName]);
close(figurei);

end

function ErrorMat = ComputeError(ImageMask, NamingImage, ColourName)

ErrorMat = [-1, -1, -1, -1];

switch ColourName
  case {'g', 'green'}
    ImageResult = NamingImage == 1;
  case {'b', 'blue'}
    ImageResult = NamingImage == 2;
  case {'pp', 'purple'}
    ImageResult = NamingImage == 3;
  case {'pk', 'pink'}
    ImageResult = NamingImage == 4;
  case {'r', 'red'}
    ImageResult = NamingImage == 5;
  case {'o', 'orange'}
    ImageResult = NamingImage == 6;
  case {'y', 'yellow'}
    ImageResult = NamingImage == 7;
  case {'br', 'brown'}
    ImageResult = NamingImage == 8;
  case {'gr', 'grey'}
    ImageResult = NamingImage == 9;
  case {'w', 'white'}
    ImageResult = NamingImage == 10;
  case {'bl', 'black'}
    ImageResult = NamingImage == 11;
  otherwise
    warning(['Colour ', colourname, ' is not supported, returning -1 for error mat.']);
    return;
end

[sens, spec, ppv, npv] = ContingencyTable(ImageMask, ImageResult);
ErrorMat = [sens, spec, ppv, npv];

end
