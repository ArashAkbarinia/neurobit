function wp = ComputeWhitePoint(illuminant, ColourReceptors)
%ComputeWhitePoint  estimates the white point from the Macbeth white pixel.
%
% inputs
%   illuminant       the spectral power distribution of source of light.
%   ColourReceptors  the spectral sensitivity function of colour receptors.
%
% outputs
%   wp  the estimated white point
%

FunctionPath = mfilename('fullpath');
FunctionRelativePath = ['src', filesep, 'algorithms', filesep, 'colouranalysis', filesep, 'ComputeWhitePoint'];

MacbethPath = strrep(FunctionPath, FunctionRelativePath, ['data', filesep, 'mats', filesep, 'hsi', filesep, 'MacbethReflectances.mat']);
MacbethMat = load(MacbethPath);
w = 391;
WhitePixel = reshape(MacbethMat.MacbethReflectances(:, 19)', 1, 1, w);

[WhitePixel, illuminant, ColourReceptors] = IntersectThree(WhitePixel, MacbethMat.wavelength, ...
  illuminant.spectra, illuminant.wavelength, ColourReceptors.spectra, ColourReceptors.wavelength);

radiances = reshape(WhitePixel, size(WhitePixel, 3), 1) .* illuminant;

xyz = ColourReceptors' * radiances;
xyz = max(xyz, 0);
xyz = xyz';

wp = xyz ./ sum(xyz(:));

end
