function [MetamerMats, UniqueMetaners] = MetamerTestUfeSpectra(ColourReceptors, illuminants)

FunctionPath = mfilename('fullpath');
FunctionRelativePath = 'src/algorithms/colouranalysis/MetamerTestUfeSpectra';

FundamentalsPath = strrep(FunctionPath, FunctionRelativePath, 'data/mats/hsi/');

if nargin < 1 || isempty(ColourReceptors)
  ColourReceptorsMat = load([FundamentalsPath, 'XyzSpectralSensitivity.mat']);
  ColourReceptors.spectra = ColourReceptorsMat.Xyz1931SpectralSensitivity;
  ColourReceptors.wavelength = ColourReceptorsMat.wavelength;
end

if nargin < 2 || isempty(illuminants)
  IlluminantstPath = strrep(FunctionPath, FunctionRelativePath, 'data/mats/hsi/illuminants.mat');
  IlluminantsMat = load(IlluminantstPath);
  IlluminantName = 'd65';
  illuminants.spectra = IlluminantsMat.(IlluminantName);
  illuminants.wavelength = IlluminantsMat.wavelength;
  illuminants.wp = whitepoint(IlluminantName);
end

% making the illumiant and colour receptor the same size
[illuminants, ColourReceptors] = IntersectIlluminantColourReceptors(illuminants, ColourReceptors);

AllSpectra = ReadSpectraData();

% checkign the wp
if ~isfield(illuminants, 'wp')
  illuminants.wp = ComputeWhitePoint(illuminants, ColourReceptors);
end

MetamerMats = MetamerTestIlluminantAll(AllSpectra, illuminants, ColourReceptors);
UniqueMetaners = [];
return;

MetamerMats = MetamerDiffs.(IlluminantNames{1});
SignalNames = fieldnames(MetamerMats);
nSignals = numel(SignalNames);
ColourDifferenceMeasures = fieldnames(MetamerMats.(SignalNames{1}));
nColourDifferences = numel(ColourDifferenceMeasures);
MetaInfos = fieldnames(MetamerMats.(SignalNames{1}).(ColourDifferenceMeasures{1}));
nMetaInfos = numel(MetaInfos);

% set the illuminants as channels
for i = 2:numel(IlluminantNames)
  for j = 1:nSignals
    for k = 1:nColourDifferences
      for l = 1:nMetaInfos
        CatMetamers = MetamerMats.(SignalNames{j}).(ColourDifferenceMeasures{k}).(MetaInfos{l});
        CatMetamers(:, :, end + 1) = MetamerDiffs.(IlluminantNames{i}).(SignalNames{j}).(ColourDifferenceMeasures{k}).(MetaInfos{l}); %#ok
        MetamerMats.(SignalNames{j}).(ColourDifferenceMeasures{k}).(MetaInfos{l}) = CatMetamers;
      end
    end
  end
end

disp('***Unique metamers***');
UniqueMetaners = struct();
for j = 1:nSignals
  disp(SignalNames{j});
  for k = 1:numel(ColourDifferenceMeasures)
    CurrentMetamers = MetamerMats.(SignalNames{j}).(ColourDifferenceMeasures{k}).metamers;
    AnyMetamers = any(CurrentMetamers, 3);
    AllMetamers = all(CurrentMetamers, 3);
    AnyMetamers(AllMetamers) = false;
    
    CurrentCompMat = mean(MetamerMats.(SignalNames{j}).(ColourDifferenceMeasures{k}).CompMat, 3);
    
    UniqueMetaners.(SignalNames{j}).(ColourDifferenceMeasures{k}).metamers = AnyMetamers;
    UniqueMetaners.(SignalNames{j}).(ColourDifferenceMeasures{k}).CompMat = CurrentCompMat;
  end
  PrintMetamer = UniqueMetaners.(SignalNames{j});
  printinfo(PrintMetamer);
  
  if plotmeunique && ~strcmpi(SignalNames{j}, 'nfall')
    % LabVals.(SignalNames{j})
    PlotElementSignals(AllSpectra.originals.(SignalNames{j}), UniqueMetaners.(SignalNames{j}), AllSpectra.wavelengths.(SignalNames{j}), [], SignalNames{i});
  end
end

end

function [illuminants, ColourReceptors] = IntersectIlluminantColourReceptors(illuminants, ColourReceptors)

if size(illuminants.wavelength, 1) ~= size(ColourReceptors.wavelength, 1) || illuminants.wavelength ~= ColourReceptors.wavelength
  [~, ia, ib] = intersect(illuminants.wavelength, ColourReceptors.wavelength);
  illuminants.wavelength = illuminants.wavelength(ia');
  illuminants.spectra = illuminants.spectra(ia');
  ColourReceptors.wavelength = ColourReceptors.wavelength(ib');
  ColourReceptors.spectra = ColourReceptors.spectra(ib', :);
end

end

function MetamerDiffs = MetamerTestIlluminantAll(AllSpectra, illuminants, ColourReceptors)

originals = AllSpectra.originals;
wavelengths = AllSpectra.wavelengths;

SignalNames = fieldnames(originals);
nSignals = numel(SignalNames);

lab = [];
for i = 1:nSignals
  LabVals.(SignalNames{i}) = ComputeLab(originals.(SignalNames{i}), wavelengths.(SignalNames{i}), ...
    illuminants.spectra, illuminants.wavelength, ...
    ColourReceptors.spectra, ColourReceptors.wavelength, ...
    illuminants.wp);
  lab = cat(1, lab, LabVals.(SignalNames{i}));
end

% TODO: too much memory optimise it
disp('  Processing all');
MetamerDiffs.nfall = MetamerAnalysisColourDifferences(lab, 0.5, false, false, true);
printinfo(MetamerDiffs.nfall, size(lab, 1));

end

function MetamerDiffs = MetamerTestIlluminantSingle(AllSpectra, illuminants, ColourReceptors, wp, plotmeall)

originals = AllSpectra.originals;
wavelengths = AllSpectra.wavelengths;

plotme.munsell = plotmeall;
plotme.candy = plotmeall;
plotme.agfa = plotmeall;
plotme.natural = plotmeall;
plotme.forest = plotmeall;
plotme.lumber = plotmeall;
plotme.paper = plotmeall;
plotme.cambridge = plotmeall;
plotme.fred400 = plotmeall;
plotme.fred401 = plotmeall;
plotme.barnard = plotmeall;
plotme.matsumoto = plotmeall;
plotme.westland = plotmeall;

SignalNames = fieldnames(originals);
nSignals = numel(SignalNames);

lab = [];
for i = 1:nSignals
  disp(['  Processing ', SignalNames{i}]);
  LabVals.(SignalNames{i}) = ComputeLab(originals.(SignalNames{i}), wavelengths.(SignalNames{i}), ...
    illuminants.spectra, illuminants.wavelength, ...
    ColourReceptors.spectra, ColourReceptors.wavelength, ...
    wp);
  lab = cat(1, lab, LabVals.(SignalNames{i}));
  MetamerReport = MetamerAnalysisColourDifferences(LabVals.(SignalNames{i}), 0.5, false, false, true);
  MetamerDiffs.(SignalNames{i}) = MetamerReport;
  
  nCurrentSignals = size(lab, 1);
  printinfo(MetamerReport, nCurrentSignals);
  
  if plotme.(SignalNames{i})
    PlotElementSignals(originals.(SignalNames{i}), MetamerDiffs.(SignalNames{i}), wavelengths.(SignalNames{i}), LabVals.(SignalNames{i}), SignalNames{i});
  end
end

end

function printinfo(MetamerReport, nCurrentSignals)

if nargin < 2
  nCurrentSignals = size(MetamerReport.m1976.metamers, 1);
end

% printinfoyear(MetamerReport.m1976.metamers, '    Metamer-1976: ', nCurrentSignals);
% printinfoyear(MetamerReport.m1994.metamers, '    Metamer-1994: ', nCurrentSignals);
printinfoyear(MetamerReport.m2000.metamers, '    Metamer-2000: ', nCurrentSignals);

end

function [] = printinfoyear(MetamerReport, PreText, nCurrentSignals)
nAll = sum(MetamerReport(:)) / 2;
disp([PreText, num2str(nAll / ((nCurrentSignals * (nCurrentSignals - 1)) / 2))]);
end

function lab = ComputeLab(ev, ew, iv, iw, cv, cw, wp)

[ev, iv, cv] = IntersectThree(ev, ew, iv, iw, cv, cw);

lab = hsi2lab(ev, iv, cv, wp);

end

function [] = PlotElementSignals(element, MetamerPlot, wavelength, lab, name)

% TODO: plot for all rather than just 2000
MetamerPlot = MetamerPlot.m2000;

SignalLength = size(element, 3);
MetamerPlot.SgnlDiffs = 1 ./ MetamerPlot.CompMat;
nSignals = size(element, 1);
PlotTopMetamers(MetamerPlot, reshape(element, nSignals, SignalLength)', 25, wavelength, lab, name);

end
