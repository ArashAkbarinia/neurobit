function [WcsColourTable, GroundTruth] = SatfacesColourCube()

SatfacesMat = load('satfaces.mat');
[WcsColourTable, GroundTruth] = ColourStruct2MatChans(SatfacesMat.ColourPoints);

WcsColourTable = reshape(WcsColourTable, 512, 384, 3);
GroundTruth = reshape(GroundTruth, 512, 384, 11);

end
