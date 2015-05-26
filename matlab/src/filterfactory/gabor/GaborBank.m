function KernelsBank = GaborBank(frequencies, orientations, MinFrequency, MaxFrequency)
%GaborBank generates a bank of Gabor kernels.
%
% inputs
%   frequencies   desired frequencies, it can be a number or list.
%   orientations  desired orientations, it can be a number or list.
%
% outputs
%   KernelsBank   created kernels bank. Rows (x dimension) corresponds to
%                 frequency differences. Columns (y dimension) corresponds
%                 to orientation differences.
%
% See also GaborKernel2
%

if nargin < 1 || isempty(frequencies)
  frequencies = 5;
end
if nargin < 2 || isempty(orientations)
  orientations = 4;
end

if length(frequencies) == 1
  u = frequencies;
  
  if nargin < 3 || isempty(MinFrequency)
    MinFrequency = 0.05;
  end
  if nargin < 4 || isempty(MaxFrequency)
    MaxFrequency = 0.45;
  end
  FrequencyIncreament = (MaxFrequency - MinFrequency) / u;
  
  frequencies = zeros(1, u);
  for f = 1:u
    frequencies(1, f) = FrequencyIncreament * (f - 1) + MinFrequency;
  end
else
  u = length(frequencies);
end

if length(orientations) == 1
  v = orientations;
  
  orientations = zeros(1, v);
  for o = 1:v
    orientations(1, o) = ((o - 1) / v) * pi;
  end
else
  v = length(orientations);
end

KernelsBank = cell(u, v);

bandwidth = 1;
offset = 0;
scale = 1;

for f = 1:u
  frequency = frequencies(1, f);
  for o = 1:v
    orientation = orientations(1, o);
    KernelsBank{f, o} = GaborKernel2(orientation, [], [], bandwidth, frequency, offset, scale);
  end
end

end
