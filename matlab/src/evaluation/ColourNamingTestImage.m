function BelongingImage = ColourNamingTestImage(ImageRGB, method, plotme)

if nargin < 3
  method = 'our';
  plotme = 1;
end

ConfigsMat = load('lab_ellipsoid_params_new');
EllipsoidsTitles = ConfigsMat.RGBTitles;
EllipsoidsRGBs = name2rgb(EllipsoidsTitles);
if strcmpi(method, 'our')
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

switch MethodNumber
  case 1
    [NamingImage, BelongingImage] = ApplyOurMethod(ImageRGB, ConfigsMat);
  case 2
    [NamingImage, BelongingImage] = ApplyJoostMethod(ImageRGB, ConfigsMat, ConversionMat);
  case 3
    [NamingImage, BelongingImage] = ApplyRobertMethod(ImageRGB, ConfigsMat, ConversionMat);
end

% plotting
if plotme
  PlotAllChannels(ImageRGB, BelongingImage, EllipsoidsTitles, EllipsoidsRGBs, 'Colour Categorisation - Colour Planes');
  
  figure('NumberTitle', 'Off', 'Name', [method, ' Colour Naming']);
  subplot(1, 2, 1);
  imshow(uint8(ImageRGB));
  subplot(1, 2, 2);
  imshow(ColourLabelImage(NamingImage));
end

end

function [NamingImage, BelongingImage] = ApplyOurMethod(ImageRGB, ConfigsMat)

BelongingImage = rgb2belonging(ImageRGB, 'lab', ConfigsMat);
BelongingImage = PostProcessBelongingImage(ImageRGB, BelongingImage);
NamingImage = belonging2naming(BelongingImage, true);

end

function [NamingImage, BelongingImage] = ApplyJoostMethod(ImageRGB, ConfigsMat, ConversionMat)

ImageRGB = double(ImageRGB);
NamingImage = im2c(ImageRGB, ConfigsMat, 0);

[rows, cols, ~] = size(ImageRGB);
BelongingImage = zeros(rows, cols, 11);
NamingImageTmp = NamingImage;
for i = 1:11
  BelongingImage(:, :, ConversionMat(i)) = im2c(ImageRGB, ConfigsMat, i);
  NamingImage(NamingImageTmp == i) = ConversionMat(i);
end

end

function [NamingImage, BelongingImage] = ApplyRobertMethod(ImageRGB, ConfigsMat, ConversionMat)

ImageRGB = double(ImageRGB);
[~, NamingImage, BelongingImage] = ImColorNamingTSELab(ImageRGB, ConfigsMat.ParFileName1, ConfigsMat.ParFileName2, ConfigsMat.ParFileName3);

NamingImageTmp = NamingImage;
BelongingImageTmp = BelongingImage;
for i = 1:11
  BelongingImage(:, :, ConversionMat(i)) = BelongingImageTmp(:, :, i);
  NamingImage(NamingImageTmp == i) = ConversionMat(i);
end

end
