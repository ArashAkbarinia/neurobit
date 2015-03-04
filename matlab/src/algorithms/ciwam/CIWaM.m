function ind = CIWaM(img, window_sizes, wlev, gamma, srgb_flag, nu_0)
% returns saliency map for image
%
% outputs:
%   smap: saliency map for image
%
% inputs:
%   imag: input image
%   window sizes: window sizes for computing relative contrast; suggested
%   value of [3 6]
%   wlev: # of wavelet levels
%   gamma: gamma value for gamma correction
%   srgb_flag: 0 if img is rgb; 1 if img is srgb
%   nu_0: peak spatial frequency for CSF; suggested value of 4

if nargin < 2
  MidaMin = 4;
  wlev = floor(log(max(size(img) - 1) / MidaMin) / log(2)) + 1;
  
  window_sizes = [3, 6];
  nu_0 = 3;
  gamma = 1;
  srgb_flag = 0;
end

% convert opponent colour space of colour images:
opp_img = rgb2opponent(img, gamma, srgb_flag);

% generate ciwam for each channel:
rec(:, :, 1) = CIWAM_per_channel(opp_img(:, :, 1), wlev, nu_0, 'colour', window_sizes);
rec(:, :, 2) = CIWAM_per_channel(opp_img(:, :, 2), wlev, nu_0, 'colour', window_sizes);
rec(:, :, 3) = CIWAM_per_channel(opp_img(:, :, 3), wlev, nu_0, 'intensity', window_sizes);

ind = opponent2rgb(rec, gamma, srgb_flag);

end
