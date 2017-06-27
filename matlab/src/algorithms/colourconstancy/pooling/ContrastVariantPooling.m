function luminance = ContrastVariantPooling(ModelResponse, InputImage)
%ContrastVariantPooling  Pooling top-x-percentage based on the contrast.
%
% inputs
%   ModelResponde  the response of colour constancy models, it can be
%                  grey-edge, double-opponency or in case of the
%                  white-patch the input image itself.
%   InputImage     the original image in order to calculate the local
%                  standard deviation which is used as local contrast.
%
% outputs
%   luminance  estimated source of light as a vector of three lements.
%

% to make the comparison exactly like Grey Edge
SaturationThreshold = max(InputImage(:));
DarkThreshold = min(InputImage(:));
MaxImage = max(InputImage, [], 3);
MinImage = min(InputImage, [], 3);
SaturatedPixels = dilation33(double(MaxImage >= SaturationThreshold | MinImage <= DarkThreshold));
SaturatedPixels = double(SaturatedPixels == 0);
sigma = 2;
SaturatedPixels = set_border(SaturatedPixels, sigma + 1, 0);

for i = 1:3
  ModelResponse(:, :, i) = ModelResponse(:, :, i) .* (ModelResponse(:, :, i) > 0);
  ModelResponse(:, :, i) = ModelResponse(:, :, i) .* SaturatedPixels;
end

% computing the size of average kernel for local standard deviation
CentreSize = floor(min(size(InputImage, 1), size(InputImage, 2)) .* 0.01);
if mod(CentreSize, 2) == 0
  CentreSize = CentreSize - 1;
end
CentreSize = max(CentreSize, 3);

% normalising the model respone in the range of [0, 1]
ModelResponse = ModelResponse ./ max(ModelResponse(:));

% computing the local standard deviation
StdImg = LocalStdContrast(ModelResponse, CentreSize);

CutOff = mean(StdImg(:));
ModelResponse = ModelResponse .* ((2 ^ 8) - 1);
MaxVals = zeros(1, 3);
for i = 1:3
  tmp = ModelResponse(:, :, i);
  tmp = tmp(SaturatedPixels == 1);
  MaxVals(1, i) = PoolingHistMax(tmp(:), CutOff, false);
end

luminance = MaxVals;

end

function HistMax = PoolingHistMax(InputImage, CutoffPercent, UseAveragePixels)
%PoolingHistMax  histogram based clipping
%
% inputs
%   InputImage        input signal to compute its histogram.
%   CutoffPercent     the desired cut off percentage.
%   UseAveragePixels  flag to average for top x percentage or not.
%
% outputs
%   luminance  estimated source of light as a vector of three lements.
%

if nargin < 3
  UseAveragePixels = false;
end

npixels = length(InputImage);
HistMax = zeros(1, 1);

MaxVal = max(InputImage(:));
if MaxVal == 0
  return;
end

if MaxVal < (2 ^ 8)
  nbins = 2 ^ 8;
elseif MaxVal < (2 ^ 16)
  nbins = 2 ^ 16;
end

if nargin < 2 || isempty(CutoffPercent)
  CutoffPercent = 0.01;
end

LowerMaxPixels = CutoffPercent .* npixels;
% setting the upper bound to 50% bigger than the lower bound, this means we
% try to find the final HistMax between the lower and upper bounds. However
% if we don't succeed we choose the closest value to the lower bound.
UpperMaxPixels = LowerMaxPixels * 1.5;

for i = 1:1
  ichan = InputImage;
  [ihist, centres] = hist(ichan(:), nbins);
  
  HistMax(1, i) = centres(end);
  jpixels = 0;
  for j = nbins - 1:-1:1
    jpixels = ihist(j) + jpixels;
    if jpixels > LowerMaxPixels(i)
      if jpixels > UpperMaxPixels
        % if we have passed the upper bound, final HistMax is the one
        % before the lower bound.
        HistMax(1, i) = centres(j + 1);
        if UseAveragePixels
          AllBiggerPixels = ichan(ichan >= centres(j + 1));
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
