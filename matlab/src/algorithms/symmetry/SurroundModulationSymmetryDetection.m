function SymmetryImage = SurroundModulationSymmetryDetection(InputImage)
%SurroundModulationSymmetryDetection

% just for now will work on colours later
if size(InputImage, 3) == 3
  InputImage = rgb2gray(InputImage);
end

% convert the image to the range of 0 to 1
InputImage = im2double(InputImage);

% size of RF in LGN
LgnSigma = 0.5;
InputImage = imfilter(InputImage, GaussianFilter2(LgnSigma), 'replicate');
% InputImage = imresize(InputImage, 0.25);

nlevels = 4;
nangles = 1;

SymmetryImage = DoV1(InputImage, nangles, nlevels, LgnSigma);
SymmetryImage = DoHigherAreas(SymmetryImage, nangles);

end

function d = NonMaxChannel(d, t)

for i = 1:size(d, 3)
  d(:, :, i) = d(:, :, i) ./ max(max(d(:, :, i)));
  d(:, :, i) = nonmax(d(:, :, i), t(:, :, i));
  d(:, :, i) = max(0, min(1, d(:, :, i)));
end

end

function SymmetryImage = DoHigherAreas(SymmetryImage, nangles)

SymmetryImage = sum(SymmetryImage, 4);

% StdSymmetry = std(SymmetryImage, [], 5);
[SymmetryImage, FinalOrientations] = max(SymmetryImage, [], 5);
% SymmetryImage = SymmetryImage .* StdSymmetry;

% figure
% for i = 1:4
%   subplot(2,4,i),imshow(SymmetryImage(:,:,:,i), []);
%   subplot(2,4,i+4),imshow(StdSymmetry(:,:,:,i), []);
% end

% SymmetryImage = 0.25 .* SymmetryImage(:, :, :, 1) + ...
%   0.50 .* SymmetryImage(:, :, :, 2) + 0.75 .* SymmetryImage(:, :, :, 3) + ...
%   1.00 .* SymmetryImage(:, :, :, 4);

SymmetryImage = SymmetryImage ./ max(SymmetryImage(:));

UseNonMax = true;

if UseNonMax
  FinalOrientations = (FinalOrientations - 1) * pi / nangles;
  FinalOrientations = mod(FinalOrientations + pi / 2, pi);
  SymmetryImage = NonMaxChannel(SymmetryImage, FinalOrientations);
  SymmetryImage([1, end], :) = 0;
  SymmetryImage(:, [1, end]) = 0;
  SymmetryImage = SymmetryImage ./ max(SymmetryImage(:));
end

end

function SymmetryImage = DoV1(InputImage, nangles, nlevels, LgnSigma)

[rows, cols, chns] = size(InputImage);
SymmetryImage = zeros(rows, cols, chns, nlevels, nangles);

% how many times the neurons in V1 are larger than LGN?
lgn2v1 = 2.7 * 2.7; % FIXME v1 is not this big
wbSigma = LgnSigma * lgn2v1;
rgSigma = LgnSigma * lgn2v1;
ybSigma = LgnSigma * lgn2v1;
params(1, :) = wbSigma;
params(2, :) = rgSigma;
params(3, :) = ybSigma;

for i = 1:nlevels
  iiedge = SymmetryLinesForScale(InputImage, params, nangles, i);
  SymmetryImage(:, :, :, i, :) = iiedge;
end

end

function OutEdges = SymmetryLinesForScale(InputImage, params, nangles, clevel)

[w, h, d] = size(InputImage);

thetas = zeros(1, nangles);
for i = 1:nangles
  thetas(i) = (i - 1) * pi / nangles + (pi / 2); % FIXME remove pi / 2
end

OutEdges = zeros(w, h, d, nangles);
for c = 1:d
  OutEdges(:, :, c, :) = DetectSymmetryLines(InputImage(:, :, c), params(c, 1), thetas, c, clevel);
end

end

function SymmetryLines = DetectSymmetryLines(InputImage, sigma, thetas, colch, clevel)

[rows1, cols1, ~] = size(InputImage);

gresize = GaussianFilter2(0.3 * (clevel - 1));

% resize the image to current scale
InputImage = imfilter(InputImage, gresize, 'replicate');
InputImage = imresize(InputImage, 1 / (2.0 ^ (clevel - 1)));

[rows2, cols2, ~] = size(InputImage);

nThetas = length(thetas);
rfresponse = zeros(rows2, cols2, nThetas);

showme = true;

% in the same orientation, orthogonality suppresses and parallelism
% facilitates.
for t = 1:nThetas
  theta1 = thetas(t);
  
  GaussianKernel = GaussianFilter2(sigma, 0.3, 0, 0, theta1);
  dorf = Gaussian2Gradient1Elongated(GaussianKernel, theta1 + pi / 2);
%   dorf(:, :) = 0;
%   m = ceil(size(dorf, 2) / 2);
%   dorf(:, 1) = 1;
%   dorf(:, end) = -1;
%   dorf = Gaussian2Gradient1(sigma, theta1 + pi / 2, 0.5);
  doresponse = abs(imfilter(InputImage, dorf, 'replicate'));
  
  doresponse = NormaliseChannel(doresponse);
  if showme
    figure;
    subplot(2,2,1), imshow(doresponse,[0, 1]);
    subplot(2,2,2), imshow(dorf,[]);
  end
  
  theta2 = theta1 + pi / 2;
  GaussianKernel = GaussianFilter2(sigma * 10, 3, 0, 0, theta2);
%   porf = -Gaussian2Gradient2Elongated(GaussianKernel, 0);
%   porf = -Gaussian2Gradient2(sigma * 3, 0);
  porf = GaussianKernel;
  doresponse01 = abs(imfilter(1 - doresponse, porf, 'replicate'));  
  doresponse01 = NormaliseChannel(doresponse01);
  
  GaussianKernel = GaussianFilter2(sigma * 10, sigma * 10, 0, 0, theta1 + pi / 2);
  morf = Gaussian2Gradient1Elongated(GaussianKernel, theta1 + pi / 2);
  doresponse02 = abs(imfilter(1 - doresponse, morf, 'replicate'));  
  doresponse02 = NormaliseChannel(doresponse02);
  
  doresponse = doresponse01 .* 0.5 + (1 - doresponse02) .* 0.5;
  
  % set the borders along the direction of theta to 0, because it's not
  % possible to have symmetry lines close to the borders
  % FIXME do it with proper direction and and sigma
  if rad2deg(theta1) == 90 || rad2deg(theta1) == 270
    BorderLength = round(0.1 * cols2);
    doresponse(:, [1:BorderLength, cols2 - BorderLength:cols2]) = 0;
  elseif rad2deg(theta1) == 0 || rad2deg(theta1) == 180
    BorderLength = round(0.1 * rows2);
    doresponse([1:BorderLength, rows2 - BorderLength:rows2], :) = 0;
  end
  
  if showme
%     subplot(2,2,3), imshow(doresponse,[0, 1]);
    subplot(2,2,3), imshowpair(doresponse, InputImage);
    subplot(2,2,4), imshow(morf, []);
  end
  
  rfresponse(:, :, t) = doresponse;
end

% resize the resutl image to the original size
SymmetryLines = imresize(rfresponse, [rows1, cols1]);
SymmetryLines = imfilter(SymmetryLines, gresize, 'replicate');

SymmetryLines = SymmetryLines ./ max(SymmetryLines(:));

end

function g1 = Gaussian2Gradient1Elongated(GaussianKernel, theta)

[gx, gy] = gradient(GaussianKernel);
g1 = cos(theta) * gx + sin(theta) * gy;

end

function g2 = Gaussian2Gradient2Elongated(GaussianKernel, theta)

g1 = Gaussian2Gradient1Elongated(GaussianKernel, theta);

[gx, gy] = gradient(g1);

g2 = cos(theta) * gx + sin(theta) * gy;

end
