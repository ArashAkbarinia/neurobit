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
    mkdir(ResultDirectory);
    
    ImageFiles = dir([DirPathJK, '*.jpg']);
    for i = 1:length(ImageFiles)
      if isempty(strfind(ImageFiles(i).name, 'MASK'))
        ImagePath = [DirPathJK, ImageFiles(i).name];
        ImageRGB = imread(ImagePath);
        ImageRGB = ImageRGB + 1;
        ImageOpponent = double(applycform(ImageRGB, makecform('srgb2lab')));
        BelongingImage = AllEllipsoidsEvaluateBelonging(ImageOpponent, ColourEllipsoids);
        BelongingImage = PostProcessBelongingImage(ImageRGB, BelongingImage);
        figurei = PlotAllChannels(ImageRGB, BelongingImage, EllipsoidsTitles, EllipsoidsRGBs, 'Colour Categorisation - Colour Planes');
        saveas(figurei, [ResultDirectory, 'res_', ImageFiles(i).name]);
      end
    end
  end
end

end
