function [ev, iv, cv] = IntersectThree(ev, ew, iv, iw, cv, cw)
%IntersectThree  finds the common intersection of illuminant, colour
%                receptors and surface reflectance.

% TODO: return the common wavelength as well.

[~, ia1, ib] = intersect(ew, iw);
% TODO: it's more accurate to find the intersection of all 3 vectors.
% I assumed the colour receptor and illuminants are similar size.
[~, ~, ic] = intersect(ew, cw);

ev = ev(:, :, ia1);
iv = iv(ib');
cv = cv(ic', :);

end
