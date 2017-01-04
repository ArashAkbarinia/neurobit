function [xi, yi] = CorssOverSpectra(spectra1, wavelength1, spectra2, wavelength2, robust)
%CorssOverSpectra  find cross overs of two signals

if nargin < 5
  robust = false;
end

signal1.spectra = spectra1;
signal1.wavelength = wavelength1;
signal2.spectra = spectra2;
signal2.wavelength = wavelength2;

[signal1, signal2] = IntersectIlluminantColourReceptors(signal1, signal2);

[xi, yi] = polyxpoly(signal1.wavelength, signal1.spectra, signal2.wavelength, signal2.spectra, robust);

end
