function FigureNumber = PlotOpponency(InputImage)
%PlotOpponency  plots the original image with its opponnent channels.
%
% inputs
%   InputImage  the input image in RGB colour space.
%
% outputs
%   FigureNumber  the reference to the figure.
%


imlsm = rgb2lms(InputImage);

rgim(:, :, 1) =  imlsm(:, :, 1) - imlsm(:, :, 2);
rgim(:, :, 2) = -imlsm(:, :, 1) + imlsm(:, :, 2);
rgim(:, :, 3) = 0;
rgim = NormaliseChannel(rgim, [], [], [], []);

ybim(:, :, 1) =  imlsm(:, :, 1) + imlsm(:, :, 2) - imlsm(:, :, 3);
ybim(:, :, 2) =  imlsm(:, :, 1) + imlsm(:, :, 2) - imlsm(:, :, 3);
ybim(:, :, 3) = -imlsm(:, :, 1) - imlsm(:, :, 2) + imlsm(:, :, 3);
ybim = NormaliseChannel(ybim, [], [], [], []);

FigureNumber = figure;
subplot(2, 2, 1:2); imshow(InputImage);
subplot(2, 2, 3); imshow(rgim);
subplot(2, 2, 4); imshow(ybim);

end