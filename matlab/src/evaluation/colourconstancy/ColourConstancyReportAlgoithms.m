function [EstimatedLuminance, CurrentAngularError, CurrentLumDiff] = ColourConstancyReportAlgoithms(CurrentImage, method, GroundtruthLuminance, isxyz)
%ColourConstancyReportAlgoithms  estimatied luminance and calculate error.
%
% inputs
%   CurrentImage          the image to be processed.
%   method                desired method.
%   GroundtruthLuminance  the luminance of groundtruth.
%   isxyz                 if the image is in XYZ space, default false.
%
% outputs
%   EstimatedLuminance    estimated luminance of the selected method.
%   CurrentAngularError   the angular error between groundtruth and
%                         estimated luminance.
%

if nargin < 4 || isempty(isxyz)
  isxyz = false;
end

EstimatedLuminance = ColourConstancySwitchAlgorithms(CurrentImage, method, isxyz);

% normalising the groundtruth
GroundtruthNorm = sum(GroundtruthLuminance(:));
GroundtruthLuminance = GroundtruthLuminance ./ GroundtruthNorm;

% calculating the angular error
CurrentAngularError = AngularError(EstimatedLuminance, GroundtruthLuminance);

CurrentLumDiff = (GroundtruthLuminance ./ max(GroundtruthLuminance)) - reshape(EstimatedLuminance ./ max(EstimatedLuminance), 1, 3);

end
