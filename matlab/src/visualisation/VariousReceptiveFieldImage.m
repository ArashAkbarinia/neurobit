function FigureNumber = VariousReceptiveFieldImage(InputImage)
%VariousReceptiveFieldImage  plots outcome of convolution with various type
%                            of receptive-fields, e.g., single-opponent and
%                            double-opponent.
%   https://www.ncbi.nlm.nih.gov/pubmed/21068298
%
% inputs
%   InputImage  the input RGB image
%
% outputs
%   FigureNumber  the ID of plotted figure.
%

% initialise the figure
FigureNumber = figure('name', 'Various model receptive fields');
rows = 3;
cols = 5;
position = cols;

% plot the original RGB image
subplot(rows, cols, 1:cols);
imshow(InputImage); title('Original image');
position = position + 1;

InputImage = im2double(InputImage);

g1sigma = 1.5;
g2sigma = 2 * g1sigma;
g1 = imfilter(InputImage, GaussianFilter2(g1sigma), 'symmetric');
g2 = imfilter(InputImage, GaussianFilter2(g2sigma), 'symmetric');

d1 = imfilter(g1, Gaussian2Gradient1(g1sigma, 0), 'symmetric');

sorg = g1(:, :, 1) - g2(:, :, 2);
soyb = 0.5 .* g1(:, :, 1) + 0.5 .* g1(:, :, 2) - g2(:, :, 3);

corg = g1(:, :, 1) - g1(:, :, 2);
coyb = 0.5 .* g1(:, :, 1) + 0.5 .* g1(:, :, 2) - g1(:, :, 3);

d1rg = d1(:, :, 1) + d1(:, :, 2);
d1yb = 0.5 .* d1(:, :, 1) + 0.5 .* d1(:, :, 2) + d1(:, :, 3);

cdrg = g1(:, :, 1) + g2(:, :, 2) - g2(:, :, 1) - g1(:, :, 2);
cdyb = 0.5 .* g1(:, :, 1) + 0.5 .* g1(:, :, 2) + g2(:, :, 3) - 0.5 .* g2(:, :, 1) - 0.5 .* g2(:, :, 2) - g1(:, :, 3);

udrg = d1(:, :, 1) - 0.5 .* d1(:, :, 2);
udyb = 0.5 .* d1(:, :, 1) + 0.5 .* d1(:, :, 2) - 0.5 .* d1(:, :, 3);

% red-greens
subplot(rows, cols, position);
imshow(ColouredImageRedGreen(sorg)); title('Single-opponent R-G');
position = position + 1;

subplot(rows, cols, position);
imshow(ColouredImageRedGreen(corg)); title('Centre-only Opponent R-G');
position = position + 1;

subplot(rows, cols, position);
imshow(ColouredImageRedGreen(d1rg)); title('Oriented Non-opponent R-G');
position = position + 1;

subplot(rows, cols, position);
imshow(ColouredImageRedGreen(cdrg)); title('Concentric Double-opponent R-G');
position = position + 1;

subplot(rows, cols, position);
imshow(ColouredImageRedGreen(udrg)); title('Oriented Double-opponent R-G');
position = position + 1;

% yellow-blues
subplot(rows, cols, position);
imshow(ColouredImageYellowBlue(soyb)); title('Single-opponent Y-B');
position = position + 1;

subplot(rows, cols, position);
imshow(ColouredImageYellowBlue(coyb)); title('Centre-only Opponent Y-B');
position = position + 1;

subplot(rows, cols, position);
imshow(ColouredImageYellowBlue(d1yb)); title('Oriented Non-opponent Y-B');
position = position + 1;

subplot(rows, cols, position);
imshow(ColouredImageYellowBlue(cdyb)); title('Concentric Double-opponent Y-B');
position = position + 1;

subplot(rows, cols, position);
imshow(ColouredImageYellowBlue(udyb)); title('Oriented Double-opponent Y-B');

figure;
subplot(1, 2, 1);
imshow(ColouredImageRedGreen(sorg)); title('Single-opponent R-G');
subplot(1, 2, 2);
imshow(ColouredImageYellowBlue(soyb)); title('Single-opponent Y-B');

figure;
subplot(1, 2, 1);
imshow(ColouredImageRedGreen(corg)); title('Centre-only Opponent R-G');
subplot(1, 2, 2);
imshow(ColouredImageYellowBlue(coyb)); title('Centre-only Opponent Y-B');

figure;
subplot(1, 2, 1);
imshow(ColouredImageRedGreen(d1rg)); title('Oriented Non-opponent R-G');
subplot(1, 2, 2);
imshow(ColouredImageYellowBlue(d1yb)); title('Oriented Non-opponent Y-B');

figure;
subplot(1, 2, 1);
imshow(ColouredImageRedGreen(cdrg)); title('Concentric Double-opponent R-G');
subplot(1, 2, 2);
imshow(ColouredImageYellowBlue(cdyb)); title('Concentric Double-opponent Y-B');

figure;
subplot(1, 2, 1);
imshow(ColouredImageRedGreen(udrg)); title('Oriented Double-opponent R-G');
subplot(1, 2, 2);
imshow(ColouredImageYellowBlue(udyb)); title('Oriented Double-opponent Y-B');

end
