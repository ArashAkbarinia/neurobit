function [ ] = PlotPlanePoints(ColourFrontiers, luminance)
%PlotPlanePoints Summary of this function goes here
%   Detailed explanation goes here

ColourNames = fieldnames(ColourFrontiers);

figure;
hold on;
grid on;
view(90, 0);

for i = 1:numel(ColourNames)
  CurrentColour = ColourFrontiers.(ColourNames{i});
  for j = i + 1:numel(ColourNames)
    borders = CurrentColour.GetBorderWithColour(luminance, ColourNames{j});
    if ~isempty(borders)
      rgb = (ColourFrontiers.(ColourNames{i}).rgb + ColourFrontiers.(ColourNames{j}).rgb) / 2;
      plot3(borders(:, 1), borders(:, 2), borders(:, 3), '.', 'Color', rgb);
    end
  end
end

end
