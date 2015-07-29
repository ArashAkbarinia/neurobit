function AngularErrors = ColourConstancyReportMirf(method, RealWorldFlag, plotme, ImageNumbers)
%ColourConstancyReportMirf Summary of this function goes here
%   Detailed explanation goes here


if nargin < 1
  method = 'nothing';
end
if nargin < 2
  plotme = false;
end
if nargin < 4
  RealWorldFlag=false;
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
image_names = MirfImageListMat.image_names;

% if nargin < 3
%   ImageNumbers = 1:nimages;
% end

nimages=size(image_names, 2);  % number of images
AngularErrors = zeros(nimages, 1);

parfor i = 1:nimages  % loop over images;
  CurrentImage = double(imread([pathImages, image_names{i}, '.png']));
  GroundTruthImage = double(imread([pathGT, image_names{i}, '.png']));
  MaskImage = double(imread([pathMasks, image_names{i}, '.png']));
  
  CurrentImage = CurrentImage ./ ((2 ^ 14) - 1);
  
  EstimatedLuminance = ColourConstancySwitchAlgorithms(CurrentImage, method, false);
  lumr = EstimatedLuminance(1);
  lumg = EstimatedLuminance(2);
  lumb = EstimatedLuminance(3);
    
  EstimatedLuminanceRep = repmat(reshape([lumr, lumg, lumb], 1, 1, 3), size(GroundTruthImage, 1), size(GroundTruthImage, 2));
  adist = PixelAngularError(GroundTruthImage .* repmat(MaskImage, [1, 1, 3]), EstimatedLuminanceRep);
  AngularErrors(i) = mean(adist) / pi * 180; % error in degrees
  
%   ColourConstancyReportPlot(CurrentImage, EstimatedLuminance, GroundtruthLuminance, CurrentAngularError, i, plotme);
end

fprintf('Average angular error mean %f\n', mean(AngularErrors));
fprintf('Average angular error median %f\n', median(AngularErrors));

end
