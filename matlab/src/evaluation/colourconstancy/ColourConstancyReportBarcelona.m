function [AngularErrors, LuminanceDiffs] = ColourConstancyReportBarcelona(method, plotme, ImageNumbers)
%ColourConstancyReportBarcelona  applies colour constancy on Barcelona set.
%   Explanation  http://www.cvc.uab.es/color_calibration/
%
% inputs
%   method        name of the method to be used.
%   plotme        if true the corrected images are displayed.
%   ImageNumbers  number of images to be tested, by default all.
%
% outputs
%   AngularErrors   the angular error between estimated luminance and
%                   ground truth.
%   LuminanceDiffs  the differences between estimated luminance and ground
%                   truth.
%

if nargin < 1
  method = 'opponency';
end
if nargin < 2
  plotme = false;
end

FunctionPath = mfilename('fullpath');
DataSetFolder = 'data/dataset/ColourConstancyDataset/barcelona/';
DataSetMatPath = [DataSetFolder, 'BarcelonaImageList.mat'];
MatFilePath = strrep(FunctionPath, 'matlab/src/evaluation/colourconstancy/ColourConstancyReportBarcelona', DataSetMatPath);
DataSetPath = strrep(FunctionPath, 'matlab/src/evaluation/colourconstancy/ColourConstancyReportBarcelona', DataSetFolder);
GreyBallImageListMat = load(MatFilePath);

BarcelonaImageNames = GreyBallImageListMat.BarcelonaImageNamesMAT;
BarcelonaGroundtruthIlluminations = GreyBallImageListMat.BarcelonaGroundtruthIlluminationsRGB;

nimages = numel(BarcelonaImageNames);
if nargin < 3
  ImageNumbers = 1:nimages;
end

AngularErrors = zeros(nimages, 1);
LuminanceDiffs = zeros(nimages, 3);

for i = ImageNumbers
  %   CurrentImage = imread([DataSetPath, BarcelonaImageNames{i}]);
  CurrentImage = load([DataSetPath, BarcelonaImageNames{i}]);
  CurrentImage = CurrentImage.foveon_processed;
  CurrentImage = CurrentImage ./ max(CurrentImage(:));
  CurrentImage = uint16(CurrentImage .* ((2 ^ 16) - 1));
  %   CurrentImage = applycform(CurrentImage, makecform('xyz2srgb'));
  
  if strcmpi(method, 'opponency')
    [~, EstimatedLuminance] = ColourConstancyOpponency(CurrentImage, false);
  elseif strcmpi(method, 'grey world')
    [~, EstimatedLuminance] = ColourConstancyGreyWorld(CurrentImage);
  elseif strcmpi(method, 'hist white patch')
    [~, EstimatedLuminance] = ColourConstancyHistWhitePatch(CurrentImage);
  elseif strcmpi(method, 'white patch')
    [~, EstimatedLuminance] = ColourConstancyWhitePatch(CurrentImage);
  elseif strcmpi(method, 'local std')
    [~, EstimatedLuminance] = ColourConstancyLocalStd(CurrentImage);
  elseif strcmpi(method, 'gao')
    EstimatedLuminance = GaoDOCC_demo(CurrentImage);
  elseif strcmpi(method, 'joost')
    EstimatedLuminance = JoostColorConstancyDemo(CurrentImage);
  end
  EstimatedLuminance = EstimatedLuminance ./ max(EstimatedLuminance(:));
  EstimatedLuminance = applycform(EstimatedLuminance, makecform('xyz2srgb'));
  EstimatedLuminance = EstimatedLuminance';
  
  % normalizing the illuminant
  norm = EstimatedLuminance(1, :) + EstimatedLuminance(2, :) + EstimatedLuminance(3, :);
  
  EstimatedLuminance(1, :) = EstimatedLuminance(1, :) ./ norm;
  EstimatedLuminance(2, :) = EstimatedLuminance(2, :) ./ norm;
  EstimatedLuminance(3, :) = EstimatedLuminance(3, :) ./ norm;
  
  GroundtruthLuminance = BarcelonaGroundtruthIlluminations(i, :);
  CurrentAngularError = AngularError(EstimatedLuminance, GroundtruthLuminance);
  
  if plotme
    ColourConstantImage = MatChansMulK(CurrentImage, 1 ./ EstimatedLuminance);
    ColourConstantImage = NormaliseChannel(ColourConstantImage, [], [], [],[]);
    ColourConstantImage = uint8(ColourConstantImage .* 255);
    
    GroundTruthImage = MatChansMulK(CurrentImage, 1 ./ GroundtruthLuminance);
    GroundTruthImage = NormaliseChannel(GroundTruthImage, [], [], [],[]);
    GroundTruthImage = uint8(GroundTruthImage .* 255);
    
    figure;
    subplot(1, 3 , 1);
    imshow(CurrentImage); title(['original ', num2str(i)]);
    subplot(1, 3 , 2);
    imshow(ColourConstantImage); title(['Colour constant estimated - angular error ', num2str(CurrentAngularError)]);
    subplot(1, 3 , 3);
    imshow(GroundTruthImage); title('Colour constant groundtruth');
  end
  
  fprintf('%d - angular error %f\n', i, CurrentAngularError);
  AngularErrors(i, :) = CurrentAngularError;
  
  CurrentLumDiff = (GroundtruthLuminance ./ max(GroundtruthLuminance)) - reshape(EstimatedLuminance ./ max(EstimatedLuminance), 1, 3);
  LuminanceDiffs(i, :) = CurrentLumDiff;
end

fprintf('Average angular error mean %f\n', mean(AngularErrors));
fprintf('Average angular error median %f\n', median(AngularErrors));
fprintf('Average luminance difference [%f %f %f]\n', mean(abs(LuminanceDiffs)));

end
