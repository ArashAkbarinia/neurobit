function illus = SaveMetamersAllIllumMat(MetamerDiff, signals, nTops, wavelength, lab, wp, labels)
%SaveMetamersAllIllumMat  plots the metamers results
%   Detailed explanation goes here

if nargin < 3
  nTops = 9;
end
if nargin < 4 || isempty(wavelength)
  wavelength = 1:size(signals, 1);
end
if nargin < 5
  lab = [];
end
if nargin < 6
  wp = whitepoint('d65');
end
if nargin < 6
  labels = {};
end

MetamersDis = MetamerDiff.SgnlDiffs;
MetamersDis(MetamerDiff.metamers == 0) = -1;
MetamersDis(isinf(MetamersDis)) = -1;

UniqueDistances = sort(unique(MetamersDis(:)), 'descend');
UniqueDistances = UniqueDistances(UniqueDistances >= 0);
if UniqueDistances == 0
  illus = struct();
  return;
end
nTops = min(nTops, length(UniqueDistances));
c = 1 + size(lab, 2);

rgb = zeros(size(lab));
for i = 1:c - 1
  rgb(:, i, :) = applycform(lab(:, i, :), makecform('lab2srgb', 'AdaptedWhitePoint', wp(i, :)));
end

% this is the array that can be saved for visulation proposes
illus.rows = zeros(nTops, 1);
illus.cols = zeros(nTops, 1);
illus.signal1 = cell(nTops, 1);
illus.signal2 = cell(nTops, 1);
illus.wavelength1 = cell(nTops, 1);
illus.wavelength2 = cell(nTops, 1);
illus.rgbrows = zeros(nTops, c - 1, 3);
illus.rgbcols = zeros(nTops, c - 1, 3);

illus.labels = labels;

for i = 1:nTops
  [row, col] = find(MetamersDis == UniqueDistances(i));
  row = row(1);
  col = col(1);
  
  if ~iscell(wavelength)
    wavelength1 = wavelength;
    wavelength2 = wavelength;
    signal1 = signals(row, :, :);
    signal2 = signals(col, :, :);
  else
    wavelength1 = wavelength{row, :};
    wavelength2 = wavelength{col, :};
    signal1 = signals{row, :, :};
    signal2 = signals{col, :, :};
  end
  
  signal1 = reshape(signal1, size(signal1, 3), 1);
  signal2 = reshape(signal2, size(signal2, 3), 1);
  
  % illus stuff
  illus.rows(i) = row;
  illus.cols(i) = col;
  illus.signal1{i, :} = signal1;
  illus.signal2{i, :} = signal2;
  illus.wavelength1{i, :} = wavelength1;
  illus.wavelength2{i, :} = wavelength2;
  
  for j = 2:c
    illus.rgbrows(i, j - 1, :) = rgb(row, j - 1, :);
    illus.rgbcols(i, j - 1, :) = rgb(col, j - 1, :);
  end
end

end
