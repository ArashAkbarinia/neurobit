function [UniqueSignals, wavelength] = ExtractUniqueSignalsFosterHyperspectral(SignalThreshold)

if nargin < 1
  SignalThreshold = 1e-1;
end

FunctionPath = mfilename('fullpath');
DataSetFolder = 'data/dataset/ColourConstancyDataset/hyperspectral/';
DataSetMatPath = [DataSetFolder, 'HyperspectralImageList.mat'];
FunctionRelativePath = 'src/algorithms/colouranalysis/ExtractUniqueSignalsFosterHyperspectral';
MatFilePath = strrep(FunctionPath, ['matlab/', FunctionRelativePath], DataSetMatPath);
DataSetPath = strrep(FunctionPath, ['matlab/', FunctionRelativePath], DataSetFolder);
HyperspectralImageListMat = load(MatFilePath);

% 400 - 720 nm
wavelength = 400:10:720;

HyperspectralImageNames = HyperspectralImageListMat.HyperspectralImageNames;

nimages = numel(HyperspectralImageNames);

UniqueSignals = [];
for i = 1:nimages
  DebugImagePath = [DataSetPath, HyperspectralImageNames{i}(1:end-3), 'mat'];
  CurrentMat = load(DebugImagePath);
  
  hsi = CurrentMat.hsi;
  
  [rows, cols, chns] = size(hsi);
  
  hsi = reshape(hsi, rows * cols, chns);
  
  IntHsi = round(hsi .* (1 / SignalThreshold));
  
  [~, UniqueInds, ~] = unique(IntHsi, 'rows');
  
  UniqueSignals = [UniqueSignals; hsi(UniqueInds, :)]; %#ok
end

end
