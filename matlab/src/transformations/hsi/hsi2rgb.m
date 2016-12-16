function rgb = hsi2rgb(hsi, illuminant, ColourReceptor, wp)
%HSI2RGB  converts a hyperspectral image into an RGB one.
%   Explanation http://personalpages.manchester.ac.uk/staff/d.h.foster/Tutorial_HSI2RGB/Tutorial_HSI2RGB.html
%
% inputs
%   hsi             the hyperspectral image
%   illuminant      the illumination signal
%   ColourReceptor  the xyz sensitivity function.
%   wp              white reference.
%
% outputs
%   rgb  the converted RGB image
%

FunctionPath = mfilename('fullpath');
DataFolder = ['matlab', filesep, 'data', filesep, 'mats', filesep, 'hsi', filesep];
FunctionRelativePath = ['matlab', filesep, 'src', filesep, 'transformations', filesep, 'hsi', filesep, 'hsi2rgb'];
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

xyz = hsi2xyz(hsi, illuminant, ColourReceptor);

% to have similar results as hsi2lab
rgb = xyz2rgb(xyz, 'WhitePoint', wp);

% values below 0 have to correspondes in RGB
rgb = max(rgb, 0);
rgb = NormaliseChannel(rgb, [], [], [], []);

end
