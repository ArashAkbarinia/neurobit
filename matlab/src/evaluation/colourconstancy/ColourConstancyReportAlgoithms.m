function [EstimatedLuminance, CurrentAngularError, CurrentLumDiff] = ColourConstancyReportAlgoithms(CurrentImage, method, GroundtruthLuminance)
%ColourConstancyReportAlgoithms  estimatied luminance of am algorithm.
%
% inputs
%   CurrentImage          the image to be processed.
%   method                desired method.
%   GroundtruthLuminance  the luminance of groundtruth.
%
% outputs
%   EstimatedLuminance    estimated luminance of the selected method.
%   CurrentAngularError   the angular error between groundtruth and
%                         estimated luminance.
%

if strcmpi(method, 'opponency')
  [~, EstimatedLuminance] = ColourConstancyOpponency(CurrentImage, false);
elseif strcmpi(method, 'grey world')
  [~, EstimatedLuminance] = ColourConstancyGreyWorld(CurrentImage);
elseif strcmpi(method, 'hist white patch')
  [~, EstimatedLuminance] = ColourConstancyHistWhitePatch(CurrentImage);
elseif strcmpi(method, 'hist white patch local std')
  [~, EstimatedLuminance] = ColourConstancyHistWhitePatch(CurrentImage, -1);
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

% normalising the groundtruth
GroundtruthNorm = sum(GroundtruthLuminance(:));
GroundtruthLuminance = GroundtruthLuminance ./ GroundtruthNorm;

% calculating the angular error
CurrentAngularError = AngularError(EstimatedLuminance, GroundtruthLuminance);

CurrentLumDiff = (GroundtruthLuminance ./ max(GroundtruthLuminance)) - reshape(EstimatedLuminance ./ max(EstimatedLuminance), 1, 3);

end
