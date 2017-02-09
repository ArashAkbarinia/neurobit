function [u, s, v] = PcaIlluminants(IlluminantNames, plotme)
%PcaIlluminants Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
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

TestedIllums = zeros(nIllus, 300);
for i = 1:nIllus
  TestedIllums(i, :) = spectras.(IlluminantNames{i}) ./  sum(spectras.(IlluminantNames{i}));
end

% MeanVal = mean(TestedIllums, 1);

[u, s, v] = svd(TestedIllums, 0);

if plotme
  figure;
  hold on
  for i = 1:3
    plot(wavelengths.(IlluminantNames{i}), v(:, i)', 'DisplayName', ['Comp-', num2str(i)]);
  end
  
  legend('show');
end

end
