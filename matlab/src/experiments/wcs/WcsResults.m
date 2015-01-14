function ChipsTable = WcsResults(ConvertToEllipsoidColours)
%WcsResults Summary of this function goes here
%   Detailed explanation goes here

if nargin < 1
  ConvertToEllipsoidColours = false;
end

ChipsTable = BerlinKayColourBoundries(ConvertToEllipsoidColours);

end
