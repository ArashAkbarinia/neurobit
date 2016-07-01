function [AngularErrors, LuminanceDiffs, EstiLuminances] = ColourConstancyReportHyperspectral(method, plotme, ImageNumbers)
%ColourConstancyReportSfuLab  applies colour constancy on SFU Lab dataset.
%   http://personalpages.manchester.ac.uk/staff/d.h.foster/Local_Illumination_HSIs/Local_Illumination_HSIs_2015.html
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
DataSetFolder = 'data/dataset/ColourConstancyDataset/hyperspectral/';
DataSetMatPath = [DataSetFolder, 'HyperspectralImageList.mat'];
MatFilePath = strrep(FunctionPath, 'matlab/src/evaluation/colourconstancy/ColourConstancyReportHyperspectral', DataSetMatPath);
DataSetPath = strrep(FunctionPath, 'matlab/src/evaluation/colourconstancy/ColourConstancyReportHyperspectral', DataSetFolder);
HyperspectralImageListMat = load(MatFilePath);

HyperspectralImageNames = HyperspectralImageListMat.HyperspectralImageNames;
HyperspectralGroundtruthIlluminations = HyperspectralImageListMat.HyperspectralGroundtruthIlluminations;

nimages = numel(HyperspectralImageNames);
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
  
  DebugImagePath = [DataSetPath, HyperspectralImageNames{i}];
  CurrentImage = double(imread(DebugImagePath));
  CurrentImage = CurrentImage ./ ((2 ^ 8) - 1);
  
  GroundtruthLuminance = HyperspectralGroundtruthIlluminations(i, :);
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
