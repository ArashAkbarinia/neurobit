function [CompMat, lab] = ColourDiffSpectraSamples(ColourReceptors, illuminants, OldCompMat)

FunctionPath = mfilename('fullpath');
[~, FunctionName, ~] = fileparts(FunctionPath);
FunctionRelativePath = ['src', filesep, 'algorithms', filesep, 'colouranalysis', filesep, FunctionName];

DataPath = ['data', filesep, 'mats', filesep, 'hsi', filesep];

if nargin < 1 || isempty(ColourReceptors)
  FundamentalsPath = strrep(FunctionPath, FunctionRelativePath, [DataPath, 'XyzSpectralSensitivity.mat']);
  ColourReceptorsMat = load(FundamentalsPath);
  ColourReceptors.spectra = ColourReceptorsMat.Xyz1931SpectralSensitivity;
  ColourReceptors.wavelength = ColourReceptorsMat.wavelength;
end

if nargin < 2 || isempty(illuminants)
  IlluminantstPath = strrep(FunctionPath, FunctionRelativePath, [DataPath, 'illuminants.mat']);
  IlluminantsMat = load(IlluminantstPath);
  IlluminantName = 'd65';
  illuminants.spectra = IlluminantsMat.(IlluminantName);
  illuminants.wavelength = IlluminantsMat.wavelength;
  illuminants.wp = whitepoint(IlluminantName);
end

if nargin < 3
  OldCompMat = [];
end

% making the illumiant and colour receptor the same size
[illuminants, ColourReceptors] = IntersectIlluminantColourReceptors(illuminants, ColourReceptors);

AllspectraPath = strrep(FunctionPath, FunctionRelativePath, [DataPath, 'AllSpectra.mat']);
AllSpectraMat = load(AllspectraPath);
AllSpectra = AllSpectraMat.AllSpectra;

% checkign the wp
if ~isfield(illuminants, 'wp')
  illuminants.wp = ComputeWhitePoint(illuminants, ColourReceptors);
end

[CompMat, LabCar] = MetamerTestIlluminantAll(AllSpectra, illuminants, ColourReceptors, OldCompMat);
lab.car = LabCar;
lab.wp = illuminants.wp;

end

function [CompMat, lab] = MetamerTestIlluminantAll(AllSpectra, illuminants, ColourReceptors, OldCompMat)

originals = AllSpectra.originals;
wavelengths = AllSpectra.wavelengths;

SignalNames = fieldnames(originals);
nSignals = numel(SignalNames);

lab = [];
for i = 1:nSignals
  LabVals.(SignalNames{i}) = ComputeLab(originals.(SignalNames{i}), wavelengths.(SignalNames{i}), ...
    illuminants.spectra, illuminants.wavelength, ...
    ColourReceptors.spectra, ColourReceptors.wavelength, ...
    illuminants.wp);
  lab = cat(1, lab, LabVals.(SignalNames{i}));
end

% TODO: too much memory optimise it
disp('Processing colour differences');
CompMat = ColourDifferences(lab, OldCompMat);

end

function CompMat = ColourDifferences(lab, OldCompMat)

nSignals = size(lab, 1);
lab = reshape(lab, nSignals, 3);

CompMat = zeros(nSignals, nSignals);
[rows, cols] = size(OldCompMat);
CompMat(1:rows, 1:cols) = OldCompMat;

for i = 1 + rows:nSignals
  RowI = repmat(lab(i, :), [nSignals, 1]);
  CompMat(i, :) = deltae2000(RowI, lab);
  if cols ~= 0
    CompMat(:, i) = CompMat(i, :)';
  end
end

end

function lab = ComputeLab(rs, rw, is, iw, cs, cw, wp)

reflectance.spectra = rs;
reflectance.wavelength = rw;
illuminant.spectra = is;
illuminant.wavelength = iw;
colour.spectra = cs;
colour.wavelength = cw;
lab = hsi2lab(reflectance, illuminant, colour, wp);

end
