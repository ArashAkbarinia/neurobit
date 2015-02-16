function ChipsTable = WcsResults(sources)
%WcsResults Summary of this function goes here
%   Detailed explanation goes here

if nargin < 1
  sources = {'berlin', 'sturges', 'benavente', 'arash'};
end

ChipsTable = 0;

sources = lower(sources);
nsources = length(sources);
for i = 1:nsources;
  switch sources{i}
    case {'berlin'}
      TmpTable = BerlinKayColourBoundries(true);
      ArashTable = ArashColourBoundries();
      TmpTable([1, 10], 2:41, 9:11) = ArashTable([1, 10], 2:41, 9:11);
      ChipsTable = ChipsTable + TmpTable;
    case {'sturges'}
      TmpTable = SturgesWhitfielColourBoundries();
      ArashTable = ArashColourBoundries();
      TmpTable([1, 10], 2:41, 9:11) = ArashTable([1, 10], 2:41, 9:11);
      ChipsTable = ChipsTable + TmpTable;
    case {'benavente'}
      ChipsTable = ChipsTable + BenaventeColourBoundries();
    case {'joost'}
      ChipsTable = ChipsTable + ColourNamingTestImage(WcsChart(), 'joost', 0);
    case {'robert'}
      ChipsTable = ChipsTable + ColourNamingTestImage(WcsChart(), 'robert', 0);
    case {'arash'}
      ChipsTable = ChipsTable + ArashColourBoundries();
    otherwise
      disp(['Wrong category: ', sources{i}]);
  end
end

ChipsTable = ChipsTable / nsources;

end
