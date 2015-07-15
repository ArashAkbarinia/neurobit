function HistMax = PoolingHistMax(InputImage, CutoffPercent, UseAveragePixels)
%PoolingHistMax  pooling the maximum value based on the histogram.
%   Instead of choosing the maximum intensity for each colour channel, this
%   function chooses the intensity such that number of pixels with
%   intensity higher account for cutoff percentage.
%   EQUATION: eq-6.6-6.8 Ebner 2007, "Color Constancy"
%
% inputs
%   InputImage        the input image.
%   CutoffPercent     the cut off percentage, default is 0.01.
%   UseAveragePixels  if true, returns mean of all pixels above cut off.
%
% outputs
%   HistMax  the maximum value that satisfies CutoffPercent in range [0, 1]
%

if nargin < 3
  UseAveragePixels = false;
end

[rows, cols, chns] = size(InputImage);
npixels = rows * cols;

MaxVal = max(InputImage(:));
if MaxVal < (2 ^ 8)
  nbins = 2 ^ 8;
elseif MaxVal < (2 ^ 16)
  nbins = 2 ^ 16;
end

if nargin < 2 || isempty(CutoffPercent)
  CutoffPercent = 0.01;
end
if length(CutoffPercent) == 1
  CutoffPercent(2:chns) = CutoffPercent(1);
end

LowerMaxPixels = CutoffPercent .* npixels;
% setting the upper bound to 50% bigger than the lower bound, this means we
% try to find the final HistMax between the lower and upper bounds. However
% if we don't succeed we choose the closest value to the lower bound.
UpperMaxPixels = LowerMaxPixels * 1.5;

HistMax = zeros(1, chns);
for i = 1:chns
  ichan = InputImage(:, :, i);
  [ihist, centres] = hist(ichan(:), nbins);
  
  HistMax(1, i) = centres(end);
  jpixels = 0;
  for j = nbins:-1:1
    jpixels = ihist(j) + jpixels;
    if jpixels > LowerMaxPixels(i)
      if jpixels > UpperMaxPixels
        % if we have passed the upper bound, final HistMax is the one
        % before the lower bound.
        HistMax(1, i) = centres(j - 1);
        if UseAveragePixels
          AllBiggerPixels = ichan(ichan >= centres(j - 1));
          HistMax(1, i) = mean(AllBiggerPixels(:));
        end
      else
        HistMax(1, i) = centres(j);
        if UseAveragePixels
          AllBiggerPixels = ichan(ichan >= centres(j));
          HistMax(1, i) = mean(AllBiggerPixels(:));
        end
      end
      break;
    end
  end
end

end
