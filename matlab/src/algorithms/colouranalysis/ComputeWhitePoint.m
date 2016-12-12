function wp = ComputeWhitePoint(illuminant, ColourReceptors)
%ComputeWhitePoint  estimates the white point based on the unity energy.
%   Explnation https://en.wikipedia.org/wiki/White_point
%
% inputs
%   illuminant       the spectral power distribution of source of light.
%   ColourReceptors  the spectral sensitivity function of colour receptors.
%                    by default the 1931 spectra sensitivities.
%
% outputs
%   wp  the estimated white point.
%

FunctionPath = mfilename('fullpath');
FunctionRelativePath = ['src', filesep, 'algorithms', filesep, 'colouranalysis', filesep, 'ComputeWhitePoint'];

DataPath = ['data', filesep, 'mats', filesep, 'hsi', filesep];

if nargin < 2
  FundamentalsPath = strrep(FunctionPath, FunctionRelativePath, [DataPath, 'XyzSpectralSensitivity.mat']);
  ColourReceptorsMat = load(FundamentalsPath);
  ColourReceptors.spectra = ColourReceptorsMat.Xyz1931SpectralSensitivity;
  ColourReceptors.wavelength = ColourReceptorsMat.wavelength;
end

% making the illumiant and colour receptor the same size
[illuminant, ColourReceptors] = IntersectIlluminantColourReceptors(illuminant, ColourReceptors);

WhitePixel = 1;

radiances = WhitePixel .* illuminant.spectra;

xyz = ColourReceptors.spectra' * radiances;
xyz = max(xyz, 0);
xyz = xyz';

wp = xyz ./ sum(xyz(:));

end
