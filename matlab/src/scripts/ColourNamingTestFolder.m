function [] = ColourNamingTestFolder(DirPath)

ConfigsMat = load('lab_ellipsoid_params');
ColourEllipsoids = ConfigsMat.ColourEllipsoids;
EllipsoidsTitles = ConfigsMat.RGBTitles;

EllipsoidsRGBs = name2rgb(EllipsoidsTitles);

SubFolders = GetSubFolders(DirPath);

for j = 1:length(SubFolders)
  DirPathJ = [DirPath, SubFolders{j}, '/'];
  
  SubSubFolders = GetSubFolders(DirPathJ);
  for k = 1:length(SubSubFolders)
    DirPathJK = [DirPathJ, SubSubFolders{k}, '/'];
    ResultDirectory = [DirPathJK, 'results/'];
    if ~isdir(ResultDirectory)
      mkdir(ResultDirectory);
    end
    
    ImageFiles = dir([DirPathJK, '*.jpg']);
    MaskFiles = dir([DirPathJK, '*.png']);
    if length(ImageFiles) ~= length(MaskFiles)
      warning(['Directory ', DirPathJK, ' does not have same number of pictures and gts.']);
      continue;
    end
    for i = 1:length(ImageFiles)
      ImagePath = [DirPathJK, ImageFiles(i).name];
      ImageRGB = imread(ImagePath);
      MaskPath = [DirPathJK, MaskFiles(i).name];
      ImageMask = im2bw(imread(MaskPath));
      BelongingImage = rgb2belonging(ImageRGB, 'lab', ConfigsMat);
      BelongingImage = PostProcessBelongingImage(ImageRGB, BelongingImage);
      ErrorMat = ComputeError(ImageMask, belonging2naming(BelongingImage), SubSubFolders{k});
      fprintf('Sensitivity: %0.2f Specificity %0.2f Positive predictive %0.2f Negative predictive %0.2f\n', ErrorMat);
      figurei = PlotAllChannels(ImageRGB, BelongingImage, EllipsoidsTitles, EllipsoidsRGBs, 'Colour Categorisation - Colour Planes');
      saveas(figurei, [ResultDirectory, 'res_', ImageFiles(i).name]);
    end
  end
end

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
