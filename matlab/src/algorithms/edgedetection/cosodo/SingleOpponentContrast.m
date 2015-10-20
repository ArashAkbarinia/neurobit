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
