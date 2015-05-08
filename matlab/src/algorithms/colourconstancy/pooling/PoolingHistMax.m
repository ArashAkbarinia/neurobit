function HistMax = PoolingHistMax(InputImage, nbins, CutoffPercent, MaxVal)
%PoolingHistMax  pooling the maximum value based on the histogram.
%   Instead of choosing the maximum intensity for each colour channel, this
%   function chooses the intensity such that number of pixels with
%   intensity higher account for cutoff percentage.
%
% inputs
%   InputImage     the input image.
%   nbins          number of discrete grey levels, default is max value.
%   CutoffPercent  the cut off percentage, default is 0.01.
%   MaxVal         the maximum value of data type, default max operation.
%
% outputs
%   HistMax  the maximum value that satisfies CutoffPercent in range [0, 1]
%

if nargin < 3
  CutoffPercent = 0.01;
end

[rows, cols, chns] = size(InputImage);
npixels = rows * cols;

maxnpizels = CutoffPercent * npixels;

HistMax = zeros(1, 3);
for i = 1:chns
  ichan = InputImage(:, :, i);
  if nargin < 4
    MaxVal = max(max(ichan));
  end
  if nargin < 2
    nbins = ceil(MaxVal);
  end
  ihist = imhist(ichan, nbins);
  
  HistMax(1, i) = MaxVal;
  jpixels = 0;
  for j = nbins:-1:1
    jpixels = ihist(j) + jpixels;
    if jpixels >= maxnpizels
      HistMax(1, i) = j ./ nbins .* MaxVal;
      break;
    end
  end
end

end
