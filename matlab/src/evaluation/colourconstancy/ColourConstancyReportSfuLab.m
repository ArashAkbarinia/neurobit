function AngularErrors = ColourConstancyReportSfuLab(plotme, ImageNumbers)
%ColourConstancyReportSfuLab Summary of this function goes here
%   Detailed explanation goes here

if nargin < 1
  plotme = false;
end

FunctionPath = mfilename('fullpath');
DataSetFolder = 'data/dataset/ColourConstancyDataSet/sfulab/';
DataSetMatPath = [DataSetFolder, 'SfuLabImageList.mat'];
MatFilePath = strrep(FunctionPath, 'matlab/src/evaluation/colourconstancy/ColourConstancyReportSfuLab', DataSetMatPath);
SfuLabImageListMat = load(MatFilePath);

SfuLabImageNames = SfuLabImageListMat.SfuLabImageNames;
SfuGroundtruthIlluminations = SfuLabImageListMat.SfuGroundtruthIlluminations;

if nargin < 2
  nimages = numel(SfuLabImageNames);
  ImageNumbers = 1:nimages;
else
  nimages = length(ImageNumbers);
end

AngularErrors = zeros(nimages, 1);

for i = ImageNumbers
  CurrentImage = imread([DataSetFolder, SfuLabImageNames{i}, '.tif']);
  
  [~, EstimatedLuminance] = ColourConstancyOpponency(CurrentImage, false);
  %   [~, EstimatedLuminance] = ColourConstancyHistWhitePatch(CurrentImage);
  EstimatedLuminance = EstimatedLuminance';
  
  % normalizing the illuminant
  norm = EstimatedLuminance(1, :) + EstimatedLuminance(2, :) + EstimatedLuminance(3, :);
  
  EstimatedLuminance(1, :) = EstimatedLuminance(1, :) ./ norm;
  EstimatedLuminance(2, :) = EstimatedLuminance(2, :) ./ norm;
  EstimatedLuminance(3, :) = EstimatedLuminance(3, :) ./ norm;
  
  GroundtruthLuminance = SfuGroundtruthIlluminations(i, :);
  CurrentAngularError = AngularError(EstimatedLuminance, GroundtruthLuminance);
  
  if plotme
    ColourConstantImage = MatChansMulK(CurrentImage, 1 ./ EstimatedLuminance);
    ColourConstantImage = NormaliseChannel(ColourConstantImage, [], [], [],[]);
    
    ColourConstantImage = uint8(ColourConstantImage .* 255);
    figure;
    subplot(1, 3 , 1);
    imshow(CurrentImage); title('original');
    subplot(1, 3 , 2);
    imshow(ColourConstantImage); title('Colour constant estimated');
    subplot(1, 3 , 3);
    imshow(ColourConstantImage); title('Colour constant groundtruth');
  end
  
  fprintf('%d - angular error %f\n', i, roundn(CurrentAngularError, -1));
  AngularErrors(i, :) = CurrentAngularError;
end


fprintf('Average angular error %f\n', mean(AngularErrors));

end
