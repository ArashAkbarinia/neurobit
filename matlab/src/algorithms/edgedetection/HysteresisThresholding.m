function OutputImage = HysteresisThresholding(InputImage, nthresh, hmult)
%HysteresisThresholding Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
  nthresh = 100;
end
if nargin < 3
  hmult = 1 / 3;
end

if hmult < 0 || hmult > 1
  error('Invalid hmult value');
end
if nthresh < 1
  error('Invalid nthresh value');
end

OutputImage = zeros(size(InputImage));

for j = 1:size(InputImage, 3)
  pbgm = InputImage(:, :, j);
  pbgm = pbgm ./ max(pbgm(:));
  
  % apply hysteresis thresholding
  pb = zeros(size(pbgm));
  thresh = linspace(1 / nthresh, 1 - 1 / nthresh, nthresh);
  for i = 1:nthresh,
    [r, c] = find(pbgm >= thresh(i));
    if numel(r) == 0
      continue;
    end
    b = bwselect(pbgm > hmult * thresh(i), c, r, 8);
    pb = max(pb, b * thresh(i));
  end
  
  OutputImage(:, :, j) = pb;
end

end
