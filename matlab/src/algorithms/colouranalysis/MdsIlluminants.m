function [y, stress, disparities] = MdsIlluminants(IlluminantsMat, IlluminantsNames)
%MdsIlluminants Summary of this function goes here
%   Detailed explanation goes here

[y, stress, disparities] = mdscale(IlluminantsMat, 2, 'criterion', 'metricstress');

nIllus = numel(IlluminantsNames);

DistinguishableColors = distinguishable_colors(nIllus);

figure;
hold on;
for i = 1:nIllus
  WhichNumber = num2str(i);
  plot(y(i, 1), y(i, 2), 'o', 'color', DistinguishableColors(i, :), ...
    'markersize', 8, 'markerfacecolor', 'w', 'displayname', [WhichNumber, ' - ' IlluminantsNames{i}], ...
    'markers', 8, 'markerfacecolor', 'None');
  text(y(i, 1), y(i, 2), WhichNumber, 'FontSize', 8, 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
end
axis equal;
legend('show', 'location', 'eastoutside');
xlabel('Dimension 1 (-)', 'fontsize', 8, 'fontweight', 'b')
ylabel('Dimension 2 (-)', 'fontsize', 8, 'fontweight', 'b')
set(gca,'FontWeight','bold')

end
