function [EuclideanDistances, AngularDistances, IllumNames] = EucIlluminants(IllumNames)
%EucIlluminants Summary of this function goes here
%   Detailed explanation goes here

FunctionPath = mfilename('fullpath');
[~, FunctionName, ~] = fileparts(FunctionPath);
FunctionRelativePath = ['matlab', filesep, 'src', filesep, 'algorithms', filesep, 'colouranalysis', filesep, FunctionName];

IlluminantsPath = strrep(FunctionPath, FunctionRelativePath, ['matlab', filesep, 'data', filesep, 'mats', filesep, 'hsi', filesep, 'AllIlluminantsUniformed.mat']);

IllMat = load(IlluminantsPath);
spectras = IllMat.spectras;

if nargin < 1
  IllumNames = fieldnames(spectras);
end
nIllus = numel(IllumNames);

EuclideanDistances = zeros(nIllus, nIllus);
AngularDistances = zeros(nIllus, nIllus);

for i = 1:nIllus - 1
  spectrai = spectras.(IllumNames{i}) ./ sum(spectras.(IllumNames{i}));
  for j = i + 1:nIllus
    if i == j
      continue;
    end
    spectraj = spectras.(IllumNames{j}) ./ sum(spectras.(IllumNames{j}));
    CurrentDistance = sqrt(sum((spectrai - spectraj) .^ 2, 1));
    EuclideanDistances(i, j) = CurrentDistance;
    EuclideanDistances(j, i) = CurrentDistance;
    
    CurrentAngularDistance = acos((spectrai' * spectraj) / (norm(spectrai) * norm(spectraj)));
    AngularDistances(i, j) = CurrentAngularDistance;
    AngularDistances(j, i) = CurrentAngularDistance;
  end
end

end
