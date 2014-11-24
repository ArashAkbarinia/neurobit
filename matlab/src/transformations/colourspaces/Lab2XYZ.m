function XYZ = Lab2XYZ(Lab, XYZmatrix)
% XYZ = Lab2XYZ(Lab,whiteXYZ)
%
% Convert Lab to XYZ, given the XYZ coordinates of
% the white point.
%
% 10/10/93    dhb   Converted from CAP C code.
% 5/9/02      dhb   Improved help
% Modified by Alej from DHB's Psychotoolbox code
%===============================================
% if nargin < 2
%     params = InitBits('LinearLUT');
%     XYZmatrix = params{2};
% end

if nargin < 2
  whiteXYZ = [0.950170; 1.000000; 1.088130];
  %White point of D65
elseif isnumeric(XYZmatrix)
  whiteXYZ = XYZmatrix';
else
  whiteXYZ = XYZmatrix.white'; %for backward compatibility!!!
end

[lin, col, pla] = size(Lab);
if pla == 3
  lin2 = lin * col;
  Lab = reshape(Lab, lin2, pla);
end

Lab = Lab';

%===============================================
% Check sizes and allocate
[~, n] = size(Lab);

% Get Y from Lstar
Y = LxxToY(Lab, whiteXYZ);

% Compute F[1] = f(Y/Yn) from Y
% Because subroutine is a vector routine, we put in and get/
% back dummy values for X,Z
fakeXYZ = [Y; Y; Y];
F = XYZToF(fakeXYZ, whiteXYZ);

% Compute ratio[0], ratio[2] from a*,b*, and ratio[1] */
F(1, :) = (Lab(2,:) / 500.0) + F(2, :);
F(3, :) = F(2, :) - (Lab(3, :) / 200.0);
ratio = FToRatio(F);

% Compute XYZ from the ratios
XYZ = ratio .* (whiteXYZ * ones(1, n));
XYZ = XYZ';
if pla == 3
  XYZ = reshape(XYZ, lin, col, pla);
end

end

function ratio = FToRatio(F)
% ratio = FToRatio(F)
%
% This is related to Lab calculations.
%
% 10/10/93    dhb   Converted from CAP C code.

% Find sizes and allocate
[m, n] = size(F);
ratio = zeros(m, n);

% Compute according to the range
hIndex = find( F > 0.206893);
lIndex = find( F <= 0.206893);
if (~isempty(hIndex))
  ratio(hIndex) = F(hIndex) .^ 3.0;
end
if (~isempty(lIndex))
  ratio(lIndex) = (F(lIndex) - (16.0 / 116.0) * ones(length(lIndex), 1)) / 7.787;
end

end