function FigureHandler = PlotIlluminants(IllumNames)
%PlotIlluminants  plotting the illuminants tested for metamer analysis

FunctionPath = mfilename('fullpath');
[~, FunctionName, ~] = fileparts(FunctionPath);
FunctionRelativePath = ['matlab', filesep, 'src', filesep, 'algorithms', filesep, 'colouranalysis', filesep, 'plotting', filesep, FunctionName];

IlluminantsPath = strrep(FunctionPath, FunctionRelativePath, ['matlab', filesep, 'data', filesep, 'mats', filesep, 'hsi', filesep, 'AllIlluminants.mat']);
AllIlluminants = load(IlluminantsPath);

if nargin < 1
  IllumNames = fieldnames(AllIlluminants.spectras);
end

FigureHandler = figure('name', 'Tested Illuminants');
hold on;

for i = 1:numel(IllumNames)
  CurrentLabel = IllumNames{i};
  DisplayName = AllIlluminants.labels.(CurrentLabel);
  CurrentSpectra = AllIlluminants.spectras.(CurrentLabel);
  plot(AllIlluminants.wavelengths.(CurrentLabel), CurrentSpectra ./ max(CurrentSpectra), 'color', rand(1, 3), 'DisplayName', DisplayName);
end

legend('show');
xlim([400, 700]);

end
