function [PlaneHistograms, BorderNames] = PlotPlaneHistogram(ColourFrontiers, luminance, RadiusOrAngle)
%PlotPlaneHistogram Summary of this function goes here
%
% inputs
%   ColourFrontiers  colour frontiers in the lab space
%   luminance        the desired luminance plane.
%   RadiusOrAngle    'radius' or 'angle'.
%
% outputs
%   PlaneHistograms  the histograms of each frontiers.
%   BorderNames      name of frontiers.
%

ColourNames = fieldnames(ColourFrontiers);

BorderNames = cell(0, 0);
PlaneHistograms = zeros(0, 0);

for i = 1:numel(ColourNames)
  if strcmpi(RadiusOrAngle, 'angle') && strcmpi(ColourNames{i}, 'grey')
    continue;
  elseif strcmpi(RadiusOrAngle, 'radius') && ~strcmpi(ColourNames{i}, 'grey')
    continue
  end
  CurrentColour = ColourFrontiers.(ColourNames{i});
  CurrentBorderNames = CurrentColour.GetNeighbourNames(luminance);
  for j = 1:length(CurrentBorderNames)
    if strcmpi(RadiusOrAngle, 'angle') && strcmpi(CurrentBorderNames{j}, 'grey')
      continue;
    end
    if isempty(BorderNames)
      DuplicateBorder = false;
    else
      PreviousBorders = ~cellfun('isempty', strfind(BorderNames(:, 2), ColourNames{i}));
      if ~PreviousBorders
        DuplicateBorder = false;
      else
        DuplicateBorder = ~cellfun('isempty', strfind(BorderNames(PreviousBorders, 1), CurrentBorderNames{j}));
      end
    end
    if ~DuplicateBorder
      if strcmpi(RadiusOrAngle, 'angle')
        PlaneHistograms(end + 1, :) = PlotFrontierAngleHistogram(CurrentColour.GetBorderWithColour(luminance, CurrentBorderNames{j})); %#ok
      elseif strcmpi(RadiusOrAngle, 'radius')
        PlaneHistograms(end + 1, :) = PlotFrontierRadiusHistogram(CurrentColour.GetBorderWithColour(luminance, CurrentBorderNames{j})); %#ok
      end
      BorderNames(end + 1, :) = {ColourNames{i}, CurrentBorderNames{j}}; %#ok
    end
  end
end

end
