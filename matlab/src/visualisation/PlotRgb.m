function FigureNumber = PlotRgb(InputImage)
%PlotRgb  plots the original image along with its R, G, B channels,
%
% inputs
%   InputImage  the input image in RGB colour space.
%
% outputs
%   FigureNumber  the reference to the figure.
%

FigureNumber = figure('name', 'RGB Channels');
subplot(2, 2, 1); imshow(InputImage); title('original');

InputImage = double(InputImage);

rch = InputImage(:, :, 1);
gch = InputImage(:, :, 2);
bch = InputImage(:, :, 3);

lim = ColouredImageRedGreen(rch);
mim = ColouredImageGreen(gch);
sim = ColouredImageBlue(bch);

subplot(2, 2, 2); imshow(lim); title('R Channel');
subplot(2, 2, 3); imshow(mim); title('G Channel');
subplot(2, 2, 4); imshow(sim); title('B Channel');

end
