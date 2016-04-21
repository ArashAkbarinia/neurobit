function [AngularErrors, LuminanceDiffs, EstiLuminances] = ColourConstancyReportMirf(method, RealWorldFlag, plotme, ImageNumbers)
%ColourConstancyReportMirf  applies colour constancy on MIRF dataset.
%   https://www5.cs.fau.de/research/data/two-illuminant-dataset-with-computed-ground-truth/
%
% inputs
%   method         name of the method to be used.
%   RealWorldFlag  flag for laboratory or real wolrd images.
%   plotme         if true the corrected images are displayed.
%   ImageNumbers   number of images to be tested, by default all.
%
% outputs
%   AngularErrors   the angular error between estimated luminance and
%                   ground truth.
%   LuminanceDiffs  the differences between estimated luminance and ground
%                   truth.
%   EstiLuminances  the estimated luminances.
%

if nargin < 1
  method = 'nothing';
end
if nargin < 2
  RealWorldFlag = false;
end
if nargin < 3
  plotme = false;
end

FunctionPath = mfilename('fullpath');
DataSetFolder = 'data/dataset/ColourConstancyDataset/mirf/';
DataSetPath = strrep(FunctionPath, 'matlab/src/evaluation/colourconstancy/ColourConstancyReportMirf', DataSetFolder);
if RealWorldFlag
  DataSetMatPath = [DataSetFolder, 'MirfRealImageList.mat'];
  pathImages = [DataSetPath, '/realworld/img/'];
  pathGT = [DataSetPath, '/realworld/groundtruth/'];
  pathMasks = [DataSetPath, '/realworld/masks/'];
else
  DataSetMatPath = [DataSetFolder, 'MirfLabImageList.mat'];
  pathImages = [DataSetPath, '/lab/img/'];
  pathGT = [DataSetPath, '/lab/groundtruth/'];
  pathMasks = [DataSetPath, '/lab/masks/'];
end
MatFilePath = strrep(FunctionPath, 'matlab/src/evaluation/colourconstancy/ColourConstancyReportMirf', DataSetMatPath);

MirfImageListMat = load(MatFilePath);
ImageNames = MirfImageListMat.image_names;

nimages = size(ImageNames, 2);
if nargin < 4
  ImageNumbers = 1:nimages;
end

AngularErrors = zeros(nimages, 1);
LuminanceDiffs = cell(nimages, 1);
EstiLuminances = cell(nimages, 1);

parfor i = 1:nimages
  if isempty(find(ImageNumbers == i, 1))
    continue;
  end
  
  CurrentImage = double(imread([pathImages, ImageNames{i}, '.png']));
  GroundTruthImage = double(imread([pathGT, ImageNames{i}, '.png']));
  MaskImage = double(imread([pathMasks, ImageNames{i}, '.png']));
  
  CurrentImage = CurrentImage ./ ((2 ^ 14) - 1);
  
  EstimatedLuminanceI = ColourConstancySwitchAlgorithms(CurrentImage, [], method, false);
  if length(EstimatedLuminanceI) == 3
    lumr = EstimatedLuminanceI(1);
    lumg = EstimatedLuminanceI(2);
    lumb = EstimatedLuminanceI(3);
    EstimatedLuminanceRep = repmat(reshape([lumr, lumg, lumb], 1, 1, 3), size(GroundTruthImage, 1), size(GroundTruthImage, 2));
  else
    EstimatedLuminanceRep = EstimatedLuminanceI;
  end
  EstiLuminances{i} = EstimatedLuminanceRep;
  LuminanceDiffs{i} = GroundTruthImage .* repmat(MaskImage, [1, 1, 3]) - EstimatedLuminanceRep;
  
  adist = PixelAngularError(GroundTruthImage .* repmat(MaskImage, [1, 1, 3]), EstimatedLuminanceRep);
  % error in degrees
  AngularErrors(i) = mean(adist) / pi * 180;
  
  %   ColourConstancyReportPlot(CurrentImage, EstimatedLuminance, GroundtruthLuminance, CurrentAngularError, i, plotme);
end

fprintf('Average angular error mean %f\n', mean(AngularErrors));
fprintf('Average angular error median %f\n', median(AngularErrors));

end
