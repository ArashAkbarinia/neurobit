function [u, s, v] = PcaIlluminants(IlluminantNames, nComps, plotme)
%PcaIlluminants Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
  nComps = 3;
end
if nargin < 3
  plotme = true;
end

FunctionPath = mfilename('fullpath');
[~, FunctionName, ~] = fileparts(FunctionPath);
FunctionRelativePath = ['matlab', filesep, 'src', filesep, 'algorithms', filesep, 'colouranalysis', filesep, FunctionName];

IlluminantsPath = strrep(FunctionPath, FunctionRelativePath, ['matlab', filesep, 'data', filesep, 'mats', filesep, 'hsi', filesep, 'AllIlluminantsUniformed.mat']);

IllMat = load(IlluminantsPath);
spectras = IllMat.spectras;
wavelengths = IllMat.wavelengths;

nIllus = numel(IlluminantNames);

TestedIllums = zeros(nIllus, size(wavelengths.(IlluminantNames{1}), 2));
for i = 1:nIllus
  TestedIllums(i, :) = spectras.(IlluminantNames{i}) ./  sum(spectras.(IlluminantNames{i}));
end

% MeanVal = mean(TestedIllums, 1);

[u, s, v] = svd(TestedIllums, 0);

nComps = min(size(v, 2), nComps);

if plotme
  figure;
  hold on
  for i = 1:nComps
    plot(wavelengths.(IlluminantNames{1}), v(:, i)', 'DisplayName', ['Comp-', num2str(i)]);
  end
  
  legend('show');
end

end
