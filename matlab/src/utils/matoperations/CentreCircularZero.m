function SurroundMat = CentreCircularZero(SurroundMat, CentreRadius)
%CentreCircularZero  sets the centre with given radius to 0.
%
% inputs
%   SurroundMat   the matrix that its centre will be set to 0.
%   CentreRadius  the radius of centre.
%
% outputs
%   SurroundMat  the centred set to 0 matrix.
%

[ws, hs] = size(SurroundMat);

if CentreRadius == 0 || CentreRadius > min(ws, hs)
  return;
end

x = max(ws, hs) + 1;
[rr, cc] = meshgrid(1:x - 1);
ch = sqrt((rr - x / 2) .^ 2 + (cc - x / 2) .^ 2) <= CentreRadius;

SurroundMat(ch) = 0;

end
