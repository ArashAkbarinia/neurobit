function FigureHandler = PlotIlluminants()
%PlotIlluminants  plotting the illuminants tested for metamer analysis

FunctionPath = mfilename('fullpath');
FunctionRelativePath = ['matlab', filesep, 'src', filesep, 'algorithms', filesep, 'colouranalysis', filesep, 'plotting', filesep, 'PlotIlluminants'];

ArtLightsPath = strrep(FunctionPath, FunctionRelativePath, ['data', filesep, 'dataset', filesep, 'hsi', filesep, 'lights', filesep, 'ArtLights.mat']);
ArtIlluminantsMat = load(ArtLightsPath);

IlluminantstPath = strrep(FunctionPath, FunctionRelativePath, ['matlab', filesep, 'data', filesep, 'mats', filesep, 'hsi', filesep, 'illuminants.mat']);
IlluminantsMat = load(IlluminantstPath);

FosterPath = strrep(FunctionPath, FunctionRelativePath, ['matlab', filesep, 'data', filesep, 'mats', filesep, 'hsi', filesep, 'FosterIlluminants.mat']);
FosterIlluminantsMat = load(FosterPath);

DayLightsPath = strrep(FunctionPath, FunctionRelativePath, ['data', filesep, 'dataset', filesep, 'hsi', filesep, 'lights', filesep, 'DayLights.mat']);
DayIlluminantsMat = load(DayLightsPath);

FigureHandler = figure('name', 'Tested Illuminants');
hold on;

for i = 1:4
  plot(ArtIlluminantsMat.wavelength, ArtIlluminantsMat.lights(:, i) ./ max(ArtIlluminantsMat.lights(:, i)), 'color', rand(1, 3), 'DisplayName', ArtIlluminantsMat.labels{i});
end
plot(IlluminantsMat.wavelength, IlluminantsMat.a ./ max(IlluminantsMat.a), 'color', rand(1, 3), 'DisplayName', 'a');
plot(IlluminantsMat.wavelength, IlluminantsMat.c ./ max(IlluminantsMat.c), 'color', rand(1, 3), 'DisplayName', 'c');
plot(IlluminantsMat.wavelength, IlluminantsMat.d65 ./ max(IlluminantsMat.d65), 'color', rand(1, 3), 'DisplayName', 'd65');
plot(FosterIlluminantsMat.wavelength, FosterIlluminantsMat.illum_25000 ./ max(FosterIlluminantsMat.illum_25000), 'color', rand(1, 3), 'DisplayName', 'd25000');
plot(FosterIlluminantsMat.wavelength, FosterIlluminantsMat.illum_4000 ./ max(FosterIlluminantsMat.illum_4000), 'color', rand(1, 3), 'DisplayName', 'd4000');

for i = 1:15
  plot(DayIlluminantsMat.wavelength, DayIlluminantsMat.sky(:, i) ./ max(DayIlluminantsMat.sky(:, i)), 'color', rand(1, 3), 'DisplayName', ['sky', num2str(i)]);
end

legend('show');

end
