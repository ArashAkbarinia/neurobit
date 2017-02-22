function [  ] = GroupSpectrasToMunsellChips(LabPath, DelPath, WhichIlluminans)
%GroupSpectrasToMunsellChips Summary of this function goes here
%   Detailed explanation goes here

if nargin < 3
  WhichIlluminans = [];
end

% there are the indeces of illuminants we experimented
TestedIllums = [1:2, 5:14, 20, 27];

LabList = dir([LabPath, '*.mat']);
LabList = LabList(TestedIllums);
DelList = dir([DelPath, '*.mat']);
DelList = DelList(TestedIllums);

% loading the AllSpectraUniformed
FunctionPath = mfilename('fullpath');
[~, FunctionName, ~] = fileparts(FunctionPath);
FunctionRelativePath = ['matlab', filesep, 'src', filesep, 'algorithms', filesep, 'colouranalysis', filesep, 'categories', filesep, FunctionName];

MatDataPath = ['matlab', filesep, 'data', filesep, 'mats', filesep, 'hsi', filesep];
AllSpectraMat = load(strrep(FunctionPath, FunctionRelativePath, [MatDataPath, 'AllSpectraUniformed.mat']));

% obtainnig the munsell and other indeces
MunsellInds = ExtractDatasetIndices([], AllSpectraMat.AllSpectra, {'munsell'});
OtherInds = ExtractDatasetIndices([], AllSpectraMat.AllSpectra, {'munsell'}, false);

NumMunsellEls = size(MunsellInds, 1);
NumOtherEls = size(OtherInds, 1);

nIllums = numel(LabList);

% load focal gts
load('FocalColours.mat');
FocalInds = SturgesFocalColours > 0;
FocalCategories = SturgesFocalColours(FocalInds);

LabMat = load([LabPath, 'd65.mat']);
car = LabMat.car(MunsellInds, :);
rgb = lab2rgb(reshape(car, NumMunsellEls, 1, 3), 'WhitePoint', LabMat.wp);
rgb = min(max(rgb, 0.25), 1.55);
rgb = uint8(NormaliseChannel(rgb, 0, 1, min(min(rgb)), max(max(rgb))) .* 255);
[CurrentBelonging, ~] = ColourNamingTestImage(rgb, 'ourlab', false);
CurrentBelonging = permute(CurrentBelonging, [1, 3, 2]);

FocalColours = CurrentBelonging >= 0.80;
FocalInds = sum(FocalColours, 2);

figure;
rows = round(sqrt(nIllums));
cols = ceil(sqrt(nIllums));

for i = 1:nIllums
  BreakFor = true;
  if isempty(WhichIlluminans)
    BreakFor = false;
  else
    for j = 1:numel(WhichIlluminans)
      if strcmpi(LabList(i).name(1:end - 4), WhichIlluminans{j})
        BreakFor = false;
        break;
      end
    end
  end
  
  if BreakFor
    continue;
  end
  
  LabMat = load([LabPath, LabList(i).name]);
  DelMat = load([DelPath, DelList(i).name]);
  
  DelMat.CompMat = DelMat.CompMat + DelMat.CompMat';
%   DelMat.CompMat(logical(eye(size(DelMat.CompMat, 1)))) = inf;
  
  [SmallestMunsellVal, SmallestMunsellInd] = min(DelMat.CompMat(OtherInds, MunsellInds), [], 2);
  
  CurrentFocalColours = SturgesFocalColours;
  
%   [SmallestFocalVal, SmallestFocalInd] = min(DelMat.CompMat(MunsellInds, FocalInds), [], 2);
%   SimulatedFocals = SmallestFocalVal < 4.0 & SmallestFocalVal ~= 0;
  
%   CurrentFocalColours(SimulatedFocals) = FocalCategories(SmallestFocalInd(SimulatedFocals));
%   CurrentFocalInds = CurrentFocalColours > 0;
  CurrentFocalInds = FocalInds > 0;
  
  CategoryHist = histcounts(SmallestMunsellInd, 1:NumMunsellEls + 1);
  NormalisedCategoryHist = CategoryHist ./ sum(CategoryHist(:));
  
  RatioFocalChips = sum(CurrentFocalInds) / NumMunsellEls;
  RatioSpectraFocal = sum(CategoryHist(CurrentFocalInds)) / NumOtherEls;
  
  subplot(rows, cols, i);
  bar(MunsellInds(~CurrentFocalInds), NormalisedCategoryHist(~CurrentFocalInds), 'FaceColor', 'g', 'EdgeColor', 'g');
  hold on;
  bar(MunsellInds(CurrentFocalInds), NormalisedCategoryHist(CurrentFocalInds), 'FaceColor', 'r', 'EdgeColor', 'r');
  xlim([1, NumMunsellEls]);
  title(['''', LabList(i).name(1:end - 4), ''' focal ratio ', num2str(RatioSpectraFocal / RatioFocalChips)]);
  
  fprintf('Illuminant %s\n', LabList(i).name(1:end - 4));
  fprintf('  Ratio of focal colour: %f\n', RatioFocalChips);
  fprintf('  Ratio of spectra on focal colour: %f\n', RatioSpectraFocal);
  
end

end
