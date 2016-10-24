function lab = hsi2lab(hsi, illuminant, xyzspectra)
% HSI2LAB  converts a hyperspectral image into an LAB one.
%
%   We are assuming that hsi, illuminant and xyzspectra are in the same
%   wavelength range.
%
% inputs
%   hsi         the hyperspectral image
%   illuminant  the illumination signal
%
% outputs
%   lab  the converted image into the CIE L*a*b* colour space.
%

FunctionPath = mfilename('fullpath');
FolderPath = strrep(FunctionPath, 'matlab/src/transformations/hsi/hsi2lab', 'matlab/data/mats/hsi/');

%TODO: create a set of default illuminants that can be tested rapidly.
if nargin < 2
  IlluminantsMat = load([FolderPath, 'FosterIlluminants.mat']);
  illuminant = IlluminantsMat.illum_6500;
  wp = whitepoint('d65');
end

[r, c, w] = size(hsi);
if length(illuminant) ~= w
  illuminant = imresize(illuminant, [w, 1]);
end
illuminant = reshape(illuminant, 1, 1, w);

radiances = hsi .* repmat(illuminant, [r, c, 1]);
radiances = reshape(radiances, r * c, w);

if nargin < 3
  xyzmat = load([FolderPath, 'FosterXYZbar.mat']);
  xyzspectra = xyzmat.xyzbar;
end

if length(xyzspectra) ~= w
  xyzspectra = imresize(xyzspectra, [w, 3]);
end
xyz = (xyzspectra' * radiances')';

xyz = reshape(xyz, r, c, 3);
xyz = max(xyz, 0);
xyz = xyz / max(xyz(:));

lab = xyz2lab(xyz, 'WhitePoint', wp);

end