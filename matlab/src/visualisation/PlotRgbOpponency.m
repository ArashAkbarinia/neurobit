function FigureNumber = PlotRgbOpponency(InputImage)
%PlotRgbOpponency  plots the original image with its opponnent channels.
%
% inputs
%   InputImage  the input image in RGB colour space.
%
% outputs
%   FigureNumber  the reference to the figure.
%

FigureNumber = figure('name', 'RGB Opponency');
subplot(2, 2, 1:2); imshow(InputImage); title('original');

InputImage = double(InputImage);

rgim = ColouredImageRedGreen(InputImage(:, :, 1) - InputImage(:, :, 2));
ybim = ColouredImageYellowBlue(0.5 .* InputImage(:, :, 1) + 0.5 .* InputImage(:, :, 2) - InputImage(:, :, 3));

subplot(2, 2, 3); imshow(rgim); title('R-G Opponency');
subplot(2, 2, 4); imshow(ybim); title('Y-B Opponency');

end
