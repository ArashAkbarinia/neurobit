function ColourConstantImage = ColourConstancyProgressive(InputImage, h1, h2)
%ColourConstancyProgressive applies the progressive algorithm.
%
% Inputs
%   InputImage  the input image.
%
% Outputs
%   ColourConstantImage  the colour constant image in range of [0, 1].
%   h1                   the lower threshold.
%   h2                   the higher threshold.
%
% Examples
%   im = imread('peppers.png');
%   imout = ColourConstancyProgressive(im);
%   figure; imshow(uint8(imout .* 255));
%
% See also: ColourConstancy
%

InputImage = im2double(InputImage);
[rows, cols, chns] = size(InputImage);

MeanImg = mean(InputImage, 3);

MeanChns = mean(mean(InputImage));
MeanPix = mean(MeanChns);
delta = MeanImg / (h1 - h2) - h2 / (h1 - h2);

ColourConstantImage = zeros(rows, cols, chns);
for i = 1:chns
  ichan = InputImage(:, :, i);
  kchan = zeros(rows, cols);
  LowerH1 = 1.0 / mean(ichan(ichan >= h1));
  DeltaH1H2 = delta(MeanImg >= h2 & MeanImg <= h1);
  kchan(MeanImg >= h1) = LowerH1;
  kchan(MeanImg <= h2) = MeanPix / MeanChns(:, :, i);
  kchan(MeanImg >= h2 & MeanImg <= h1) = (1 - DeltaH1H2) * LowerH1 + DeltaH1H2 * LowerH1;
  ColourConstantImage(:, :, i) = kchan .* InputImage(:, :, i);
end

end
