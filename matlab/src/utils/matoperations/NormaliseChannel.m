function noarmalisedx = NormaliseChannel(x, a, b)
%NormaliseChannel change range of data between a and b.
%   This function applies normalisation on each channel of the matrix. If
%   'a' and 'b' are not provided the matrix 'x' is is scaled to brin all
%   values into the range [0, 1].
%
% Inputs
%   x  the input data.
%   a  the lower value of output, default 0.
%   b  the higher value of output, default 1.
%
% Outputs
%   noarmalisedx the output matrix between 'a' and 'b'.
%

if nargin < 3
  a = 0.0;
  b = 1.0;
end

[rows, cols, chns] = size(x);
x = double(x);
a = double(a);
b = double(b);

noarmalisedx = zeros(rows, cols, chns);
for i = 1:chns
  minv = min(min(x(:, :, i)));
  maxv = max(max(x(:, :, i)));
  noarmalisedx(:, :, i) = a + (x(:, :, i) - minv) * (b - a) / (maxv - minv);
end

end
