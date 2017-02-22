function MondrianDataset = ColourConstancyDatasetRanomMandrian(nimages, imwidth, imheight)
%ColourConstancyDatasetRanomMandrian Summary of this function goes here
%   Detailed explanation goes here

if nargin < 1
  nimages = 100;
end
if nargin < 2
  imwidth = 300;
end
if nargin < 3
  imheight = 300;
end

MondrianArrays = CreateMondrians(nimages, imwidth, imheight);

MondrianImages = zeros(imwidth, imheight, 3, nimages, 'uint8');
BiasedImages = zeros(imwidth, imheight, 3, nimages, 'uint8');

% adding by 0.2 so they wont be 0
illuminants = rand([nimages, 3]) + 0.2;
illuminants = illuminants ./ repmat(sum(illuminants, 2), [1, 3]);
for i = 1:nimages
  MondrianImages(:, :, 1, i) = MondrianArrays{i, 1};
  j = i + 1;
  if j > nimages
    j = j - nimages;
  end
  MondrianImages(:, :, 2, j) = MondrianArrays{i, 2};
  k = i + 2;
  if k > nimages
    k = k - nimages;
  end
  MondrianImages(:, :, 3, k) = MondrianArrays{i, 3};
  
  chr = im2double(MondrianArrays{i, 1});
  chg = im2double(MondrianArrays{i, 2});
  chb = im2double(MondrianArrays{i, 3});
  chr = uint8((chr .* illuminants(i, 1)) .* 255);
  chg = uint8((chg .* illuminants(i, 2)) .* 255);
  chb = uint8((chb .* illuminants(i, 3)) .* 255);
  BiasedImages(:, :, 1, i) = chr;
  BiasedImages(:, :, 2, i) = chg;
  BiasedImages(:, :, 3, i) = chb;
end

MondrianDataset.MondrianImages = MondrianImages;
MondrianDataset.BiasedImages = BiasedImages;
MondrianDataset.illuminants = illuminants;

end
