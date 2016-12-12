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
