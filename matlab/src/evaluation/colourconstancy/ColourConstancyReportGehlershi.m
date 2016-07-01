function [AngularErrors, LuminanceDiffs, EstiLuminances] = ColourConstancyReportGehlershi(method, plotme, ImageNumbers)
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
%   EstiLuminances  the estimated luminances.
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

BlackIllumination = 129;
CoordinatesDirectory = [DataSetFolder 'ColorCheckerDatabase_MaskCoordinates/coordinates/'];

GehlershiImageNames = GehlershiImageListMat.GehlershiImageNames;
GehlershiGroundtruthIlluminations = GehlershiImageListMat.GehlershiGroundtruthIlluminations;

nimages = numel(GehlershiImageNames);
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
  
  DebugImagePath = [DataSetPath, GehlershiImageNames{i}];
  CurrentImage = double(imread(DebugImagePath));
  
  % based on http://www.cs.sfu.ca/~colour/data/process_568.m
  if i > 87   % subtract black level
    CurrentImage = max(CurrentImage - BlackIllumination, 0);
  end
  
  CoordinatesFileName = GehlershiImageNames{i};
  CoordinatesFileName = [CoordinatesFileName(1:end - 4), '_macbeth.txt'];
  
  % mask out the colorchecker within the image scene
  CoordinatesPoints = load([CoordinatesDirectory, filesep, CoordinatesFileName]);
  scale = CoordinatesPoints(1, [2, 1]) ./ [size(CurrentImage, 1) size(CurrentImage, 2)];
  MaskImage = repmat(roipoly(CurrentImage, CoordinatesPoints([2, 4, 5, 3], 1) / scale(1), CoordinatesPoints([2, 4, 5, 3], 2) / scale(2)), [1, 1, 3]);
  CurrentImage(MaskImage) = 0;
  
  CurrentImage = CurrentImage ./ ((2 ^ 12) - 1);
  
  GroundtruthLuminance = GehlershiGroundtruthIlluminations(i, :);
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
