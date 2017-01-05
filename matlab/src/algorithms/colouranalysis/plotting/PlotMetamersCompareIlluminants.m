function FigureHandler = PlotMetamersCompareIlluminants(IlluminantPairReport, WhichLth, WhichUth)
%PlotMetamersCompareIlluminants  Summary of this function goes here
%   Detailed explanation goes here

IllumNamesOrder = IlluminantPairReport.IllumNamesOrder;
IllumPairsPlot = IlluminantPairReport.IllumPairsPlot;
% LowHighAbs and LowHighPer the x axis is reverse (low values in the last
% rows)
lths = IlluminantPairReport.lths;
uths = IlluminantPairReport.uths;

nillus = numel(IllumNamesOrder);

if nargin < 2 || isempty(WhichLth)
  WhichLth = 1:length(lths);
else
  WhichLth = ismember(lths, WhichLth);
end
if nargin < 3 || isempty(WhichUth)
  WhichUth = 1:length(uths);
else
  % the flipping is beause LowHighAbs and LowHighPer the x axis is reverse
  % (low values in the last rows)
  WhichUth = fliplr(ismember(uths, WhichUth));
end

[nuth, nlth] = size(IllumPairsPlot{1, 2}.LowHighAbs);

LthUthAbsolute = zeros(nuth, nlth, nillus);

for i = 1:nillus
  for j = 1:nillus
    if i ~= j
      LthUthAbsolute(:, :, i) = LthUthAbsolute(:, :, i) + IlluminantPairReport.IllumPairsPlot{i, j}.LowHighAbs;
    end
  end
  LthUthAbsolute(:, :, i) = LthUthAbsolute(:, :, i) ./ (nillus - 1);
end

LthUthAbsolute = LthUthAbsolute(WhichUth, WhichLth, :);

AllMetamers = mean(mean(LthUthAbsolute, 1), 2);
AllMetamers = reshape(AllMetamers, 1, nillus);
RelativeAllMetamers = AllMetamers ./ max(AllMetamers);

AllIlluminantsMat = load('AllIlluminantsUniformed.mat');

FigureHandler = figure('name', 'Tested Illuminants');
hold on;
ColourMapInds = colormap('jet');
for i = 1:nillus
  CurrentIlluminantName = IlluminantPairReport.IllumNamesOrder{i};
  CurrentSpectra = AllIlluminantsMat.spectras.(CurrentIlluminantName);
  CurrentWavelength = AllIlluminantsMat.wavelengths.(CurrentIlluminantName);
  CurrentDisplayName = [AllIlluminantsMat.labels.(CurrentIlluminantName), ' ratio: [', num2str(RelativeAllMetamers(i)), ']', ' abs: [', num2str(AllMetamers(i)), ']'];
  cind = round(RelativeAllMetamers(i) * size(ColourMapInds, 1));
  plot(CurrentWavelength, CurrentSpectra ./ sum(CurrentSpectra), 'color', ColourMapInds(cind, :), 'DisplayName', CurrentDisplayName);
end

xlim([400, 700]);
legend('show', 'location', 'northoutside');

end
