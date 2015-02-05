function [WcsColourTable, GroundTruth] = SatfacesColourCube()

SatfacesMat = load('satfaces.mat');
WcsColourTable = [];
FieldNames = fieldnames(SatfacesMat.ColourPoints);
for i = 1:length(FieldNames)
  WcsColourTable = [WcsColourTable; SatfacesMat.ColourPoints.(FieldNames{i})]; %#ok
end

nColourPoints = size(WcsColourTable, 1);
GroundTruth = zeros(nColourPoints, 1, 11);
LastIndex = 1;
ProbabilityFactor = 1;
for i = 1:length(FieldNames)
  nCurrentPoints = size(SatfacesMat.ColourPoints.(FieldNames{i}), 1);
  
  if nCurrentPoints > 0
    switch FieldNames{i}
      case {'g', 'green'}
        GroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 1) = ProbabilityFactor;
      case {'b', 'blue'}
        GroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 2) = ProbabilityFactor;
      case {'pp', 'purple'}
        GroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 3) = ProbabilityFactor;
      case {'pk', 'pink'}
        GroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 4) = ProbabilityFactor;
      case {'r', 'red'}
        GroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 5) = ProbabilityFactor;
      case {'o', 'orange'}
        GroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 6) = ProbabilityFactor;
      case {'y', 'yellow'}
        GroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 7) = ProbabilityFactor;
      case {'br', 'brown'}
        GroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 8) = ProbabilityFactor;
      case {'gr', 'grey'}
        GroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 9) = ProbabilityFactor;
      case {'w', 'white'}
        GroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 10) = ProbabilityFactor;
      case {'bl', 'black'}
        GroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 11) = ProbabilityFactor;
        
      case {'olive'}
        GroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, [1, 8]) = ProbabilityFactor;
      case {'maroon'}
        GroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 5) = ProbabilityFactor;
      case {'darkteal', 'teal'}
        GroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 1:2) = ProbabilityFactor;
      case {'magenta'}
        GroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 3:4) = ProbabilityFactor;
      case {'darkgreen', 'lightgreen'}
        GroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 1) = ProbabilityFactor;
      case {'navyblue', 'darkblue', 'lightblue', 'cyan', 'skyblue'}
        GroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 2) = ProbabilityFactor;
      case {'darkpurple'}
        GroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 3) = ProbabilityFactor;
      case {'darkred'}
        GroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 5) = ProbabilityFactor;
      case {'gold', 'mustard'}
        GroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 6:7) = ProbabilityFactor;
      case {'limegreen'}
        GroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 7) = ProbabilityFactor;
      case {'darkbrown'}
        GroundTruth(LastIndex:(LastIndex + nCurrentPoints - 1), 1, 8) = ProbabilityFactor;
        
      otherwise
        disp(FieldNames{i});
    end
    
    LastIndex = LastIndex + nCurrentPoints;
  end
end
WcsColourTable = uint8(WcsColourTable);

WcsColourTable = reshape(WcsColourTable, 512, 384, 3);
GroundTruth = reshape(GroundTruth, 512, 384, 11);

end
