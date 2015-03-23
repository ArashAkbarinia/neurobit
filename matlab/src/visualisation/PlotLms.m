function FigureNumber = PlotLms(InputImage)
%PlotLms  plots the original image along with its L, M and S channels,
%
% inputs
%   InputImage  the input image in RGB colour space.
%
% outputs
%   FigureNumber  the reference to the figure.
%

imlsm = rgb2lms(InputImage);

l = imlsm(:, :, 1);
m = imlsm(:, :, 2);
s = imlsm(:, :, 3);

lim = l;
lim(:, :, 2:3) = 0;
lim = uint8(lim);

sim = s;
sim(:, :, 3) = sim(:, :, 1);
sim(:, :, 1:2) = 0;
sim = uint8(sim);

mim = m;
mim(:, :, 2) = mim;
mim(:, :, [1, 3]) = 0;
mim = uint8(mim);

FigureNumber = figure;
subplot(2, 2, 1); imshow(InputImage);
subplot(2, 2, 2); imshow(lim);
subplot(2, 2, 3); imshow(sim);
subplot(2, 2, 4); imshow(mim);

end
