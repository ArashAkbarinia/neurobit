function [AngularErrors, LuminanceDiffs, EstiLuminances] = ColourConstancyReportGreyBall(method, plotme, ImageNumbers)
%ColourConstancyReportGreyBall  applies colour constancy on Grayball data.
%   http://www.cs.sfu.ca/~colour/data/gray_ball/
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
%   EstiLuminances  the estimated luminances.
%

if nargin < 1
  method = 'opponency';
end
if nargin < 2
  plotme = false;
end

FunctionPath = mfilename('fullpath');
DataSetFolder = 'data/dataset/ColourConstancyDataset/grayball/';
DataSetMatPath = [DataSetFolder, 'GreyBallImageList.mat'];
MatFilePath = strrep(FunctionPath, 'matlab/src/evaluation/colourconstancy/ColourConstancyReportGreyBall', DataSetMatPath);
DataSetPath = strrep(FunctionPath, 'matlab/src/evaluation/colourconstancy/ColourConstancyReportGreyBall', DataSetFolder);
GreyBallImageListMat = load(MatFilePath);

GreyBallImageNames = GreyBallImageListMat.GreyBallImageNames;
GreyBallGroundtruthIlluminations = GreyBallImageListMat.GreyBallGroundtruthIlluminations;

nimages = numel(GreyBallImageNames);
if nargin < 3
  ImageNumbers = 1:nimages;
end

AngularErrors = zeros(nimages, 1);
LuminanceDiffs = zeros(nimages, 3);
EstiLuminances = zeros(nimages, 3);

parfor i = 1:nimages
  if isempty(find(ImageNumbers == i, 1))
    continue;
  end

  DebugImagePath = [DataSetPath, GreyBallImageNames{i}];
  CurrentImage = double(imread(DebugImagePath));
  CurrentImage = CurrentImage ./ ((2 ^ 8) - 1);
  
  GroundtruthLuminance = GreyBallGroundtruthIlluminations(i, :);
  [EstimatedLuminance, CurrentAngularError, CurrentLumDiff] = ColourConstancyReportAlgoithms(CurrentImage, method, GroundtruthLuminance);
  
  ColourConstancyReportPlot(CurrentImage, EstimatedLuminance, GroundtruthLuminance, CurrentAngularError, i, plotme);
  
  AngularErrors(i, :) = CurrentAngularError;
  LuminanceDiffs(i, :) = CurrentLumDiff;
  EstiLuminances(i, :) = EstimatedLuminance;
end

fprintf('Mean angular error %f\n', mean(AngularErrors));
fprintf('Median angular error %f\n', median(AngularErrors));
fprintf('Trimean angular error %f\n', TrimeanError(AngularErrors));
fprintf('Average luminance difference [%f %f %f]\n', mean(abs(LuminanceDiffs)));

end
