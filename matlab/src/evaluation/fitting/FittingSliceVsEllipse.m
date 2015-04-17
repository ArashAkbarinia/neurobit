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
    LumPoints3 = CurrentColour.GetBorder(lum);
    if ~isempty(LumPoints3)
      LumPoints2 = LumPoints3(:, 1:2);
      % fitting to ellipse
      CurrentEllipse = FitPointsToEllipses(LumPoints2);
      [eldis, ~] = DistanceEllipse(LumPoints2, CurrentEllipse);
      EvalReport.(ColourNames{i}).EllipseDistance = mean(eldis);
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
        EvalReport.(ColourNames{i}).SliceDistance = mean(LineDistances);
      else
        CurrentSlice = FitPointsToSlices(LumPoints2, ColourSpaceCentre);
        EvalReport.(ColourNames{i}).SliceDistance = mean(CurrentSlice.error);
      end
    else
      EvalReport.(ColourNames{i}).EllipseDistance = 0;
      EvalReport.(ColourNames{i}).SliceDistance = 0;
    end
  end
end

SliceDistance = 0;
EllipseDistance = 0;
for i = 1:numel(ColourNames)
  SliceDistance = EvalReport.(ColourNames{i}).SliceDistance + SliceDistance;
  EllipseDistance = EvalReport.(ColourNames{i}).EllipseDistance + EllipseDistance;
end

fprintf('The mean distance for slice %f\n', SliceDistance);
fprintf('The mean distance for ellipse %f\n', EllipseDistance);

end
