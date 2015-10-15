function [Ch12, Ch21] = SingleOpponentContrast(map,opponent,sigma,weights,ContrastEnlarge, ContrastLevels)

if nargin < 4, weights= -0.7; end

[rr, cc, d] = size(map);
if d~=3
  error('The input image must be a color image(3-D matrix)!\n');
end

% obtain each channel
R = map(:,:,1);   % Cone-L
G = map(:,:,2);   % Cone-M
B = map(:,:,3);   % Cone-S
Y = (R+G)/2;

rgb2do = ...
  [
  0.2990,  0.5870,  0.1140;
  0.5000,  0.5000, -1.0000;
  0.8660, -0.8660,  0.0000;
  ];
OpponentImage = rgb2do * reshape(map, rr * cc, d)';
OpponentImage = reshape(OpponentImage', rr, cc, d);

% select the opponent channels
if strcmp(opponent,'RG')
  %     channel1 = R;  channel2 = G;
  channel1 = OpponentImage(:, :, 2);
  channel2 = 1 - channel1;
elseif strcmp(opponent,'BY')
  %     channel1 = B;  channel2 = Y;
  channel1 = OpponentImage(:, :, 3);
  channel2 = 1 - channel1;
elseif strcmp(opponent,'WB')
  %     channel1 = B;  channel2 = Y;
  channel1 = OpponentImage(:, :, 1);
  channel2 = 1 - channel1;
else
  error('the opponent channel parameter must be one of {RG,BY}\n');
end

% compute the response of center-only single opponent cells
w1 = 1.0 * ones(rr,cc);
w2 = weights .* ones(rr,cc);

% original code
% gau2D = gaus(sigma);
% Ch1 = imfilter(channel1,gau2D,'conv','replicate');
% Ch2 = imfilter(channel2,gau2D,'conv','replicate');

% our improvement
Ch1 = ContrastDependantGaussian(channel1, sigma, ContrastEnlarge, ContrastLevels);
% Ch2 = ContrastDependantGaussian(channel2, sigma, ContrastEnlarge, ContrastLevels);
Ch2 = Ch1;

Ch12 = w1.*Ch1 + w2.*Ch2;   % Ch1+ Ch2-
Ch21 = w2.*Ch1 + w1.*Ch2;   % Ch1- Ch2+
%=========================================================================%
