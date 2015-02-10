function [ErrorMats] = ColourNamingTestFolder(DirPath, method, EvaluateGroundTruth, GroundTruthColour)

if nargin < 3
  DirPath = '/home/arash/Software/Repositories/neurobit/data/dataset/ColourNameDataset/soccer/acmilan/';
  method = 'our';
  EvaluateGroundTruth = false;
end

if strcmpi(method, 'our')
  ConfigsMat = load('lab_ellipsoid_params_new');
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
  elseif strcmpi(method, 'robert')
    ConfigsMat.ParFileName1 = 'TSE_JOSA_Params1.mat';
    ConfigsMat.ParFileName2 = 'TSE_JOSA_Params2.mat';
    ConfigsMat.ParFileName3 = 'TSE_JOSA_Params3.mat';
    ConversionMat = EllipsoidDicMat.robert2ellipsoid;
    MethodNumber = 3;
  else
    error(['Method ', method, ' is not supported']);
  end
end
method = lower(method);
disp(['Applying method of ', method]);

ResultDirectory = [DirPath, method, '_results/'];
if ~isdir(ResultDirectory)
  mkdir(ResultDirectory);
end

ImageFiles = dir([DirPath, '*.jpg']);
nimages = length(ImageFiles);

if EvaluateGroundTruth
  MaskFiles = dir([DirPath, '*.png']);
  if nimages ~= length(MaskFiles)
    warning(['Directory ', DirPath, ' does not have same number of pictures and gts.']);
    EvaluateGroundTruth = false;
  end
end

if EvaluateGroundTruth
  ErrorMats = cell(nimages, 1);
end
for i = 1:nimages
  ImagePath = [DirPath, ImageFiles(i).name];
  ImageRGB = imread(ImagePath);
  switch MethodNumber
    case 1
      NamingImage = ApplyOurMethod(ImageRGB, ConfigsMat, ResultDirectory, ImageFiles(i).name, EllipsoidsTitles, EllipsoidsRGBs);
    case 2
      NamingImage = ApplyJoostMethod(ImageRGB, ConfigsMat, ConversionMat, ResultDirectory, ImageFiles(i).name);
    case 3
      NamingImage = ApplyRobertMethod(ImageRGB, ConfigsMat, ConversionMat, ResultDirectory, ImageFiles(i).name);
  end
  if EvaluateGroundTruth
    MaskPath = [DirPath, MaskFiles(i).name];
    ImageMask = im2bw(imread(MaskPath));
    ErrorMats{i} = ComputeError(ImageMask, NamingImage, GroundTruthColour);
    fprintf('Sensitivity %0.2f Specificity %0.2f Positive predictive %0.2f Negative predictive %0.2f\n', ErrorMats{i}.sens, ErrorMats{i}.spec, ErrorMats{i}.ppv, ErrorMats{i}.npv);
    fprintf('TP %d FP %d TN %d FN %d\n', ErrorMats{i}.tp, ErrorMats{i}.fp, ErrorMats{i}.tn, ErrorMats{i}.fn);
  end
end
if EvaluateGroundTruth
  save([ResultDirectory, 'ErrorMats.mat'], 'ErrorMats');
end

end

function NamingImage = ApplyOurMethod(ImageRGB, ConfigsMat, ResultDirectory, FileName, EllipsoidsTitles, EllipsoidsRGBs)

BelongingImage = rgb2belonging(ImageRGB, 'lab', ConfigsMat);
BelongingImage = PostProcessBelongingImage(ImageRGB, BelongingImage);
NamingImage = belonging2naming(BelongingImage, true);

figurei = PlotAllChannels(ImageRGB, BelongingImage, EllipsoidsTitles, EllipsoidsRGBs, 'Colour Categorisation - Colour Planes');
saveas(figurei, [ResultDirectory, 'res_prob', FileName]);
close(figurei);

figurei = figure('NumberTitle', 'Off', 'Name', 'Our Colour Naming', 'visible', 'off');
subplot(1, 2, 1);
imshow(uint8(ImageRGB));
subplot(1, 2, 2);
imshow(ColourLabelImage(NamingImage));
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
subplot(1, 2, 1);
imshow(uint8(ImageRGB));
subplot(1, 2, 2);
imshow(ColourLabelImage(NamingImage));
saveas(figurei, [ResultDirectory, 'res_', FileName]);
close(figurei);

end

function NamingImage = ApplyRobertMethod(ImageRGB, ConfigsMat, ConversionMat, ResultDirectory, FileName)

ImageRGB = double(ImageRGB);
[~, NamingImage, ~] = ImColorNamingTSELab(ImageRGB, ConfigsMat.ParFileName1, ConfigsMat.ParFileName2, ConfigsMat.ParFileName3);

NamingImageTmp = NamingImage;
for i = 1:11
  NamingImage(NamingImageTmp == i) = ConversionMat(i);
end

figurei = figure('NumberTitle', 'Off', 'Name', 'Robert Colour Naming', 'visible', 'off');
subplot(1, 2, 1);
imshow(uint8(ImageRGB));
subplot(1, 2, 2);
imshow(ColourLabelImage(NamingImage));
saveas(figurei, [ResultDirectory, 'res_', FileName]);
close(figurei);

end

function contingency = ComputeError(ImageMask, NamingImage, ColourName)

% TODO: if colourname is all

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
    warning(['Colour ', ColourName, ' is not supported, returning -1 for error mat.']);
    return;
end

contingency = ContingencyTable(ImageMask, ImageResult);

end
