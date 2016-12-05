function [rs, is, cs] = IntersectThree(rs, rw, is, iw, cs, cw)
%IntersectThree  finds the common intersection of illuminant, colour
%                receptors and surface reflectance.

% TODO: return the common wavelength as well.

% TODO: it's more accurate to find the intersection of all 3 vectors.
% I assumed the colour receptor and illuminants are similar size.
if size(rw, 1) < size(iw, 1)
  [rs, rw, is, iw, cs, cw] = SmallBigIntersect(rs, rw, is, iw, cs, cw);
elseif size(rw, 1) > size(iw, 1)
  [is, iw, rs, rw, cs, cw] = BigSmallIntersect(is, iw, rs, rw, cs, cw);
elseif rw ~= iw
  [rs, rw, is, iw, cs, cw] = SmallBigIntersect(rs, rw, is, iw, cs, cw);
end

end

function [rs, rw, is, iw, cs, cw] = SmallBigIntersect(rs, rw, is, iw, cs, cw)

rs = reshape(rs, size(rs, 1), size(rs, 3))';

wavelength = interp1(rw, rw, iw);
spectra = interp1(rw, rs, iw);
NumberInds = ~isnan(wavelength);

rw = wavelength(NumberInds);
rs = spectra(NumberInds, :);
iw = iw(NumberInds);
is = is(NumberInds, :);
cw = cw(NumberInds);
cs = cs(NumberInds, :);

rs = reshape(rs', size(rs, 2), 1, size(rs, 1));

end

function [is, iw, rs, rw, cs, cw] = BigSmallIntersect(is, iw, rs, rw, cs, cw)

wavelength = interp1(iw, iw, rw);
spectra = interp1(iw, is, rw);
NumberInds = ~isnan(wavelength);

% it has the same dimension as illuminant
cs = interp1(iw, cs, rw);

iw = wavelength(NumberInds, :);
is = spectra(NumberInds, :);
rw = rw(NumberInds);
rs = rs(:, :, NumberInds);

cw = iw;
cs = cs(NumberInds, :);

end
