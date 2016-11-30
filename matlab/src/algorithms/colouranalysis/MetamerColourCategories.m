function AllSpectraColourCategories = MetamerColourCategories( ColourReceptors, illuminants, ColourCategorisationModel )
%MetamerColourCategories Summary of this function goes here
%   Detailed explanation goes here

FunctionPath = mfilename('fullpath');
FunctionRelativePath = 'src/algorithms/colouranalysis/MetamerColourCategories';

FundamentalsPath = strrep(FunctionPath, FunctionRelativePath, 'data/mats/hsi/');

if nargin < 1 || isempty(ColourReceptors)
  ColourReceptorsMat = load([FundamentalsPath, 'XyzSpectralSensitivity.mat']);
  ColourReceptors.spectra = ColourReceptorsMat.Xyz1931SpectralSensitivity;
  ColourReceptors.wavelength = ColourReceptorsMat.wavelength;
end

if nargin < 2 || isempty(illuminants)
  IlluminantstPath = strrep(FunctionPath, FunctionRelativePath, 'data/mats/hsi/illuminants.mat');
  IlluminantsMat = load(IlluminantstPath);
  IlluminantName = 'd65';
  illuminants.spectra = IlluminantsMat.(IlluminantName);
  illuminants.wavelength = IlluminantsMat.wavelength;
  illuminants.wp = whitepoint(IlluminantName);
end

if nargin < 3 || isempty(ColourCategorisationModel)
  ColourCategorisationModel = 'ourlab';
end

% making the illumiant and colour receptor the same size
[illuminants, ColourReceptors] = IntersectIlluminantColourReceptors(illuminants, ColourReceptors);

AllSpectra = ReadSpectraData();

% checkign the wp
if ~isfield(illuminants, 'wp')
  illuminants.wp = ComputeWhitePoint(illuminants, ColourReceptors);
end

AllSpectraColourCategories = ColourCategoryEachSpectra(AllSpectra, illuminants, ColourReceptors,ColourCategorisationModel);

end

function [illuminants, ColourReceptors] = IntersectIlluminantColourReceptors(illuminants, ColourReceptors)

if size(illuminants.wavelength, 1) ~= size(ColourReceptors.wavelength, 1) || illuminants.wavelength ~= ColourReceptors.wavelength
  [~, ia, ib] = intersect(illuminants.wavelength, ColourReceptors.wavelength);
  illuminants.wavelength = illuminants.wavelength(ia');
  illuminants.spectra = illuminants.spectra(ia');
  ColourReceptors.wavelength = ColourReceptors.wavelength(ib');
  ColourReceptors.spectra = ColourReceptors.spectra(ib', :);
end

end

function ColourNames = ColourCategoryEachSpectra(AllSpectra, illuminants, ColourReceptors, ColourCategorisationModel)

originals = AllSpectra.originals;
wavelengths = AllSpectra.wavelengths;

SignalNames = fieldnames(originals);
nSignals = numel(SignalNames);

ColourNames = [];
for i = 1:nSignals
  lab = ComputeLab(originals.(SignalNames{i}), wavelengths.(SignalNames{i}), ...
    illuminants.spectra, illuminants.wavelength, ...
    ColourReceptors.spectra, ColourReceptors.wavelength, ...
    illuminants.wp);
  rgb = lab2rgb(lab, 'WhitePoint', illuminants.wp);
  rgb = uint8(min(max(rgb, 0), 1) .* 255);
  [~, CurrentNames] = ColourNamingTestImage(rgb, ColourCategorisationModel, false);
  
  ColourNames = cat(1, ColourNames, CurrentNames);
end

end

function lab = ComputeLab(ev, ew, iv, iw, cv, cw, wp)

[ev, iv, cv] = IntersectThree(ev, ew, iv, iw, cv, cw);

lab = hsi2lab(ev, iv, cv, wp);

end
