function [DO12, DO21] = OrientedDoubleOpponentContrast(map, CentreSigma, angles, weights)

if nargin < 5, weights= -0.7; end
if nargin < 4,  angles = 8;  end

CentreContrastEnlarge = 10;
CentreContrastLevels = 16;
% compute responses of single-opponent cells
[Ch12, Ch21] = SingleOpponentContrast(map,CentreSigma,weights, CentreContrastEnlarge, CentreContrastLevels);

% construct RF of the oriented double-opponent
SurroundSigma = 2 * 1.1;%2 * CentreSigma;
DO12 = zeros(size(map,1),size(map,2),angles);
DO21 = zeros(size(map,1),size(map,2),angles);

% Obtain the response with the filters in degree of [0 pi],
% and then taking the absolute value, which is same as rotating the  filters
% in [0 2*pi]
thetas = zeros(1, angles);
for i = 1:angles
  thetas(i) = (i-1)*pi/angles;
  
  dgau2D = DivGauss2D(SurroundSigma,thetas(i));
  S = sum(abs(dgau2D(:)));
  
  t1 = conByfft(Ch12,dgau2D/S); % Ch12
  DO12(:,:,i) = abs(t1);
  
%   t2 = conByfft(Ch21,dgau2D/S); % Ch21
%   DO21(:,:,i) = abs(t2);
end

SurroundContrastEnlarge = 2;
SurroundContrastLevels = 4;
% DO12 = abs(ContrastDependantGaussianGradient(Ch12, SurroundSigma, SurroundContrastEnlarge, SurroundContrastLevels, 1, thetas, map));
% DO21 = abs(ContrastDependantGaussianGradient(Ch21, sigma, ContrastEnlarge, ContrastLevels, 1, thetas));

DO21 = DO12;

end

function [Ch12, Ch21] = SingleOpponentContrast(map,sigma,weights,ContrastEnlarge, ContrastLevels)

if nargin < 4, weights= -0.7; end

[rr, cc, d] = size(map);

channel1 = map(:, :, 1);
channel2 = map(:, :, 2);

% compute the response of center-only single opponent cells
w1 = 1.0 * ones(rr,cc);
w2 = weights .* ones(rr,cc);

% original code
gau2D = gaus(1.1);
Ch1 = imfilter(channel1,gau2D,'conv','replicate');
% Ch2 = imfilter(channel2,gau2D,'conv','replicate');

% our improvement
ContrastGaussian = ContrastDependantGaussian(channel1, sigma, ContrastEnlarge, ContrastLevels);
Ch1 = Ch1 + ContrastGaussian;
% Ch2 = Ch2 + ContrastDependantGaussian(channel2, sigma, ContrastEnlarge, ContrastLevels);

Ch12 = Ch1;
Ch21 = Ch1;

% Ch12 = w1.*Ch1 + w2.*Ch2;   % Ch1+ Ch2-
% Ch21 = w2.*Ch1 + w1.*Ch2;   % Ch1- Ch2+

end
