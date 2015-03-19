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

center_size   = WindowSize(1);
surround_size = WindowSize(2);

% horizontal orientation:
if orientation == 1
  % define center and surround filters:
  hc = ones(1, center_size);
  hs = [ones(1, surround_size), zeros(1, center_size), ones(1, surround_size)];
  
  % compute std dev:
  sigma_cen = imfilter(WaveletPlane .^ 2, hc .^ 2, 'symmetric') / (length(find(hc == 1)));
  sigma_sur = imfilter(WaveletPlane .^ 2, hs .^ 2, 'symmetric') / (length(find(hs == 1)));
  
  % vertical orientation:
elseif orientation == 2
  % define center and surround filters:
  hc = ones(center_size, 1);
  hs = [ones(surround_size, 1); zeros(center_size, 1); ones(surround_size, 1)];
  
  % compute std dev:
  sigma_cen = imfilter(WaveletPlane .^ 2, hc .^ 2, 'symmetric') / (length(find(hc == 1)));
  sigma_sur = imfilter(WaveletPlane .^ 2, hs .^ 2, 'symmetric') / (length(find(hs == 1)));
  
  % diagonal orientation:
elseif orientation == 3
  % define center and surround filters:
  hc = ceil((diag(ones(1, center_size)) + fliplr(diag(ones(1, center_size)))) / 4);
  hs = diag([ones(1, surround_size), zeros(1, center_size), ones(1, surround_size)]);
  hs = hs + fliplr(hs);
  
  % compute std dev:
  sigma_cen = imfilter(WaveletPlane .^ 2, hc .^ 2, 'symmetric') / (length(find(hc == 1)));
  sigma_sur = imfilter(WaveletPlane .^ 2, hs .^ 2, 'symmetric') / (length(find(hs == 1)));
end

r    = sigma_cen ./ (sigma_sur + 1.e-6);
zctr = r .^ 2 ./ (1 + r .^ 2);

end
