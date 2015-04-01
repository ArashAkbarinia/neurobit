function [OurVertical, OurHorizontal] = SurroundModulationEdgeDetector(im)
%SurroundModulationEdgeDetector Summary of this function goes here
%   Detailed explanation goes here

h = SurroundModulationFilter();

% h(:, [1:7, 11:17]) = 0;
% h(1:7, 1:7) = 0;
% h(1:7, 11:17) = 0;
% h(11:17, 1:7) = 0;
% h(11:17, 11:17) = 0;

figure;
subplot(2, 2, 1);
imshow(im); title('Original Image');
subplot(2, 2, 2);
imagesc(h); title('Our Filter');
subplot(2, 2, 3);
% OurVertical = nlfilter(im2double(im), [size(h, 1), size(h, 2)], @(x) OurEdgeDetector(h, x));
OurVertical = imfilter(im, h, 'symmetric');
imshow(OurVertical); title('Vertical Edges');
subplot(2, 2, 4);
% OurHorizontal = nlfilter(im2double(im), [size(h, 1), size(h, 2)], @(x) OurEdgeDetector(h', x));
OurHorizontal = imfilter(im, h', 'symmetric');
imshow(OurHorizontal); title('Horizontal Edges');

% figure;
% OtherFilter = fspecial('sobel');
% subplot(2, 2, 1);
% imshow(im); title('Original Image');
% subplot(2, 2, 2);
% imagesc(OtherFilter); title('Sobel Filter');
% subplot(2, 2, 3);
% OtherVertical = imfilter(im, OtherFilter, 'symmetric');
% imshow(OtherVertical); title('Vertical Edges');
% subplot(2, 2, 4);
% OtherHorizontal = imfilter(im, OtherFilter', 'symmetric');
% imshow(OtherHorizontal);  title('Horizontal Edges');

end

function GradientVal = OurEdgeDetector(h, x)

% CentreContrast = MichelsonContrast(x);

CentreSize = 3;
hc = ones(1, CentreSize);
xcen = x(13:15, 13:15);
MeanCentre = conv2(xcen, hc / CentreSize ^ 2, 'same');
SigmaCentre = sqrt(conv2(xcen .^ 2, hc / CentreSize ^ 2, 'same') - MeanCentre .^ 2);
% CentreContrast = mean(SigmaCentre(:));
CentreContrast = std(xcen(:));

if CentreContrast > 0.10
  TmpCentre = h(13:15, 13:15);
  TmpSurround = h(10:18, 10:18);
  TmpNear = h(7:21, 7:21);
  TmpFar = h(4:24, 4:24);
  h(4:24, 4:24) = 0;
  h(7:21, 7:21) = TmpNear;
  h(10:18, 10:18) = -TmpSurround;
  h(13:15, 13:15) = TmpCentre;
elseif CentreContrast < 0.05
  TmpCentre = h(13:15, 13:15);
  TmpSurround = h(10:18, 10:18);
  TmpNear = h(7:21, 7:21);
  TmpFar = h(4:24, 4:24);
  
  FarSize = 21;
  hc = ones(1, FarSize);
  xfar = x(4:24, 4:24);
  xfar(7:21, 7:21) = 0;
  MeanFar = conv2(xfar, hc / FarSize ^ 2, 'same');
  SigmaFar = sqrt(conv2(xfar .^ 2, hc / FarSize ^ 2, 'same') - MeanFar .^ 2);
  %   FarContrast = mean(SigmaFar(:));
  FarContrast = std(xfar(:));
  if FarContrast < 0.10
    h(4:24, 4:24) = TmpFar * 10;
    h(7:21, 7:21) = TmpNear;
  end
  
  h(10:18, 10:18) = TmpSurround * 4;
  h(13:15, 13:15) = TmpCentre * 2;
end
GradientVal = sum(sum((h .* x)));

end
