function KernelsBank = GaborBank(frequencies, orientations)
%GaborBank generates a bank of Gabor kernels.
%
% inputs
%   frequencies   desired frequencies.
%   orientations  desired orientations. It can be a number or list.
%
% outputs
%   KernelsBank   created kernels bank. Rows (x dimension) corresponds to
%                 frequency differences. Columns (y dimension) corresponds
%                 to orientation differences.
%
% See also GaborKernel2
%

% TODO: support for both list and number for frequency and orientation.

u = frequencies;
v = orientations;

KernelsBank = cell(u, v);

MinFrequency = 0.05;
MaxFrequency = 0.25;
FrequencyIncreament = (MaxFrequency - MinFrequency) / u;
bandwidth = 1;
offset = 0;
scale = 1;

for f = 1:u
  frequency = FrequencyIncreament * (f - 1) + MinFrequency;
  for o = 1:v
    theta = ((o - 1) / v) * pi;
    KernelsBank{f, o} = GaborKernel2(theta, [], [], bandwidth, frequency, offset, scale);
  end
end

end
