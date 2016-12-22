function [xs, ys] = ComputeCorssOverPerPair(MetamerPairs, spectras, wavelengths)

xs = [];
ys = [];
for i = 1:size(MetamerPairs, 1)
  row = MetamerPairs(i, 1);
  col = MetamerPairs(i, 2);
  
  % fetching the spectra
  spectra1 = spectras{row};
  spectra1 = reshape(spectra1, size(spectra1, 3), 1);
  spectra2 = spectras{col};
  spectra2 = reshape(spectra2, size(spectra2, 3), 1);
  
  [xi, yi] = CorssOverSpectra(spectra1, wavelengths{row}, spectra2, wavelengths{col}, true);
  xs = [xs; xi]; %#ok
  ys = [ys; yi]; %#ok
end

end
