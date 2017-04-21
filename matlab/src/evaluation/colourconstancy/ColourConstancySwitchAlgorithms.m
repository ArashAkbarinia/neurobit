function EstimatedLuminance = ColourConstancySwitchAlgorithms(CurrentImage, DebugImagePath, params, isxyz)
%ColourConstancySwitchAlgorithms  estimatied luminance of an algorithm.
%
% inputs
%   CurrentImage          the image to be processed.
%   DebugImagePath        the path to the image, for debugging proposes.
%   params                desired method and its parameters.
%   isxyz                 if the image is in XYZ space, default false.
%
% outputs
%   EstimatedLuminance    estimated luminance of the selected method.
%

if nargin < 3 || isempty(isxyz)
  isxyz = false;
end

method = params{1};

if strcmpi(method, 'nothing')
  EstimatedLuminance = [1, 1, 1];
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
elseif strcmpi(method, 'colour edge')
  [~, EstimatedLuminance] = ColourConstancyColourEdge(CurrentImage);
elseif strcmpi(method, 'gao')
  EstimatedLuminance = GaoDOCC_demo(CurrentImage, params{2}, params{3}, params{4});
elseif strcmpi(method, 'joost')
  EstimatedLuminance = JoostColorConstancyDemo(CurrentImage);
elseif strcmpi(method, 'gamut mapping')
  EstimatedLuminance = GamutMappingColourConstancy(CurrentImage);
elseif strcmpi(method, 'bayesian')
  EstimatedLuminance = BayesianColourConstancy(CurrentImage);
else
  method{end + 1} = DebugImagePath;
  [~, EstimatedLuminance] = ColourConstancySurroundModulation(CurrentImage, method);
end
if isxyz
  EstimatedLuminance = EstimatedLuminance ./ max(EstimatedLuminance(:));
  EstimatedLuminance = applycform(EstimatedLuminance, makecform('xyz2srgb'));
end

if size(EstimatedLuminance, 1) == 1
  EstimatedLuminance = EstimatedLuminance';
end

% normalising the illuminant
EstimatedNorm = sum(EstimatedLuminance(:));
EstimatedLuminance = EstimatedLuminance ./ EstimatedNorm;

end
