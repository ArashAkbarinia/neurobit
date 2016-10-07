function FigureNumber = PlotLmsOpponency(InputImage)
%PlotLmsOpponency  plots the original image with its LMS opponnecy.
%
% inputs
%   InputImage  the input image in RGB colour space.
%
% outputs
%   FigureNumber  the reference to the figure.
%

FigureNumber = figure('name', 'Opponency Channels');
subplot(2, 2, 1:2); imshow(InputImage); title('original');

imlms = rgb2lms(InputImage);

rgim = ColouredImageRedGreen(imlms(:, :, 1) - imlms(:, :, 2));
ybim = ColouredImageYellowBlue(0.5 .* imlms(:, :, 1) + 0.5 .* imlms(:, :, 2) - imlms(:, :, 3));
subplot(2, 2, 3); imshow(rgim); title('L-M Opponency');
subplot(2, 2, 4); imshow(ybim); title('S-(L+M) Opponency');

end
