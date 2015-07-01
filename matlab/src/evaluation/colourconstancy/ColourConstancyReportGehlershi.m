function [AngularErrors, LuminanceDiffs] = ColourConstancyReportGehlershi(method, plotme, ImageNumbers)
%ColourConstancyReportGehlershi  applies colour constancy on Gehler-Shi.
%   http://www.cs.sfu.ca/~colour/data/shi_gehler/
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
DataSetFolder = 'data/dataset/ColourConstancyDataset/gehlershi/';
DataSetMatPath = [DataSetFolder, 'GehlershiImageList.mat'];
MatFilePath = strrep(FunctionPath, 'matlab/src/evaluation/colourconstancy/ColourConstancyReportGehlershi', DataSetMatPath);
DataSetPath = strrep(FunctionPath, 'matlab/src/evaluation/colourconstancy/ColourConstancyReportGehlershi', DataSetFolder);
GehlershiImageListMat = load(MatFilePath);

GehlershiImageNames = GehlershiImageListMat.GehlershiImageNames;
GehlershiGroundtruthIlluminations = GehlershiImageListMat.GehlershiGroundtruthIlluminations;

nimages = numel(GehlershiImageNames);
if nargin < 3
  ImageNumbers = 1:nimages;
end

AngularErrors = zeros(nimages, 1);
LuminanceDiffs = zeros(nimages, 3);

parfor i = 1:nimages
  if isempty(find(ImageNumbers == i, 1))
    continue;
  end
  
  CurrentImage = double(imread([DataSetPath, GehlershiImageNames{i}]));
  CurrentImage = CurrentImage ./ max(CurrentImage(:)); %((2 ^ 16) - 1);
  
  GroundtruthLuminance = GehlershiGroundtruthIlluminations(i, :);
  [EstimatedLuminance, CurrentAngularError, CurrentLumDiff] = ColourConstancyReportAlgoithms(CurrentImage, method, GroundtruthLuminance);
  
  ColourConstancyReportPlot(CurrentImage, EstimatedLuminance, GroundtruthLuminance, CurrentAngularError, i, plotme);
  
  AngularErrors(i, :) = CurrentAngularError;
  LuminanceDiffs(i, :) = CurrentLumDiff;
end

fprintf('Average angular error mean %f\n', mean(AngularErrors));
fprintf('Average angular error median %f\n', median(AngularErrors));
fprintf('Average luminance difference [%f %f %f]\n', mean(abs(LuminanceDiffs)));

end
