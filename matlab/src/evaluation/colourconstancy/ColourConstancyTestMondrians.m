function ColourConstancyReport = ColourConstancyTestMondrians()
%ColourConstancyTestMondrians Summary of this function goes here
%   Detailed explanation goes here

load('C:\Users\arash\Desktop\TmpBarcelona\MatlabStuff\MondrianDatasetChannelsDiff.mat')
nimages = 1000;

cgw = zeros(nimages, 2);
agw = zeros(nimages, 2);
agwpars = {3, 1.5, 2, 5, -0.77, -0.67, 1, 1, 4, 'single', []};
cgwpars = {3, 1.5, 2, 5, -0.77, -0.67, 1, 1, 1, 'single', []};
for i = 1:nimages
  disp(num2str(i));
  CurrentImage = MondrianDataset.BiasedImages(:, :, :, i);
  [~, agwlum] = ColourConstancySurroundModulation(CurrentImage, agwpars);
%   [~, cgwlum] = ColourConstancySurroundModulation(CurrentImage, cgwpars);
  cgwlum = GaoDOCC_demo(CurrentImage);
  
  ColourConstancyReport.agw.EstiLuminances(i, :) = agwlum;
  ColourConstancyReport.cgw.EstiLuminances(i, :) = cgwlum;
  
  % calculating the angular error
  GroundtruthLuminance = MondrianDataset.illuminants(i, :);
  agw(i, 1) = AngularError(agwlum, GroundtruthLuminance);
  agw(i, 2) = ReproductionAngularError(agwlum, GroundtruthLuminance);
  cgw(i, 1) = AngularError(cgwlum, GroundtruthLuminance);
  cgw(i, 2) = ReproductionAngularError(cgwlum, GroundtruthLuminance);
end

ColourConstancyReport.cgw.AngularErrors = cgw;
ColourConstancyReport.agw.AngularErrors = agw;

end
