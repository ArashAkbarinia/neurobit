function ChipsTable = WcsResults(ConvertToEllipsoidColours)
%WcsResults Summary of this function goes here
%   Detailed explanation goes here

if nargin < 1
  ConvertToEllipsoidColours = false;
end

ChipsTable1 = BerlinKayColourBoundries(ConvertToEllipsoidColours);
ChipsTable2 = SturgesWhitfielColourBoundries();

ChipsTable = (ChipsTable1 + ChipsTable2) / 2;

end
