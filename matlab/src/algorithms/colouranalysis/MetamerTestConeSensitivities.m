function MetamerDiffs = MetamerTestConeSensitivities(InputSignals, wavelength)
%MetamerTestConeSensitivities Summary of this function goes here
%   Detailed explanation goes here

FunctionPath = mfilename('fullpath');
FunctionRelativePath = 'src/algorithms/colouranalysis/MetamerTest';

IlluminantstPath = strrep(FunctionPath, FunctionRelativePath, 'data/mats/hsi/illuminants.mat');
illuminants = load(IlluminantstPath);
d65 = illuminants.d65;

wgap = wavelength(2) - wavelength(1);
inds = find(illuminants.wavelength == wavelength(1)):wgap:find(illuminants.wavelength == wavelength(end));

FundamentalsPath = strrep(FunctionPath, FunctionRelativePath, 'data/mats/hsi/ConeSpectralSensitivity.mat');
FundamentalsMat = load(FundamentalsPath);
ConeSpectralSensitivity = FundamentalsMat.ConeSpectralSensitivity;

MetamerDiffs = MetamerAnalysisConeDifferences(InputSignals, ConeSpectralSensitivity(inds, :), d65(inds));

end
