function [Re, theta] = resSCOContrast(map, sigma, angles, ws, DebugImagePath, weights1)

if nargin < 4, ws= 5; end
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
OpponentImage = rgb2do * reshape(map, w * h, d)';
OpponentImage = reshape(OpponentImage', w, h, d);

% OpponentImage = double(applycform(uint8(map .* 255), makecform('srgb2lab')));
% for i = 1:3
%   OpponentImage(:, :, i) = OpponentImage(:, :, i) ./ max(max(OpponentImage(:, :, i)));
% end

% R = map(:,:,1);   % Cone-L
% G = map(:,:,2);   % Cone-M
% B = map(:,:,3);   % Cone-S
% Y = (R+G)/2;
% OpponentImage(:, :, 1) = R;
% OpponentImage(:, :, 2) = G;
% OpponentImage(:, :, 3) = B;
% OpponentImage(:, :, 4) = Y;

% [Drg Dgr]= OrientedDoubleOpponent(map,'RG',sigma,angles,weights);
% [Dby Dyb]= OrientedDoubleOpponent(map,'BY',sigma,angles,weights);
[Boundary(:, :, 1:2), Orients(:, :, 1:2)] = resSCOContrastOneChannel(OpponentImage(:, :, 1),sigma,angles, ws, DebugImagePath, 1, weights1); % 'RG'
[Boundary(:, :, 3:4), Orients(:, :, 3:4)] = resSCOContrastOneChannel(OpponentImage(:, :, 2),sigma,angles, ws, DebugImagePath, 2, weights1); % 'BY'
[Boundary(:, :, 5:6), Orients(:, :, 5:6)] = resSCOContrastOneChannel(OpponentImage(:, :, 3),sigma,angles, ws, DebugImagePath, 3, weights1); % 'WB'

% max-pool
[Re(:,:),idx(:,:)]= max(Boundary,[],3);

% obtain the optimal orientation
for i = 1:w
  for j =1:h
    theta(i,j) = Orients(i,j,idx(i,j));
  end
end

end

function [Boundary, Orients] = resSCOContrastOneChannel(map, sigma, angles, ws, DebugImagePath, c, weights1)
if nargin < 4, ws= 5; end
if nargin < 3,  angles = 8;  end

dor = OrientedDoubleOpponentContrast(map, sigma, angles, DebugImagePath, c, weights1);

Dgr = dor;

[CBrg(:,:),Orients(:,:,1)] = max(dor,[],3);
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
