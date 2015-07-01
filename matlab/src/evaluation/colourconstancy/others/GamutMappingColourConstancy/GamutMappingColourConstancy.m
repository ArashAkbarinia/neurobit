function EstimatedLuminance = GamutMappingColourConstancy(CurrentImage)
%GamutMappingColourConstancy Summary of this function goes here
%   Detailed explanation goes here

load('example_canonical_gamuts.mat');

curr_canonical = example_canonical_gamut_1grad;
njet_type = '1grad';
[EstimatedLuminance, ~] = gamut_mapping(CurrentImage, curr_canonical, njet_type, 3);

end

