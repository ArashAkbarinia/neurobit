function [ ] = ColourConstancyReportPlot(CurrentImage, EstimatedLuminance, GroundtruthLuminance, CurrentAngularError, ImageIndex, plotme)
%ColourConstancyReportPlot  plottig results of colour constancy reports.
%
% inputs
%   CurrentImage          the original image.
%   EstimatedLuminance    the estimated luminance of an algorithm.
%   GroundtruthLuminance  the groundtruth luminance.
%   CurrentAngularError   the angular error.
%   ImageIndex            index of the image.
%   plotme                if true it plots the results
%
% outputs
%

if plotme
  EstimatedLuminance = EstimatedLuminance ./ sum(EstimatedLuminance(:));
  GroundtruthLuminance = GroundtruthLuminance ./ sum(GroundtruthLuminance(:));
  
  ColourConstantImage = MatChansMulK(CurrentImage, 1 ./ EstimatedLuminance);
  ColourConstantImage = ColourConstantImage ./ max(ColourConstantImage(:));
  ColourConstantImage = uint8(ColourConstantImage .* 255);
  
  GroundTruthImage = MatChansMulK(CurrentImage, 1 ./ GroundtruthLuminance);
  GroundTruthImage = GroundTruthImage ./ max(GroundTruthImage(:));
  GroundTruthImage = uint8(GroundTruthImage .* 255);
  
  figure;
  subplot(1, 3 , 1);
  imshow(CurrentImage); title(['original ', num2str(ImageIndex)]);
  subplot(1, 3 , 2);
  imshow(ColourConstantImage); title(['Colour constant estimated - angular error ', num2str(CurrentAngularError)]);
  subplot(1, 3 , 3);
  imshow(GroundTruthImage); title('Colour constant groundtruth');
end

fprintf('%d - angular error %f\n', ImageIndex, CurrentAngularError);

end
