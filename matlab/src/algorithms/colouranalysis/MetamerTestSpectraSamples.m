function [CompMat, lab] = MetamerTestSpectraSamples(ColourReceptors, illuminants)

FunctionPath = mfilename('fullpath');
FunctionRelativePath = ['src', filesep, 'algorithms', filesep, 'colouranalysis', filesep, 'MetamerTestSpectraSamples'];

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

% making the illumiant and colour receptor the same size
[illuminants, ColourReceptors] = IntersectIlluminantColourReceptors(illuminants, ColourReceptors);

AllspectraPath = strrep(FunctionPath, FunctionRelativePath, [DataPath, 'AllSpectra.mat']);
AllSpectraMat = load(AllspectraPath);
AllSpectra = AllSpectraMat.AllSpectra;

% checkign the wp
if ~isfield(illuminants, 'wp')
  illuminants.wp = ComputeWhitePoint(illuminants, ColourReceptors);
end

[CompMat, LabCar] = MetamerTestIlluminantAll(AllSpectra, illuminants, ColourReceptors);
lab.car = LabCar;
lab.wp = illuminants.wp;

end

function [illuminants, ColourReceptors] = IntersectIlluminantColourReceptors(illuminants, ColourReceptors)

if size(illuminants.wavelength, 1) < size(ColourReceptors.wavelength, 1)
  [illuminants, ColourReceptors] = SmallBigIntersect(illuminants, ColourReceptors);
elseif size(illuminants.wavelength, 1) > size(ColourReceptors.wavelength, 1)
  [ColourReceptors, illuminants] = SmallBigIntersect(ColourReceptors, illuminants);
elseif illuminants.wavelength ~= ColourReceptors.wavelength
  [illuminants, ColourReceptors] = SmallBigIntersect(illuminants, ColourReceptors);
end

end

function [small, big] = SmallBigIntersect(small, big)

wavelength = interp1(small.wavelength, small.wavelength, big.wavelength);
spectra = interp1(small.wavelength, small.spectra, big.wavelength);
NumberInds = ~isnan(wavelength);

small.wavelength = wavelength(NumberInds);
small.spectra = spectra(NumberInds, :);
big.wavelength = big.wavelength(NumberInds);
big.spectra = big.spectra(NumberInds, :);

end

function [CompMat, lab] = MetamerTestIlluminantAll(AllSpectra, illuminants, ColourReceptors)

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
CompMat = ColourDifferences(lab);

end

function CompMat = ColourDifferences(lab)

nSignals = size(lab, 1);
lab = reshape(lab, nSignals, 3);

CompMat = zeros(nSignals, nSignals);

% TODO
for i = 1:nSignals
  RowI = repmat(lab(i, :), [nSignals, 1]);
  CompMat(i, :) = deltae2000(RowI, lab);
end

end

function lab = ComputeLab(ev, ew, iv, iw, cv, cw, wp)

[ev, iv, cv] = IntersectThree(ev, ew, iv, iw, cv, cw);

lab = hsi2lab(ev, iv, cv, wp);

end
