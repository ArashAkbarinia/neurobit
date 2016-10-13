function rgb = hsi2rgb(hsi, illuminant)
% HSI2RGB  converts a hyperspectral image into an RGB one.
%   Explanation http://personalpages.manchester.ac.uk/staff/d.h.foster/Tutorial_HSI2RGB/Tutorial_HSI2RGB.html
%
% inputs
%   hsi         the hyperspectral image
%   illuminant  the illumination signal
%
% outputs
%   rgb  the converted RGB image
%

FunctionPath = mfilename('fullpath');
FolderPath = strrep(FunctionPath, 'matlab/src/transformations/hsi/hsi2rgb', 'matlab/data/mats/hsi/');

if nargin < 2
  IlluminantsMat = load([FolderPath, 'illuminants.mat']);
  illuminant = IlluminantsMat.illum_6500;
end

[r, c, w] = size(hsi);
if length(illuminant) ~= w
  illuminant = imresize(illuminant, [w, 1]);
end
illuminant = reshape(illuminant, 1, 1, w);

radiances = hsi .* repmat(illuminant, [r, c, 1]);
radiances = reshape(radiances, r * c, w);

xyzmat = load([FolderPath, 'xyzbar.mat']);
if length(xyzmat.xyzbar) ~= w
  xyzmat.xyzbar = imresize(xyzmat.xyzbar, [w, 3]);
end
xyz = (xyzmat.xyzbar' * radiances')';

xyz = reshape(xyz, r, c, 3);
xyz = max(xyz, 0);
xyz = xyz / max(xyz(:));

rgb = xyz2srgb_exgamma(xyz);
rgb = max(rgb, 0);
rgb = min(rgb, 1);

end

function srgb = xyz2srgb_exgamma(xyz)

% See IEC_61966-2-1.pdf
% No gamma correction has been incorporated here, nor any clipping, so this
% transformation remains strictly linear.  Nor is there any data-checking.

% Image dimensions
d = size(xyz);
r = prod(d(1:end-1));   % product of sizes of all dimensions except last, wavelength
w = d(end);             % size of last dimension, wavelength

% Reshape for calculation, converting to w columns with r rows.
xyz = reshape(xyz, [r, w]);

% Forward transformation from 1931 CIE XYZ values to sRGB values (Eqn 6 in
% IEC_61966-2-1.pdf).
M = ...
  [
  +3.2406, -1.5372, -0.4986
  -0.9689, +1.8758, +0.0414
  +0.0557, -0.2040, +1.0570
  ];
srgb = (M * xyz')';

% Reshape to recover shape of original input.
srgb = reshape(srgb, d);

end
