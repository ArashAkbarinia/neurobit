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

AngularErrors = zeros(nimages, 2);
LuminanceDiffs = zeros(nimages, 3);

parfor i = 1:nimages
  if isempty(find(ImageNumbers == i, 1))
    continue;
  end
  
  %   CurrentImage = imread([DataSetPath, BarcelonaImageNames{i}]);
  CurrentImage = load([DataSetPath, BarcelonaImageNames{i}]);
  CurrentImage = CurrentImage.foveon_processed;
  CurrentImage = CurrentImage ./ max(CurrentImage(:));
  %   CurrentImage = uint16(CurrentImage .* ((2 ^ 16) - 1));
  %   CurrentImage = applycform(CurrentImage, makecform('xyz2srgb'));
  
  GroundtruthLuminance = BarcelonaGroundtruthIlluminations(i, :);
  [EstimatedLuminance, CurrentAngularError, CurrentLumDiff] = ColourConstancyReportAlgoithms(CurrentImage, method, GroundtruthLuminance, true);
  
  ColourConstancyReportPlot(CurrentImage, EstimatedLuminance, GroundtruthLuminance, CurrentAngularError, i, plotme);
  
  AngularErrors(i, :) = CurrentAngularError;
  LuminanceDiffs(i, :) = CurrentLumDiff;
end

fprintf('Mean angular error (recovery) %f (reproduction) %f\n', mean(AngularErrors));
fprintf('Median angular error (recovery) %f (reproduction) %f\n', median(AngularErrors));
fprintf('Trimean angular error (recovery) %f (reproduction) %f\n', TrimeanError(AngularErrors));
fprintf('Average luminance difference [%f %f %f]\n', mean(abs(LuminanceDiffs)));

end
