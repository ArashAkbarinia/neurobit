function CrossOversReport = ReportMetamersSpectraCrossOvers(MetamerReport)
%ReportMetamersSpectraCrossOvers Summary of this function goes here
%   Detailed explanation goes here

FunctionPath = mfilename('fullpath');
[~, FunctionName, ~] = fileparts(FunctionPath);
FunctionRelativePath = ['matlab', filesep, 'src', filesep, 'algorithms', filesep, 'colouranalysis', filesep, 'reporting', filesep, FunctionName];

DataPath = ['matlab', filesep, 'data', filesep, 'mats', filesep, 'hsi', filesep];

AllSpectraPath = strrep(FunctionPath, FunctionRelativePath, [DataPath, 'AllSpectraUniformed.mat']);
AllSpectraMat = load(AllSpectraPath);

spectras = AllSpectraMat.spectra;
wavelengths = AllSpectraMat.wavelength;
clear AllSpectraMat;

ThresholdNames = fieldnames(MetamerReport.all.lths);
nLowThreshes = numel(ThresholdNames);
nHighThreshes = numel(fieldnames(MetamerReport.all.lths.th1.uths));

TmpReport = struct();
AllCrossOvers = [];
for i = 1:nLowThreshes
  LowThreshold = MetamerReport.all.lths.(ThresholdNames{i});
  TmpReport.(ThresholdNames{i}).lth = LowThreshold.lth;
  for j = 1:nHighThreshes
    HighThreshold = LowThreshold.uths.(['uth', num2str(j)]);
    MetamerPairs = HighThreshold.metamerpairs;
    [xi, yi] = ComputeCorssOverPerPair(MetamerPairs, spectras, wavelengths);
    TmpReport.(ThresholdNames{i}).uths.(['uth', num2str(j)]).uth = HighThreshold.uth;
    TmpReport.(ThresholdNames{i}).uths.(['uth', num2str(j)]).crossovers = [xi, yi];
    AllCrossOvers = [AllCrossOvers; xi, yi]; %#ok
  end
end

CrossOversReport.all.lths = TmpReport;
CrossOversReport.all.crossovers = AllCrossOvers;

end
