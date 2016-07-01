function [AngularErrors, LuminanceDiffs, EstiLuminances] = ColourConstancyReportSfuLab(method, plotme, ImageNumbers)
%ColourConstancyReportSfuLab  applies colour constancy on SFU Lab dataset.
%   http://www.cs.sfu.ca/~colour/data/colour_constancy_test_images/index.html
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
DataSetFolder = 'data/dataset/ColourConstancyDataset/sfulab/';
DataSetMatPath = [DataSetFolder, 'SfuLabImageList.mat'];
MatFilePath = strrep(FunctionPath, 'matlab/src/evaluation/colourconstancy/ColourConstancyReportSfuLab', DataSetMatPath);
DataSetPath = strrep(FunctionPath, 'matlab/src/evaluation/colourconstancy/ColourConstancyReportSfuLab', DataSetFolder);
SfuLabImageListMat = load(MatFilePath);

SfuLabImageNames = SfuLabImageListMat.SfuLabImageNames;
SfuGroundtruthIlluminations = SfuLabImageListMat.SfuGroundtruthIlluminations;

nimages = numel(SfuLabImageNames);
if nargin < 3
  ImageNumbers = 1:nimages;
end

AngularErrors = zeros(nimages, 2);
LuminanceDiffs = zeros(nimages, 3);
EstiLuminances = zeros(nimages, 3);

parfor i = 1:nimages
  if isempty(find(ImageNumbers == i, 1))
    continue;
  end
  
  DebugImagePath = [DataSetPath, SfuLabImageNames{i}, '.tif'];
  CurrentImage = double(imread(DebugImagePath));
  CurrentImage = CurrentImage ./ ((2 ^ 8) - 1);
  
  GroundtruthLuminance = SfuGroundtruthIlluminations(i, :);
  [EstimatedLuminance, CurrentAngularError, CurrentLumDiff] = ColourConstancyReportAlgoithms(CurrentImage, DebugImagePath, method, GroundtruthLuminance);
  
  ColourConstancyReportPlot(CurrentImage, EstimatedLuminance, GroundtruthLuminance, CurrentAngularError, i, plotme);
  
  AngularErrors(i, :) = CurrentAngularError;
  LuminanceDiffs(i, :) = CurrentLumDiff;
  EstiLuminances(i, :) = EstimatedLuminance;
end

fprintf('Mean angular error (recovery) %f (reproduction) %f\n', mean(AngularErrors));
fprintf('Median angular error (recovery) %f (reproduction) %f\n', median(AngularErrors));
fprintf('Trimean angular error (recovery) %f (reproduction) %f\n', TrimeanError(AngularErrors));
fprintf('Average luminance difference [%f %f %f]\n', mean(abs(LuminanceDiffs)));

end
