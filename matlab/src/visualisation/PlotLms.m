function FigureNumber = PlotLms(InputImage)
%PlotLms  plots the original image along with its L, M and S channels,
%
% inputs
%   InputImage  the input image in RGB colour space.
%
% outputs
%   FigureNumber  the reference to the figure.
%

FigureNumber = figure('name', 'LMS Channels');
subplot(2, 2, 1); imshow(InputImage); title('original');

imlms = rgb2lms(InputImage);

rch = imlms(:, :, 1);
gch = imlms(:, :, 2);
bch = imlms(:, :, 3);

lim = ColouredImageRedGreen(rch);
mim = ColouredImageGreen(gch);
sim = ColouredImageBlue(bch);

subplot(2, 2, 2); imshow(lim); title('L Channel');
subplot(2, 2, 3); imshow(mim); title('M Channel');
subplot(2, 2, 4); imshow(sim); title('S Channel');

end
