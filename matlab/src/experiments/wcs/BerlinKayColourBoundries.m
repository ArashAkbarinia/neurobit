function ChipsTable = BerlinKayColourBoundries(ConvertToEllipsoidColours)
%BerlinKayColourBoundries Summary of this function goes here
%   Detailed explanation goes here

if nargin < 1
  ConvertToEllipsoidColours = false;
end

FunctionPath = mfilename('fullpath');
TermsPath = strrep(FunctionPath, 'matlab/src/experiments/wcs/BerlinKayColourBoundries', 'data/WCS-Data-20110316/BK-term.txt');
DicPath = strrep(FunctionPath, 'matlab/src/experiments/wcs/BerlinKayColourBoundries', 'data/WCS-Data-20110316/BK-dict.txt');
ChipsTablePath = strrep(FunctionPath, 'matlab/src/experiments/wcs/BerlinKayColourBoundries', 'data/WCS-Data-20110316/cnum-vhcm-lab-new.txt');

WcsTerms = tdfread(TermsPath);
WcsDic = tdfread(DicPath);
WcsChips = tdfread(ChipsTablePath);

ColourTerms = WcsColourTerms(WcsTerms, 6);
LanguageDic = WcsLanguageDic(WcsDic, 6);

nchips = size(WcsChips.x0x23cnum, 1);
ChipsColours = zeros(nchips, 11);

nexperiments = size(ColourTerms, 1);

ChipNumbers = WcsChips.x0x23cnum;
for i = 1:nexperiments
  index = ~cellfun('isempty', strfind(LanguageDic(:, 2), ColourTerms{i, 4}));
  ColourIndex = LanguageDic{index, 3};
  ChipIndex = ColourTerms{i, 3};
  ChipsColours(ChipNumbers == ChipIndex, ColourIndex) = ChipsColours(ChipIndex, ColourIndex) + 1;
end

ChipsTable = WcsChipsTable(WcsChips, ChipsColours);

if ConvertToEllipsoidColours
  EllipsoidDicMatPath = strrep(FunctionPath, 'matlab/src/experiments/wcs/BerlinKayColourBoundries', 'matlab/data/mats/EllipsoidDic.mat');
  EllipsoidDicMat = load(EllipsoidDicMatPath);
  
  ChipsTableTmp = ChipsTable;
  for i = 1:11
    ChipsTable(:, :, EllipsoidDicMat.wcs2ellipsoid(i)) = ChipsTableTmp(:, :, i);
  end
end

end

function ColourTerms = WcsColourTerms(WcsTerms, LanguageNumber)

lterms = size(WcsTerms.x1, 1);
ColourTerms = cell(lterms, 4);
ColourTerms(:, 1) = num2cell(WcsTerms.x1);
ColourTerms(:, 2) = num2cell(WcsTerms.x11, [2, lterms]);
ColourTerms(:, 3) = num2cell(WcsTerms.x12, [2, lterms]);
ColourTerms(:, 4) = num2cell(WcsTerms.AZ, [2, lterms]);

if ~isempty(LanguageNumber)
  indeces = cellfun(@(x) x == LanguageNumber, ColourTerms(:, 1), 'UniformOutput', 1);
  ColourTerms = ColourTerms(indeces, :);
end

end

function LanguageDic = WcsLanguageDic(WcsDic, LanguageNumber)

ldic = size(WcsDic.x0x23lnum, 1);
LanguageDic = cell(ldic, 3);
LanguageDic(:, 1) = num2cell(WcsDic.x0x23lnum);
LanguageDic(:, 2) = num2cell(WcsDic.abbr, [2, ldic]);
for i = 1:ldic
  LanguageDic(i, 3) = num2cell(str2double(WcsDic.tnum(i, :)));
end

if ~isempty(LanguageNumber)
  indeces = cellfun(@(x) x == LanguageNumber, LanguageDic(:, 1), 'UniformOutput', 1);
  LanguageDic = LanguageDic(indeces, :);
end

end

function ChipsTable = WcsChipsTable(WcsChips, ChipsColours)

nchips = size(WcsChips.x0x23cnum, 1);
ChipsTable = zeros(10, 41, 11);

% converting the results to percentage
for i = 1:nchips
  SumAll = sum(ChipsColours(i, :));
  if SumAll > 0
    ChipsColours(i, :) = ChipsColours(i, :) ./ SumAll;
  else
    ChipsColours(i, :) = 0;
  end
end

x = 2;
y = 1;
ChipsTable(1, 1, :) = ChipsColours(1, :);
for i = 2:nchips
  ChipsTable(x, y, :) = ChipsColours(i, :);
  y = y + 1;
  if y == 42
    y = 1;
    x = x + 1;
  end
end

end
