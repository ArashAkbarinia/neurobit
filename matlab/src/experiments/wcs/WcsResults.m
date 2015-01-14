function ChipsTable = WcsResults()
%WcsResults Summary of this function goes here
%   Detailed explanation goes here

ChipsTable1 = BerlinKayColourBoundries(true);
ChipsTable2 = SturgesWhitfielColourBoundries();

ChipsTable = (ChipsTable1 + ChipsTable2) / 2;

end
