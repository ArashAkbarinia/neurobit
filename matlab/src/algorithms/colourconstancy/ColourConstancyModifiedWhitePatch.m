function ColourConstantImage = ColourConstancyModifiedWhitePatch(InputImage, thresholds)
%ColourConstancyModifiedWhitePatch  applies the modified white patch
%                                   algorithm.
%
% Inputs
%   InputImage  the input image.
%
% Outputs
%   ColourConstantImage  the colour constant image in range of [0, 1].
%   thresholds           the lower thresholds.
%
% Examples
%   im = imread('peppers.png');
%   imout = ColourConstancyModifiedWhitePatch(im, 100);
%   figure; imshow(uint8(imout .* 255));
%
% See also: ColourConstancyWhitePatch, ColourConstancy
%

InputImage = im2double(InputImage);
[~, ~, chns] = size(InputImage);

% TODO: add warning if the thresholds are over the range of the image
thresholds = thresholds ./ 255;

k = zeros(1, 1, chns);
for i = 1:chns
  ichan = InputImage(:, :, i);
  k(:, :, i) = 1.0 / mean(ichan(ichan > thresholds(i)));
end

ColourConstantImage = MatChansMulK(InputImage, k);

end
