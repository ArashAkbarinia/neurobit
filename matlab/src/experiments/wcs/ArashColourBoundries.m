function ChipsTable = ArashColourBoundries()
%ArashColourBoundries Summary of this function goes here
%   Detailed explanation goes here

FunctionPath = mfilename('fullpath');
ChipsTablePath = strrep(FunctionPath, ['matlab', filesep, 'src', filesep, 'experiments', filesep, 'wcs', filesep, 'ArashColourBoundries'], ['matlab', filesep, 'data', filesep, 'mats', filesep, 'colourcategorisation', filesep, 'ArashColourBoundries.mat']);
ChipsTableMat = load(ChipsTablePath);

ChipsTable = ChipsTableMat.ChipsTable();

end
