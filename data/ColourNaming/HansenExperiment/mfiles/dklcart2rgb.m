function rgb = dklcart2rgb(dkl, with_correction)
%DKLCART2RGB  Convert cartesian DKL coordinates to RGB.
%   RGB = DKL2CARTRGB(LUM, CB, TC) returns the corresponding
%   RGB color value. LUM, CB and TC specify the value along the
%   luminance axis (L+M), constant blue axis (L-M), and tritanopic
%   confusion axis (S) in the range [-1, 1].
%
%   Function INITMON must be called once prior to DKLCART2RGB.
%
%   See also DKL2RGB, RGB2DKL, INITMON.
%
% Examples:
%  % DKL +(L-M):
%  I = dklcart2rgb(cat(3, 0, 1.0, 0.0)); imshow(I)
%  % DKL -(S-(L+M)):
%  I = dklcart2rgb(cat(3, 0, 0, -1.0)); imshow(I)
%
%Thorsten Hansen 2004-09-23
%                2005-11-08 faster computation
%                2006-09-13 warning added for uninitialized M_dkl2rgb
%                2009-06-18 with correction added

if nargin < 2, with_correction = 0; end % default is no correction

% check whether the conversion matrix has been initialized
global M_dkl2rgb
if isempty(M_dkl2rgb)
  error('Call function ''initmon'' to initialize M_dkl2rgb.')
end


% check whether the input is in the valid range [-1,1]
if max(abs(dkl(:)) > 1.0)
  warning('Cartesian DKL coordinates out of bounds [-1,1].')
end


% convert
if size(dkl,2) == 3 && size(dkl,1) == 1 % single value
  rgb = 0.5 + M_dkl2rgb*(dkl')/2;
elseif ndims(dkl) == 3 % full image
  %rgb = zeros(size(dkl,1), size(dkl,2), 3);
  %for i=1:size(dkl,1)
  %  for j=1:size(dkl,2)
  %    rgb(i,j,:) = 0.5 + M_dkl2rgb*[dkl(i,j,1);dkl(i,j,2);dkl(i,j,3)]/2;
  %  end
  %end
  [rows, cols, thirdDim] = size(dkl);
  rgb = reshape(reshape(dkl, rows*cols, 3) * M_dkl2rgb', rows, cols, 3);
  rgb = 0.5 + rgb/2;
else
  error('dimension to large.')
end

if with_correction % remap values outside range [0,1]
  ind = find(rgb < 0);
  if ~isempty(ind)
    warning('negative color values mapped to 0.')
    rgb(ind) = 0;
  end
  
  ind = find(rgb > 1);
  if ~isempty(ind)
    warning('color values greater 1 mapped to 1.')
    rgb(ind) = 1;
  end
end

end
