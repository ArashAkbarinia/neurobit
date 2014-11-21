function matrixk = MatChansMulK(m, k)
%MatChansMulK scalar multiplication in each channel.
%
% Inputs
%   m  the input matrix
%   k  the scalar vector contains same numebr of chanels as matrix.
%
%   matrixk  the output matrix each chanel is multiplied by corresponding
%            'k' scalar, i.e. matrixk(:, :, 1) =  m(:, :, 1) .* k(1)
%

[rows, cols, chns] = size(m);

matrixk = zeros(rows, cols, chns);
for i = 1:chns
  matrixk(:, :, i) = k(:, :, i) .* m(:, :, i);
end

end
