function [Re, theta] = resSCOContrast(map,sigma,angles,weights,ws)


if nargin < 5, ws= 5; end
if nargin < 4, weights= -0.7; end
if nargin < 3,  angles = 8;  end

[w, h, d] = size(map);
theta = zeros(w,h);
Re = zeros(w,h);

% [Drg Dgr]= OrientedDoubleOpponent(map,'RG',sigma,angles,weights);
% [Dby Dyb]= OrientedDoubleOpponent(map,'BY',sigma,angles,weights);
[Boundary(:, :, 1:2), Orients(:, :, 1:2)] = resSCOContrastOneChannel(map,sigma,angles,weights,ws, 'RG');
[Boundary(:, :, 3:4), Orients(:, :, 3:4)] = resSCOContrastOneChannel(map,sigma,angles,weights,ws, 'BY');
[Boundary(:, :, 5:6), Orients(:, :, 5:6)] = resSCOContrastOneChannel(map,sigma,angles,weights,ws, 'WB');

% max-pool
[Re(:,:),idx(:,:)]= max(Boundary,[],3);

% obtain the optimal orientation
for i = 1:w
  for j =1:h
    theta(i,j) = Orients(i,j,idx(i,j));
  end
end
%=========================================================================%

end

function [Boundary, Orients] = resSCOContrastOneChannel(map,sigma,angles,weights,ws, type)
if nargin < 5, ws= 5; end
if nargin < 4, weights= -0.7; end
if nargin < 3,  angles = 8;  end

% [Drg Dgr]= OrientedDoubleOpponent(map,'RG',sigma,angles,weights);
[Drg, Dgr]= OrientedDoubleOpponentContrast(map,type,sigma,angles,weights);

[CBrg(:,:),Orients(:,:,1)] = max(Drg,[],3);
[CBgr(:,:),Orients(:,:,2)] = max(Dgr,[],3);

CBrg = CBrg./max(CBrg(:));   % normlization
CBgr = CBgr./max(CBgr(:));

% SPrg=SparIndex(CBrg,ws);
% SPgr=SparIndex(CBgr,ws);
% 
% CBrg = CBrg.*SPrg;
% CBgr = CBgr.*SPgr;

Boundary(:, :, 1) = CBrg;
Boundary(:, :, 2) = CBgr;

end

