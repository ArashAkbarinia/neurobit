function MetamerDiffs = MetamerTestFosterHyperspectralImages()

FunctionPath = mfilename('fullpath');
DataSetFolder = 'data/dataset/ColourConstancyDataset/hyperspectral/';
DataSetMatPath = [DataSetFolder, 'HyperspectralImageList.mat'];
FunctionRelativePath = 'src/algorithms/colouranalysis/MetamerTestFosterHyperspectralImages';
MatFilePath = strrep(FunctionPath, ['matlab/', FunctionRelativePath], DataSetMatPath);
DataSetPath = strrep(FunctionPath, ['matlab/', FunctionRelativePath], DataSetFolder);
HyperspectralImageListMat = load(MatFilePath);

IlluminantstPath = strrep(FunctionPath, FunctionRelativePath, 'data/mats/hsi/illuminants.mat');
illuminants = load(IlluminantstPath);
d65 = illuminants.d65;

% 400 - 720 nm
inds = find(illuminants.wavelength == 400):10:find(illuminants.wavelength == 720);

FundamentalsPath = strrep(FunctionPath, FunctionRelativePath, 'data/mats/hsi/ConeSpectralSensitivity.mat');
FundamentalsMat = load(FundamentalsPath);
ConeSpectralSensitivity = FundamentalsMat.ConeSpectralSensitivity;

HyperspectralImageNames = HyperspectralImageListMat.HyperspectralImageNames;

nimages = numel(HyperspectralImageNames);
if nargin < 3
  ImageNumbers = 1:nimages;
end

MetamerDiffs = cell(nimages, 1);
ScaledSignals = cell(nimages, 1);

gap = 20;

for i = 1:nimages
  if isempty(find(ImageNumbers == i, 1))
    continue;
  end
  
  DebugImagePath = [DataSetPath, HyperspectralImageNames{i}(1:end-3), 'mat'];
  CurrentMat = load(DebugImagePath);
  
  hsi = CurrentMat.hsi;
  
  hsi = hsi(1:gap:end, 1:gap:end, :);
  [rows, cols, chns] = size(hsi);
  
  hsi = reshape(hsi, rows * cols, chns)';
  
  MetamerDiffs{i} = MetamerAnalysis(hsi, ConeSpectralSensitivity(inds, :), d65(inds));
  
  msum = sum(MetamerDiffs{i}.metamers);
  
  ScaledSignals{i} = hsi .* repmat(msum, [size(hsi, 1), 1]);
end

SumScaledSignals = 0;
for i = 1:nimages
  SumScaledSignals = SumScaledSignals + sum(ScaledSignals{i}, 2);
end

figure;
hold on;
plot(illuminants.wavelength(inds), SumScaledSignals);

end
