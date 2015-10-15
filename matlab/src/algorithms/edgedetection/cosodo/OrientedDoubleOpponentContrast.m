function [DO12, DO21] = OrientedDoubleOpponentContrast(map,opponent,sigma,angles,weights)

if nargin < 5, weights= -0.7; end
if nargin < 4,  angles = 8;  end

CentreContrastEnlarge = 10;
CentreContrastLevels = 16;
% compute responses of single-opponent cells
[Ch12, Ch21] = SingleOpponentContrast(map,opponent,sigma,weights, CentreContrastEnlarge, CentreContrastLevels);

% construct RF of the oriented double-opponent
% sig = 2*sigma;
% DO12 = zeros(size(map,1),size(map,2),angles);
% DO21 = zeros(size(map,1),size(map,2),angles);

% fprintf(2,'[');

% Obtain the response with the filters in degree of [0 pi],
% and then taking the absolute value, which is same as rotating the  filters
% in [0 2*pi]
thetas = zeros(1, angles);
for i = 1:angles
  thetas(i) = (i-1)*pi/angles;
  
  %   dgau2D = DivGauss2D(sig,thetas(i));
  %   S = sum(abs(dgau2D(:)));
  %   t1 = conByfft(Ch12,dgau2D/S); % Ch12
  %   DO12(:,:,i) = abs(t1);
  %   t2 = conByfft(Ch21,dgau2D/S); % Ch21
  %   DO21(:,:,i) = abs(t2);
  %
  %   fprintf(2,'.');
end

SurroundContrastEnlarge = 2;
SurroundContrastLevels = 4;
DO12 = abs(-ContrastDependantGaussianGradient(Ch12, sigma, SurroundContrastEnlarge, SurroundContrastLevels, 1, thetas));
% DO21 = abs(-ContrastDependantGaussianGradient(Ch21, sigma, ContrastEnlarge, ContrastLevels, 1, thetas));
DO21 = DO12;

% fprintf(2,']\n');
%=========================================================================%
