function EvalReport = FittingSliceVsEllipse(ColourFrontiers, ColourSpaceCentre, FitBorderwise)
%FittingSliceVsEllipse Summary of this function goes here
%   Detailed explanation goes here

if nargin < 3
  FitBorderwise = false;
end

ColourNames = fieldnames(ColourFrontiers);

luminances = [36, 47, 58, 76, 81, 86];
EvalReport = struct();

for i = 1:numel(ColourNames)
  CurrentColour = ColourFrontiers.(ColourNames{i});
  EvalReport.(ColourNames{i}) = struct();
  for lum = luminances
    LumName = ['lum', num2str(lum)];
    EvalReport.(ColourNames{i}).(LumName) = struct();
    LumPoints3 = CurrentColour.GetBorder(lum);
    if ~isempty(LumPoints3)
      LumPoints2 = LumPoints3(:, 1:2);
      % fitting to ellipse
      CurrentEllipse = FitPointsToEllipses(LumPoints2);
      [eldis, ~] = DistanceEllipse(LumPoints2, CurrentEllipse);
      EvalReport.(ColourNames{i}).(LumName).EllipseDistance = mean(eldis);
      % fitting to slice
      if FitBorderwise
        NeighbourNames = CurrentColour.GetNeighbourNames(lum);
        nNeighbours = numel(NeighbourNames);
        LineDistances = zeros(nNeighbours, 1);
        for k = 1:numel(NeighbourNames)
          LumPoints3 = CurrentColour.GetBorderWithColour(lum, NeighbourNames{k});
          LumPoints2 = LumPoints3(:, 1:2);
          [~, lidis] = FitPointsToLine(LumPoints2);
          LineDistances(k) = mean(lidis);
        end
        EvalReport.(ColourNames{i}).(LumName).SliceDistance = mean(LineDistances);
      else
        CurrentSlice = FitPointsToSlices(LumPoints2, ColourSpaceCentre);
        EvalReport.(ColourNames{i}).(LumName).SliceDistance = mean(CurrentSlice.error);
      end
    else
      EvalReport.(ColourNames{i}).(LumName).EllipseDistance = 0;
      EvalReport.(ColourNames{i}).(LumName).SliceDistance = 0;
    end
  end
end

SliceDistance = 0;
EllipseDistance = 0;
numlums = 0;
for i = 1:numel(ColourNames)
  for lum = luminances
    LumName = ['lum', num2str(lum)];
    SliceDistance = EvalReport.(ColourNames{i}).(LumName).SliceDistance + SliceDistance;
    EllipseDistance = EvalReport.(ColourNames{i}).(LumName).EllipseDistance + EllipseDistance;
    numlums = numlums + 1;
  end
end

fprintf('The mean distance for slice %f\n', SliceDistance / numlums);
fprintf('The mean distance for ellipse %f\n', EllipseDistance / numlums);

end
