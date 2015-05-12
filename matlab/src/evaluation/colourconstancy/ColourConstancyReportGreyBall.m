function AngularErrors = ColourConstancyReportGreyBall(method, plotme, ImageNumbers)
%COLOURCONSTANCYREPORTGREYBALL Summary of this function goes here
%   Detailed explanation goes here

if nargin < 1
  method = 'opponency';
end
if nargin < 2
  plotme = false;
end

FunctionPath = mfilename('fullpath');
DataSetFolder = 'data/dataset/ColourConstancyDataSet/grayball/';
DataSetMatPath = [DataSetFolder, 'GreyBallImageList.mat'];
MatFilePath = strrep(FunctionPath, 'matlab/src/evaluation/colourconstancy/ColourConstancyReportGreyBall', DataSetMatPath);
GreyBallImageListMat = load(MatFilePath);

GreyBallImageNames = GreyBallImageListMat.GreyBallImageNames;
GreyBallGroundtruthIlluminations = GreyBallImageListMat.GreyBallGroundtruthIlluminations;

nimages = numel(GreyBallImageNames);
if nargin < 3
  ImageNumbers = 1:nimages;
end

AngularErrors = zeros(nimages, 1);

for i = ImageNumbers
  CurrentImage = imread([DataSetFolder, GreyBallImageNames{i}]);
  
  if strcmpi(method, 'opponency')
    [~, EstimatedLuminance] = ColourConstancyOpponency(CurrentImage, false);
  elseif strcmpi(method, 'grey world')
    [~, EstimatedLuminance] = ColourConstancyGreyWorld(CurrentImage);
  elseif strcmpi(method, 'hist white patch')
    [~, EstimatedLuminance] = ColourConstancyHistWhitePatch(CurrentImage);
  end
  EstimatedLuminance = EstimatedLuminance';
  
  % normalizing the illuminant
  norm = EstimatedLuminance(1, :) + EstimatedLuminance(2, :) + EstimatedLuminance(3, :);
  
  EstimatedLuminance(1, :) = EstimatedLuminance(1, :) ./ norm;
  EstimatedLuminance(2, :) = EstimatedLuminance(2, :) ./ norm;
  EstimatedLuminance(3, :) = EstimatedLuminance(3, :) ./ norm;
  
  GroundtruthLuminance = GreyBallGroundtruthIlluminations(i, :);
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
