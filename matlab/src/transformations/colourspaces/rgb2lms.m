function imlms = rgb2lms(imrgb)
% img_LMS = RGBtoLMS(img_in);
% img_in is the ugly LINEAR version !!

img_RGB = double(imrgb); % make sure of type double

% this is an intermediate step, converting into some standard color space
img_XYZ = RGB2XYZ_cr(img_RGB);

% for the next step, there are lots of possible ways
%    norm    = 'crossingandwhitepoint';
% 'A compromise between mapping the white locus while trying to be consistent with crossings.';

norm = 'unity';
% 'normalisation is such that the max value is 1 for all fundamentals';
imlms = xyz2lms(img_XYZ, norm);
% plane 1  is Long wavelength cone
% plane 2  is Medium wavelength cone
% plane 3  is Short wavelength cone

end

function y = RGB2XYZ_cr(x)
% convert an RGB triplet into XYZ using R and C calibration

% this matrix from Claudia and Rikesh
% after measuring Yxy of coloured sqares
Transf =    [0.2356    0.1804    0.1303
  0.1310    0.3750    0.0664
  0.0165    0.0665    0.6546];


y(:,:,1) = (x(:,:,1).*Transf(1,1) + x(:,:,2).*Transf(1,2) + x(:,:,3).*Transf(1,3));
y(:,:,2) = (x(:,:,1).*Transf(2,1) + x(:,:,2).*Transf(2,2) + x(:,:,3).*Transf(2,3));
y(:,:,3) = (x(:,:,1).*Transf(3,1) + x(:,:,2).*Transf(3,2) + x(:,:,3).*Transf(3,3));

end
