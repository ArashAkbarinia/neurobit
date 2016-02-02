function ErrorMats = ColourNamingTestFolderAllCategories(DirPath, method, EvaluateGroundTruth)
%ColourNamingTestFolderAllCategories Summary of this function goes here
%   Detailed explanation goes here

if nargin < 3
  DirPath = '/home/arash/Software/Repositories/neurobit/data/dataset/ColourNameDataset/ColorNamingYuanliu/Car/';
  method = 'ourlab';
  EvaluateGroundTruth = true;
end

EllipsoidDicMat = load('EllipsoidDic.mat');
if strcmpi(method, 'ourlab')
  ConfigsMat = load('lab_ellipsoid_params');
  MethodNumber = 1;
elseif strcmpi(method, 'ourlsy')
  ConfigsMat = load('lsy_ellipsoid_params');
  MethodNumber = 1;
else
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

if MethodNumber ~= 1
  ConfigsMatRgbTitle = load('lab_ellipsoid_params');
else
  ConfigsMatRgbTitle = ConfigsMat;
end
EllipsoidsTitles = ConfigsMatRgbTitle.RGBTitles;
EllipsoidsRGBs = name2rgb(EllipsoidsTitles);

ResultDirectory = [DirPath, method, '_results/'];
if ~isdir(ResultDirectory)
  mkdir(ResultDirectory);
end

ImagesPath = [DirPath, 'Images/'];
ImageFiles = dir([ImagesPath, '*.tif']);
ImageFiles = [ImageFiles; dir([ImagesPath,'*.bmp'])];
ImageFiles = [ImageFiles; dir([ImagesPath,'*.jpg'])];
nimages = length(ImageFiles);

if EvaluateGroundTruth
  GtsPath = [DirPath, 'Annotations/'];
  MaskFiles = dir([GtsPath, '*.mat']);
  if nimages ~= length(MaskFiles)
    warning(['Directory ', DirPath, ' does not have same number of pictures and gts.']);
    EvaluateGroundTruth = false;
  end
end

if EvaluateGroundTruth
  ErrorMats = zeros(nimages, 8);
end
for i = 1:nimages
  ImagePath = [ImagesPath, ImageFiles(i).name];
  ImageRGB = double(imread(ImagePath));
  ImageRGB = uint8(ImageRGB ./ max(ImageRGB(:)) .* 255);
  disp(ImagePath);
  switch MethodNumber
    case 1
      [NamingImage, BelongingImage] = ColourNamingOur(ImageRGB, ConfigsMat);
    case 2
      [NamingImage, BelongingImage] = ColourNamingJoost(ImageRGB, ConfigsMat, ConversionMat);
    case 3
      [NamingImage, BelongingImage] = ColourNamingRobert(ImageRGB, ConfigsMat, ConversionMat);
  end
  
  save([ResultDirectory, 'res_prob', ImageFiles(i).name(1:end - 3), 'mat', 'BelongingImage')
  % plotting
  figurei = PlotAllChannels(ImageRGB, BelongingImage, EllipsoidsTitles, EllipsoidsRGBs, 'Colour Categorisation - Colour Planes');
  saveas(figurei, [ResultDirectory, 'res_prob', ImageFiles(i).name(1:end - 3), 'jpg']);
  close(figurei);
  
  figurei = figure('NumberTitle', 'Off', 'Name', [method, ' Colour Naming'], 'visible', 'off');
  subplot(1, 2, 1);
  imshow(uint8(ImageRGB));
  subplot(1, 2, 2);
  imshow(ColourLabelImage(NamingImage));
  saveas(figurei, [ResultDirectory, 'res_', ImageFiles(i).name(1:end - 3), 'jpg']);
  close(figurei);
  
  if EvaluateGroundTruth
    MaskPath = [GtsPath, lower(ImageFiles(i).name(1:end - 3)), 'mat'];
    GtMat = load(MaskPath);
    nRegions = size(GtMat.colorprop, 1);
    ErrorMatsCat = zeros(nRegions, 8);
    for c = 1:nRegions
      ImageMask = GtMat.objmap;
      ImageMask = ImageMask == c;
      
      MaxPercent = max(GtMat.colorprop(c, :));
      MaxInds = find(GtMat.colorprop(c, :) == MaxPercent);
      
      ImageResult = zeros(size(ImageMask));
      for m = 1:length(MaxInds)
        GroundTruthColour = EllipsoidDicMat.yuanliu2ellipsoid(MaxInds(m));
        ImageResult = NamingImage == GroundTruthColour | ImageResult;
      end
      contingency = ContingencyTable(ImageMask, ImageResult);
      ErrorMatsCat(c, :) = struct2array(contingency);
    end
    
    ErrorMats(i, :) = sum(ErrorMatsCat, 1);
    [acc, f1, er] = ReportResults(ErrorMats(i, :));
    fprintf('[%d]\t- Accuracy %0.2f F1-Score %0.2f Error-Rate %0.2f \n', i, acc, f1, er);
  end
  
end

[acc, f1, er] = ReportResults(sum(ErrorMats, 1));
fprintf('Sum: Accuracy %0.2f F1-Score %0.2f Error-Rate %0.2f\n', acc, f1, er);

if EvaluateGroundTruth
  save([ResultDirectory, 'ErrorMats.mat'], 'ErrorMats');
end

end

function [acc, f1, er] = ReportResults(ErrorMat)

tp = ErrorMat(1, 5);
fp = ErrorMat(1, 6);
fn = ErrorMat(1, 7);
tn = ErrorMat(1, 8);

acc = (tp + tn) / (tp + fp + fn + tn);
f1 = (2 * tp) / ((2 * tp) + fp + fn);
er = fn / (tp + fn);

end
