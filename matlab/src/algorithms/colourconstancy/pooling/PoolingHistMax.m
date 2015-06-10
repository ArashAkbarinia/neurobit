function HistMax = PoolingHistMax(InputImage, CutoffPercent)
%PoolingHistMax  pooling the maximum value based on the histogram.
%   Instead of choosing the maximum intensity for each colour channel, this
%   function chooses the intensity such that number of pixels with
%   intensity higher account for cutoff percentage.
%   EQUATION: eq-6.6-6.8 Ebner 2007, "Color Constancy"
%
% inputs
%   InputImage     the input image.
%   CutoffPercent  the cut off percentage, default is 0.01.
%
% outputs
%   HistMax  the maximum value that satisfies CutoffPercent in range [0, 1]
%

[rows, cols, chns] = size(InputImage);
npixels = rows * cols;

% bringing all the minus values to positive
MinVal = min(min(InputImage, [], 2), [], 1);
for i = 1:chns
  if MinVal(1, 1, i) < 0
    InputImage(:, :, i) = InputImage(:, :, i) - MinVal(1, 1, i);
  end
end

MaxVal = max(InputImage(:));
if MaxVal < (2 ^ 8)
  InputImage = uint8(round(InputImage));
  nbins = 2 ^ 8;
elseif MaxVal < (2 ^ 16)
  InputImage = uint16(round(InputImage));
  nbins = 2 ^ 16;
end

if nargin < 2 || isempty(CutoffPercent)
  CutoffPercent = 0.01;
end
if length(CutoffPercent) == 1
  CutoffPercent(2:chns) = CutoffPercent(1);
end

maxnpizels = CutoffPercent .* npixels;

HistMax = zeros(1, chns);
for i = 1:chns
  ichan = InputImage(:, :, i);
  ihist = imhist(ichan, nbins);
  
  HistMax(1, i) = nbins - 1;
  jpixels = 0;
  for j = nbins:-1:1
    jpixels = ihist(j) + jpixels;
    if jpixels > maxnpizels(i)
      HistMax(1, i) = j - 1;
      break;
    end
  end
end

% subtracting the minus values
for i = 1:chns
  if MinVal(1, 1, i) < 0
    HistMax(1, i) = HistMax(1, i) + MinVal(1, 1, i);
  end
end

end
