function [Re, theta] = resSCOContrast(map,sigma,angles,weights,ws)

if nargin < 5, ws= 5; end
if nargin < 4, weights= -0.7; end
if nargin < 3,  angles = 8;  end

[w, h, d] = size(map);
theta = zeros(w,h);
Re = zeros(w,h);

rgb2do = ...
  [
  0.2990,  0.5870,  0.1140;
  0.5000,  0.5000, -1.0000;
  0.8660, -0.8660,  0.0000;
  ];
NewColourSpace = rgb2do * reshape(map, w * h, d)';
NewColourSpace = reshape(NewColourSpace', w, h, d);

% OpponentImage = double(applycform(uint8(map .* 255), makecform('srgb2lab')));
% for i = 1:3
%   OpponentImage(:, :, i) = OpponentImage(:, :, i) ./ max(max(OpponentImage(:, :, i)));
% end

% OpponentImage(:, :, 1) = NewColourSpace(:, :, 2);
% OpponentImage(:, :, 2) = NewColourSpace(:, :, 2);
% OpponentImage(:, :, 3) = NewColourSpace(:, :, 3);
% OpponentImage(:, :, 4) = NewColourSpace(:, :, 3);
% OpponentImage(:, :, 5) = NewColourSpace(:, :, 1);
% OpponentImage(:, :, 6) = NewColourSpace(:, :, 1);

R = map(:,:,1);   % Cone-L
G = map(:,:,2);   % Cone-M
B = map(:,:,3);   % Cone-S
Y = (R+G)/2;
OpponentImage(:, :, 1) = R;
OpponentImage(:, :, 2) = G;
OpponentImage(:, :, 3) = B;
OpponentImage(:, :, 4) = Y;

% [Drg Dgr]= OrientedDoubleOpponent(map,'RG',sigma,angles,weights);
% [Dby Dyb]= OrientedDoubleOpponent(map,'BY',sigma,angles,weights);
[Boundary(:, :, 1:2), Orients(:, :, 1:2)] = resSCOContrastOneChannel(OpponentImage(:, :, [1, 2]),sigma,angles,weights,ws); % 'RG'
[Boundary(:, :, 3:4), Orients(:, :, 3:4)] = resSCOContrastOneChannel(OpponentImage(:, :, [3, 4]),sigma,angles,weights,ws); % 'BY'
% [Boundary(:, :, 5:6), Orients(:, :, 5:6)] = resSCOContrastOneChannel(OpponentImage(:, :, 5:6),sigma,angles,weights,ws); % 'WB'

% max-pool
[Re(:,:),idx(:,:)]= max(Boundary,[],3);

% obtain the optimal orientation
for i = 1:w
  for j =1:h
    theta(i,j) = Orients(i,j,idx(i,j));
  end
end

end

function [Boundary, Orients] = resSCOContrastOneChannel(map,sigma,angles,weights,ws)
if nargin < 5, ws= 5; end
if nargin < 4, weights= -0.7; end
if nargin < 3,  angles = 8;  end

% [Drg Dgr]= OrientedDoubleOpponent(map,'RG',sigma,angles,weights);
[Drg, Dgr]= OrientedDoubleOpponentContrast(map,sigma,angles,weights);

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
