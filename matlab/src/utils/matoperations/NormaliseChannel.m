function noarmalisedx = NormaliseChannel(x, a, b, mins, maxs)
%NormaliseChannel change range of data between a and b.
%   This function applies normalisation on each channel of the matrix. If
%   'a' and 'b' are not provided the matrix 'x' is is scaled to bring all
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

if isempty(a)
  a = 0.0;
end
if isempty(b)
  b = 1.0;
end

[rows, cols, chns] = size(x);

% TODO: make it generic for differnt channels.
if chns ~= 3 && cols ~= 3
  error('NormaliseChannel:wrongnumbers', 'NormaliseChannel only supports data in 3 channels.');
end

if chns == 1
  x = reshape(x, rows, cols / 3, 3);
end

x = double(x);
a = double(a);
b = double(b);

noarmalisedx = zeros(size(x));

if isempty(mins)
  mins = min(min(x));
end
if isempty(maxs)
  maxs = max(max(x));
end

for i = 1:3
  minv = mins(i);
  maxv = maxs(i);
  noarmalisedx(:, :, i) = a + (x(:, :, i) - minv) * (b - a) / (maxv - minv);
end

if chns == 1
  noarmalisedx = reshape(noarmalisedx, rows, cols);
end

end
