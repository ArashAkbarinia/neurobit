%% parallel

mycluster = parcluster('local');
mycluster.NumWorkers = 8;
matlabpool(mycluster);

% matlabpool close

%% ours partially

params = {'arash', 3, 0.8, 2, 5, -0.82, -0.72, 0, 0, 0};
% [AngularErrors, LuminanceDiffs] = ColourConstancyReportSfuLab(params, false, 1:3:321); mean(AngularErrors(1:3:321)), median(AngularErrors(1:3:321))
[AngularErrors, LuminanceDiffs] = ColourConstancyReportGreyBall(params, false, 1:100:11346); mean(AngularErrors(1:100:11346)), median(AngularErrors(1:100:11346))
% [AngularErrors, LuminanceDiffs] = ColourConstancyReportGehlershi(params, false, 1:5:568); mean(AngularErrors(1:5:568)), median(AngularErrors(1:5:568))
% [AngularErrors, LuminanceDiffs] = ColourConstancyReportBarcelona(params, false, 1:5:448); mean(AngularErrors(1:5:448)), median(AngularErrors(1:5:448))

%% tmp

% [AngularErrors, LuminanceDiffs] = ColourConstancyReportSfuLab('joost', false);
% save('SfuLab-JoostContrast.mat', 'AngularErrors', 'LuminanceDiffs');
%
% [AngularErrors, LuminanceDiffs] = ColourConstancyReportGreyBall('joost', false);
% save('GreyBall-JoostContrast.mat', 'AngularErrors', 'LuminanceDiffs');
%
% [AngularErrors, LuminanceDiffs] = ColourConstancyReportGehlershi('joost', false);
% save('Gehlershi-JoostContrast.mat', 'AngularErrors', 'LuminanceDiffs');

% methods = {'gaussian', 'cgaussian', 'udog', 'cudog', 'd1', 'cd1', 'd2', 'cd2'};
methods = {'arash'};
% u = -0.82;
% d = -0.72;
% CentreSize = 3;
% x = 0.8;
ContrastEnlarge = 2;
SurroundEnlarge = 5;
for i = 1:1:numel(methods)
  for CentreSize = 3
    for x = 0.7
      for u = -0.82
        for d = -0.72
          CurrentMethod = {methods{i}, CentreSize, x, ContrastEnlarge, SurroundEnlarge, u, d, 0, 0, 0};
          [AngularErrors, LuminanceDiffs] = ColourConstancyReportSfuLab(CurrentMethod, false);
          save(['SfuLab-', methods{i}, '-r', num2str(CentreSize), '-', num2str(x), '-s', num2str(SurroundEnlarge), '-c', num2str(ContrastEnlarge), '-u', num2str(u), '-d', num2str(d), '.mat'], 'AngularErrors', 'LuminanceDiffs');
          
          [AngularErrors, LuminanceDiffs] = ColourConstancyReportGreyBall(CurrentMethod, false);
          save(['GreyBall-', methods{i}, '-r', num2str(CentreSize), '-', num2str(x), '-s', num2str(SurroundEnlarge), '-c', num2str(ContrastEnlarge), '-u', num2str(u), '-d', num2str(d), '.mat'], 'AngularErrors', 'LuminanceDiffs');
          
          [AngularErrors, LuminanceDiffs] = ColourConstancyReportGehlershi(CurrentMethod, false);
          save(['Gehlershi-', methods{i}, '-r', num2str(CentreSize), '-', num2str(x), '-s', num2str(SurroundEnlarge), '-c', num2str(ContrastEnlarge), '-u', num2str(u), '-d', num2str(d), '.mat'], 'AngularErrors', 'LuminanceDiffs');
        end
      end
    end
  end
end

% [AngularErrors, LuminanceDiffs] = ColourConstancyReportSfuLab('gaussian', false);
% save('SfuLab-Gaussian.mat', 'AngularErrors', 'LuminanceDiffs');
%
% [AngularErrors, LuminanceDiffs] = ColourConstancyReportGreyBall('gaussian', false);
% save('GreyBall-Gaussian.mat', 'AngularErrors', 'LuminanceDiffs');
%
% [AngularErrors, LuminanceDiffs] = ColourConstancyReportGehlershi('gaussian', false);
% save('Gehlershi-Gaussian.mat', 'AngularErrors', 'LuminanceDiffs');
%
% [AngularErrors, LuminanceDiffs] = ColourConstancyReportSfuLab('2nd gaussian', false);
% save('SfuLab-d2Gaussian.mat', 'AngularErrors', 'LuminanceDiffs');
%
% [AngularErrors, LuminanceDiffs] = ColourConstancyReportGreyBall('2nd gaussian', false);
% save('GreyBall-d2Gaussian.mat', 'AngularErrors', 'LuminanceDiffs');
%
% [AngularErrors, LuminanceDiffs] = ColourConstancyReportGehlershi('2nd gaussian', false);
% save('Gehlershi-d2Gaussian.mat', 'AngularErrors', 'LuminanceDiffs');

%% ours
[AngularErrors, LuminanceDiffs] = ColourConstancyReportSfuLab('opponency', false);
save('SfuLab-Opponency.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportGreyBall('opponency', false);
save('GreyBall-Opponency.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportGehlershi('opponency', false);
save('Gehlershi-Opponency.mat', 'AngularErrors', 'LuminanceDiffs');

%% SfuLab

[AngularErrors, LuminanceDiffs] = ColourConstancyReportSfuLab('opponency', false);
save('SfuLab-Opponency.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportSfuLab('white patch', false);
save('SfuLab-WhitePatch.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportSfuLab('hist white patch', false);
save('SfuLab-HistWhitePatch.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportSfuLab('gao', false);
save('SfuLab-Gao.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportSfuLab('joost', false);
save('SfuLab-Joost.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportSfuLab('grey world', false);
save('SfuLab-GreyWorld.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportSfuLab('local std', false);
save('SfuLab-LocalStd.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportSfuLab('hist white patch local std', false);
save('SfuLab-HistWhitePatchLocalStd.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportSfuLab('gamut mapping', false);
save('SfuLab-GamutMapping.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportSfuLab('nothing', false);
save('SfuLab-Nothing.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportSfuLab('bayesian', false);
save('SfuLab-Bayesian.mat', 'AngularErrors', 'LuminanceDiffs');

%% GreyBall

[AngularErrors, LuminanceDiffs] = ColourConstancyReportGreyBall('opponency', false);
save('GreyBall-Opponency.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportGreyBall('white patch', false);
save('GreyBall-WhitePatch.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportGreyBall('hist white patch', false);
save('GreyBall-HistWhitePatch.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportGreyBall('gao', false);
save('GreyBall-Gao.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportGreyBall('joost', false);
save('GreyBall-Joost.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportGreyBall('grey world', false);
save('GreyBall-GreyWorld.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportGreyBall('local std', false);
save('GreyBall-LocalStd.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportGreyBall('hist white patch local std', false);
save('GreyBall-HistWhitePatchLocalStd.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportGreyBall('gamut mapping', false);
save('GreyBall-GamutMapping.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportGreyBall('nothing', false);
save('GreyBall-Nothing.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportGreyBall('bayesian', false);
save('GreyBall-Bayesian.mat', 'AngularErrors', 'LuminanceDiffs');

%% GehlerShi

[AngularErrors, LuminanceDiffs] = ColourConstancyReportGehlershi('opponency', false);
save('Gehlershi-Opponency.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportGehlershi('white patch', false);
save('Gehlershi-WhitePatch.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportGehlershi('hist white patch', false);
save('Gehlershi-HistWhitePatch.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportGehlershi('gao', false);
save('Gehlershi-Gao.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportGehlershi('joost', false);
save('Gehlershi-Joost.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportGehlershi('grey world', false);
save('Gehlershi-GreyWorld.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportGehlershi('local std', false);
save('Gehlershi-LocalStd.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportGehlershi('hist white patch local std', false);
save('Gehlershi-HistWhitePatchLocalStd.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportGehlershi('gamut mapping', false);
save('Gehlershi-GamutMapping.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportGehlershi('nothing', false);
save('Gehlershi-Nothing.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportGehlershi('bayesian', false);
save('Gehlershi-Bayesian.mat', 'AngularErrors', 'LuminanceDiffs');

%% Barcelona

[AngularErrors, LuminanceDiffs] = ColourConstancyReportBarcelona('white patch', false);
save('Barcelona-WhitePatch.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportBarcelona('hist white patch', false);
save('Barcelona-HistWhitePatch.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportBarcelona('gao', false);
save('Barcelona-Gao.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportBarcelona('joost', false);
save('Barcelona-Joost.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportBarcelona('grey world', false);
save('Barcelona-GreyWorld.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportBarcelona('local std', false);
save('Barcelona-LocalStd.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportBarcelona('hist white patch local std', false);
save('Barcelona-HistWhitePatchLocalStd.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportBarcelona('gamut mapping', false);
save('Barcelona-GamutMapping.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportBarcelona('nothing', false);
save('Barcelona-Nothing.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportBarcelona('bayesian', false);
save('Barcelona-Bayesian.mat', 'AngularErrors', 'LuminanceDiffs');