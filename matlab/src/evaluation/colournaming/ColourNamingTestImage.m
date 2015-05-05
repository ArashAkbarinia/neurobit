function BelongingImage = ColourNamingTestImage(ImageRGB, method, plotme)
%ColourNamingTestImage  applies colour naming to the input image.
%
% Inputs
%   ImageRGB  the input image.
%   method    the desired method {our, joost, robert}.
%   plotme    should the results be plotted.
%
% Outputs
%   BelongingImage  the output belonging image.
%

if nargin < 2
  method = 'our';
end
if nargin < 3
  plotme = true;
end

ConfigsMat = load('lab_ellipsoid_params');
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
    [NamingImage, BelongingImage] = ColourNamingOur(ImageRGB, ConfigsMat);
  case 2
    [NamingImage, BelongingImage] = ColourNamingJoost(ImageRGB, ConfigsMat, ConversionMat);
  case 3
    [NamingImage, BelongingImage] = ColourNamingRobert(ImageRGB, ConfigsMat, ConversionMat);
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
