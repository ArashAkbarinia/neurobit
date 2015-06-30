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

parfor i = ImageNumbers
  CurrentImage = double(imread([DataSetPath, GehlershiImageNames{i}]));
  CurrentImage = CurrentImage ./ ((2 ^ 16) - 1);
  
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
  EstimatedLuminance = EstimatedLuminance';
  
  % normalising the illuminant
  EstimatedNorm = sum(EstimatedLuminance(:));
  EstimatedLuminance = EstimatedLuminance ./ EstimatedNorm;
  
  GroundtruthLuminance = GehlershiGroundtruthIlluminations(i, :);
  % normalising the groundtruth
  GroundtruthNorm = sum(GroundtruthLuminance(:));
  GroundtruthLuminance = GroundtruthLuminance ./ GroundtruthNorm;
  
  % calculating the angular error
  CurrentAngularError = AngularError(EstimatedLuminance, GroundtruthLuminance);
  
  if plotme
    ColourConstantImage = MatChansMulK(CurrentImage, 1 ./ EstimatedLuminance);
    ColourConstantImage = ColourConstantImage ./ max(ColourConstantImage(:));
    ColourConstantImage = uint8(ColourConstantImage .* 255);
    
    GroundTruthImage = MatChansMulK(CurrentImage, 1 ./ GroundtruthLuminance);
    GroundTruthImage = GroundTruthImage ./ max(GroundTruthImage(:));
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
