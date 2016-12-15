function lab = hsi2lab(hsi, illuminant, ColourReceptor, wp)
% HSI2LAB  converts a hyperspectral image into an LAB one.
%
% inputs
%   hsi             the hyperspectral image
%   illuminant      the illumination signal
%   ColourReceptor  the xyz sensitivity function.
%   wp              white reference.
%
% outputs
%   lab  the converted image into the CIE L*a*b* colour space.
%

FunctionPath = mfilename('fullpath');
DataFolder = ['matlab', filesep, 'data', filesep, 'mats', filesep, 'hsi', filesep];
FunctionRelativePath = ['matlab', filesep, 'src', filesep, 'transformations', filesep, 'hsi', filesep, 'hsi2lab'];
FolderPath = strrep(FunctionPath, FunctionRelativePath, DataFolder);

if nargin < 2 || isempty(illuminant)
  IlluminantsMat = load([FolderPath, 'FosterIlluminants.mat']);
  illuminant.spectra = IlluminantsMat.illum_6500;
  illuminant.wavelength = IlluminantsMat.wavelength;
end

if nargin < 3 || isempty(ColourReceptor)
  xyzmat = load([FolderPath, 'FosterXYZbar.mat']);
  ColourReceptor.spectra = xyzmat.xyzbar;
  ColourReceptor.wavelength = xyzmat.wavelength;
end

if nargin < 4 || isempty(wp)
  wp = ComputeWhitePoint(illuminant, ColourReceptor);
end

% making the illumiant and colour receptor the same size
[illuminant, ColourReceptor] = IntersectIlluminantColourReceptors(illuminant, ColourReceptor);

[rs, is, cs] = IntersectThree(hsi.spectra, hsi.wavelength, illuminant.spectra, illuminant.wavelength, ColourReceptor.spectra, ColourReceptor.wavelength);

[r, c, w] = size(rs);
is = reshape(is, 1, 1, w);

radiances = rs .* repmat(is, [r, c, 1]);
radiances = reshape(radiances, r * c, w);

xyz = (cs' * radiances')';

xyz = reshape(xyz, r, c, 3);
xyz = max(xyz, 0);
xyz = xyz / max(xyz(:));

lab = xyz2lab(xyz, 'WhitePoint', wp);

end
