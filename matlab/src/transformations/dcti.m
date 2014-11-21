function b = dcti(a, n)
%DCTI discrete cosine transform type I (DCT-I).
%   The DCT-I is exactly equivalent (up to an overall scale factor of 2),
%   to  a DFT of 2N-2 real numbers with even symmetry. For example, a DCT-I
%   of N=5 real numbers abcde is exactly equivalent to a DFT of eight real
%   numbers abcdedcb (even symmetry), divided by two.
%   Explanation http://en.wikipedia.org/wiki/Discrete_cosine_transform
%
% Inputs
%   a  the input signal
%   n  length of output vector
%
% Outputs
%   b  discrete cosine transform of 'a'. If 'n' is provided 'a' is padded
%      or truncated to length 'n' before transforming. The vector 'b' is 
%      the same size as 'a'  and contains the discrete cosine transform
%      coefficients.
%
%   If 'a' is a matrix, the dcti operation is applied to each column. This 
%   transform can be inverted using the same function DCTI.
%
% Examples
%   a = (1:100) + 50 * cos((1:100) * 2 * pi / 40)
%   b = DCTI(a);
%
% See also: dct, dcti2, dct2
%

narginchk(1, 2);

if ~isa(a, 'double')
  a = double(a);
end

if min(size(a)) == 1
  if size(a, 2) > 1
    do_trans = 1;
  else
    do_trans = 0;
  end
  a = a(:);
else
  do_trans = 0;
end
if nargin == 1,
  n = size(a, 1);
end
m = size(a, 2);

% Pad or truncate a if necessary
if size(a, 1) < n,
  aa = zeros(n,m);
  aa(1:size(a, 1), :) = a;
else
  aa = a(1:n, :);
end

% Form intermediate even-symmetric matrix.
y = zeros(2 * n - 2, m);
y(1:n, :) = aa;
y(n + 1:n + n - 2, :) = flipud(aa(2:n - 1, :));

% Perform FFT
b = fft(y);

if isreal(a)
  b = real(b);
end
if do_trans
  b = b.';
end

end
