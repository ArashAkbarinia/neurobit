function rec = CIWAM_per_channel(channel, nWaveletLevels, nu_0, mode, WindowSize)
% returns chromatic induction for channel
%
% outputs:
%   rec: chromatic induction for channel
%
% inputs:
%   channel: opponent colour channel for which chromatic induction will be computed
%   wlev: # of wavelet levels
%   nu_0: peak spatial frequency for CSF; suggested value of 4
%   mode: type of channel i.e. colour or intensity
%   window sizes: window sizes for computing relative contrast; suggested
%   value of [3 6]

channel = double(channel);
[w, wc] = DWT(channel, nWaveletLevels);

wp = cell(nWaveletLevels, 1);

% for each scale:
for s = 1:nWaveletLevels
  % for horizontal, vertical and diagonal orientations:
  for orientation = 1:3
    
    % retrieve wavelet plane:
    ws = w{s, 1}(:, :, orientation);
    
    % calculate center-surround responses:
    Zctr = relative_contrast(ws, orientation, WindowSize);
    
    % return alpha values:
    alpha = generate_csf(Zctr, s, nu_0, mode);
    
    % save alpha value:
    wp{s, 1}(:, :, orientation) = ws .* alpha;
  end
  
end

% reconstruct the image using inverse wavelet transform:
rec = IDWT(wp, wc, size(channel, 2),size(channel, 1));

end

function zctr = relative_contrast(WaveletPlane, orientation, WindowSize)
% returns relative contrast for each coefficient of a wavelet plane
%
% outputs:
%   zctr: matrix of relative contrast values for each coefficient
%
% inputs:
%   X: wavelet plane
%   window sizes: window sizes for computing relative contrast; suggested
%   orientation: wavelet plane orientation

CentreSize   = WindowSize(1);
SurroundSize = WindowSize(2);

% define center and surround filters:
switch orientation
  case 1 % horizontal orientation:
    hc = ones(1, CentreSize);
    hs = [ones(1, SurroundSize), zeros(1, CentreSize), ones(1, SurroundSize)];
  case 2 % vertical orientation:
    hc = ones(CentreSize, 1);
    hs = [ones(SurroundSize, 1); zeros(CentreSize, 1); ones(SurroundSize, 1)];
  case 3 % diagonal orientation:
    hc = ceil((diag(ones(1, CentreSize)) + fliplr(diag(ones(1, CentreSize)))) / 4);
    hs = diag([ones(1, SurroundSize), zeros(1, CentreSize), ones(1, SurroundSize)]);
    hs = hs + fliplr(hs);
end

MeanCentre = conv2(WaveletPlane, hc / CentreSize ^ 2, 'same');
SigmaCentre = sqrt(conv2(WaveletPlane .^ 2, hc / CentreSize ^ 2, 'same') - MeanCentre .^ 2);

MeanSurround = conv2(WaveletPlane, hs / SurroundSize ^ 2, 'same');
SigmaSurround = sqrt(conv2(WaveletPlane .^ 2, hs / SurroundSize ^ 2, 'same') - MeanSurround .^ 2);

% compute std dev:
% SigmaCentre = imfilter(WaveletPlane .^ 2, hc .^ 2, 'symmetric') / (length(find(hc == 1)));
% SigmaSurround = imfilter(WaveletPlane .^ 2, hs .^ 2, 'symmetric') / (length(find(hs == 1)));

% EQUATION: eq-4 Otazu et al. 2007, "Multiresolution wavelet framework
% models brightness induction effect"
r    = SigmaCentre ./ (SigmaSurround + 1.e-6);
zctr = r .^ 2 ./ (1 + r .^ 2);

end
