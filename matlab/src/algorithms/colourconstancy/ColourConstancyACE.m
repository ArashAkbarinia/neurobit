function ColourConstantImage = ColourConstancyACE(InputImage, alpha)
%ColourConstancyACE applies the automatic colour equalisation (ACE).
%   This is the Matlab implementation of 'Pascal Getreuer, Automatic Color
%   Enhancement (ACE) and its Fast Implementation, Image Processing On Line
%   , 2 (2012), pp. 266–277. http://dx.doi.org/10.5201/ipol.2012.g-ace'.
%
% Inputs
%   InputImage  the input image.
%   alpha       the slope parameter (>=1), larger implies stronger
%               enhancement, default is 8.
%
% Outputs
%   ColourConstantImage  the colour constant image in range of [0, 1].
%
% Examples
%   im = imread('peppers.png');
%   imout = ColourConstancyACE(im);
%   figure; imshow(uint8(imout .* 255));
%
% See also: ColourConstancy
%

if nargin < 2
  alpha = 8;
end

degree = 9;

SlopeCoeff = ...
  [
  % alpha = 1
  [1.0, 0, 0, 0, 0];
  % alpha = 1.5
  [1.33743875, 1.55213754, -3.02825657, -0.12350511, 1.28325061];
  % alpha = 2
  [1.85623249, 3.82397125, -19.70879455, 26.15510902, -11.15375327];
  % alpha = 2.5
  [2.79126397, -1.30687551, -10.57298680, 20.02623286, -9.98284231];
  % alpha = 3
  [3.51036396, -6.31644952, 0.92439798, 9.32834829, -6.50264005];
  % alpha = 3.5
  [4.15462973, -11.85851451, 16.03418150, -7.07985902, -0.31040920];
  % alpha = 4
  [4.76270090, -18.23743983, 36.10529118, -31.35677926, 9.66532431];
  % alpha = 4.5
  [5.34087782, -25.67018163, 63.87617747, -70.15437134, 27.66951403];
  % alpha = 5
  [5.64305564, -28.94026159, 74.52401661, -83.54012582, 33.39343065];
  % alpha = 5.5
  [5.92841230, -32.11619291, 85.01764165, -96.84966316, 39.11863693];
  % alpha = 6
  [6.19837979, -35.18789052, 95.28157108, -109.95601312, 44.78177264];
  % alpha = 6.5
  [6.45529995, -38.16327397, 105.31193936, -122.83169063, 50.36462504];
  % alpha = 7
  [6.69888108, -41.02503190, 115.02784036, -135.35603880, 55.81014424];
  % alpha = 7.5
  [6.92966632, -43.76867314, 124.39645141, -147.47363378, 61.09053024];
  % alpha = 8
  [7.15179080, -46.43557440, 133.54648929, -159.34156394, 66.27157886]
  ];

i = int8((2 * alpha + 0.5) - 2);
if i < 1
  i = 1;
elseif i > 15
  i = 15;
end

PolyCoeffs = zeros(10 * 10, 1);
for n = 0:degree
  if mod(n, 2) == 0
    m1 = n + 1;
  else
    m1 = n;
  end
  for m = m1:2:degree
    PolyCoeffs(10 * n + m + 1) = ((-1) ^ (m - n + 1)) * SlopeCoeff(i, (m - 1) / 2 + 1) * BinomCoeff(m, n);
  end
end

InputImage = im2double(InputImage);
[rows, cols, chns] = size(InputImage);

ImageSqr = InputImage .^ 2;

% computing the FFT of omega(x, y) = 1 / sqrt(x ^ 2 + y ^ 2)
OmegaSum = 0;
omega = zeros(rows + 1, cols + 1);
for i = 0:rows
  for j = 0:cols
    if i == 0 && j == 0
      omega(i + 1, j + 1) = 0;
    else
      omega(i + 1, j + 1) = 1 ./ sqrt(i .^ 2 + j .^ 2);
    end
    if i == 0 || i == rows
      factor = 1;
    else
      factor = 2;
    end
    if j == 0 || j == cols
      factor = factor * 1;
    else
      factor = factor * 2;
    end
    OmegaSum = OmegaSum + factor * omega(i + 1, j + 1);
  end
end

OmegaSum = OmegaSum * 4 * (rows + 1) * (cols + 1);
for i = 0:rows
  for j = 0:cols
    omega(i + 1, j + 1) = omega(i + 1, j + 1) / OmegaSum;
  end
end

omegafft = dcti2(omega);
omegafft = omegafft(1:rows, 1:cols);

% special case for n = zero term
m = degree + 1;
a = PolyCoeffs(m);
while m > 2
  m = m - 2;
  a = a .* ImageSqr + PolyCoeffs(m);
end
ColourConstantImage = a .* InputImage;

% the rest of cases
for iter = 0:(degree - 1)
  n = 1 + mod(iter, degree);
  m = degree + 1;
  a = PolyCoeffs((degree + 1) * n + m);
  while m - n > 2
    m = m - 2;
    a = a .* ImageSqr + PolyCoeffs((degree + 1) * n + m);
  end
  
  if mod(n, 2) == 0
    a = a .* InputImage;
  end
  
  ImagePowN = InputImage .^ n;
  for i = 1:chns
    Blurred = dct2(ImagePowN(:, :, i));
    Blurred = Blurred .* (4 * sqrt(rows / 2) * sqrt(cols / 2));
    Blurred(1, :) = Blurred(1, :) .* sqrt(2.0);
    Blurred(:, 1) = Blurred(:, 1) .* sqrt(2.0);
    
    convolved = Blurred .* omegafft;
    convolved = convolved ./ (4 * sqrt(rows / 2) * sqrt(cols / 2));
    convolved(1, :) = convolved(1, :) ./ sqrt(2.0);
    convolved(:, 1) = convolved(:, 1) ./ sqrt(2.0);
    
    Blurred = idct2(convolved);
    Blurred = Blurred .* (2 * rows * 2 * cols);
    
    if length(a) == 1
      afactor = a;
    else
      afactor = a(:, :, i);
    end
    ColourConstantImage(:, :, i) = afactor .* Blurred + ColourConstantImage(:, :, i);
  end
end

MaxOut = max(max(ColourConstantImage));
for i = 1:chns
  MaxVal = -1e30;
  MaxVal = max(MaxVal, MaxOut(:, :, i));
  MaxVal = MaxVal * 2;
  ColourConstantImage(:, :, i) = 0.5 + ColourConstantImage(:, :, i) ./ MaxVal;
end

end

function f = BinomCoeff(m, n)

f = factorial(m) / ( factorial(n) * factorial(m - n));

end
