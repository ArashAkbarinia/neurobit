function OutImage = dcti2(InImage, mrows, ncols)
%DCTI2 2-D discrete cosine transform type I (DCT-I).
%   Applies dcti to a 2D matrix.
%
% Inputs
%   InImage  the input image
%   mrows    number of rows of the output image
%   ncols    number of cols of the output image
%
% Outputs
%   OutImage  discrete cosine transform of 'InImage'. If 'mrwos' and
%             'ncols' are provided matrix 'InImage' is padded with zeros or
%             tuncated to the size 'mrwos' and 'ncols' before transforming.
%             The matrix 'OutImage' is class double, has the same size  as
%             'InImage' and contains the discrete cosine transform
%             coefficients.
%
%   This transform can be inverted using the same function DCTI2.
%
% Examples
%   im = imread('peppers.png');
%   imgrey = rgb2gray(im);
%   imout = DCTI2(imgrey);
%   figure; imshow(log(abs(imout)), []);
%
% See also: dcti, dct, dct2
%

[m, n, c] = size(InImage);

if c > 1
  error('dcti2:no1chanel', 'this function supports only 1 channel 2D matrix')
end

% Basic algorithm.
if (nargin == 1),
  if (m > 1) && (n > 1),
    OutImage = dcti(dcti(InImage).').';
    return;
  else
    mrows = m;
    ncols = n;
  end
end

% Padding for vector input.
a = InImage;
if nargin == 2
  ncols = mrows(2);
  mrows = mrows(1);
end
mpad = mrows;
npad = ncols;
if m == 1 && mpad > m
  a(2, 1) = 0;
  m = 2;
end
if n == 1 && npad > n
  a(1, 2) = 0;
  n = 2;
end
% For row vector.
if m == 1
  mpad = npad;
  npad = 1;
end

% Transform.
OutImage = dcti(a, mpad);
if m > 1 && n > 1
  OutImage = dcti(OutImage.', npad).';
end

end
