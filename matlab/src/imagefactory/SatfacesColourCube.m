function [WcsColourTable, GroundTruth] = SatfacesColourCube(OutputImage)

if nargin < 1
  OutputImage = false;
end

SatfacesMat = load('satfaces.mat');
[WcsColourTable, GroundTruth] = ColourStruct2MatChans(SatfacesMat.ColourPoints);

if OutputImage
  WcsColourTable = reshape(WcsColourTable, 512, 384, 3);
  GroundTruth = reshape(GroundTruth, 512, 384, 11);
end

end
