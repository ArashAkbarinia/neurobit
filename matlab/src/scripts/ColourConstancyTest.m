%% parallel

mycluster = parcluster('local');
mycluster.NumWorkers = 8;
delete(gcp);
parpool(mycluster);

% matlabpool close

%% ours partially

% params = {'arash', 3, 1.5, 2, 5, -0.87, -0.63, 0.95, 0.99, 4, -0.01, 0};
% SFU LAB [-0.870000000000000,-0.634887779498451,0.950648987143858,0.991387687664998,0,0.0135309907901242]
% params = {3, 1.5, 2, 5, -0.77, -0.67, 1, 1, 4, 'multi'};
params = {3, 1.5, 2, 5, -0.77, -0.67, 1, 1, 4, 'single'};
[AngularErrors1, LuminanceDiffs1, EstiLuminances1] = ColourConstancyReportSfuLab(params, false);
% [AngularErrors2, LuminanceDiffs2, EstiLuminances2] = ColourConstancyReportGreyBall(params, false);
% [AngularErrors3, LuminanceDiffs3, EstiLuminances3] = ColourConstancyReportGehlershi(params, false);


% tic
% [Laboratory.AngularErrors, Laboratory.LuminanceDiffs, Laboratory.EstiLuminances] = ColourConstancyReportMirf(params, false);
% disp('real images:');
% [Real.AngularErrors, Real.LuminanceDiffs, Real.EstiLuminances] = ColourConstancyReportMirf(params, true);
% toc

% [AngularErrors, LuminanceDiffs] = ColourConstancyReportGreyBall(params, false);
% [AngularErrors, LuminanceDiffs] = ColourConstancyReportGehlershi(params, false);
% [AngularErrors, LuminanceDiffs] = ColourConstancyReportSfuLab(params, false, 1:3:321); mean(AngularErrors(1:3:321)), median(AngularErrors(1:3:321))
% [AngularErrors, LuminanceDiffs] = ColourConstancyReportGreyBall(params, false, 1:100:11346); mean(AngularErrors(1:100:11346)), median(AngularErrors(1:100:11346))
% [AngularErrors, LuminanceDiffs] = ColourConstancyReportGehlershi(params, false, 1:5:568); mean(AngularErrors(1:5:568)), median(AngularErrors(1:5:568))
% [AngularErrors, LuminanceDiffs] = ColourConstancyReportBarcelona(params, false, 1:5:448); mean(AngularErrors(1:5:448)), median(AngularErrors(1:5:448))
% AngularErrors = ColourConstancyReportMirf(params, true, false);

%% tmp

methods = 'arash';
CentreSize = 3;
x = 1.5;
ContrastEnlarge = 2;
SurroundEnlarge = 5;
u = -0.87;
d = -0.63;
c1 = 0.95;
c4 = 0.99;
f1 = -0.01;
f4 = 0.00;
l = 4;
suffix = '-MaxInf.mat';
for p2 = CentreSize
  for p3 = x
    CurrentMethod = {methods, p2, p3, ContrastEnlarge, SurroundEnlarge, u, d, c1, c4, l, f1, f4};
    prefix = [methods, '-r', num2str(p2), '-', num2str(p3), '-s', num2str(SurroundEnlarge), '-c', num2str(ContrastEnlarge), '-u', num2str(u), '-d', num2str(d), '-n', num2str(c1), '-f', num2str(c4), '-l', num2str(l)];
    
    tic
    [AngularErrors, LuminanceDiffs, EstiLuminances] = ColourConstancyReportSfuLab(CurrentMethod, false);
    toc
    save(['SfuLab-', prefix, suffix], 'AngularErrors', 'LuminanceDiffs', 'EstiLuminances');
    
    tic
    [AngularErrors, LuminanceDiffs, EstiLuminances] = ColourConstancyReportGreyBall(CurrentMethod, false);
    toc
    save(['GreyBall-', prefix, suffix], 'AngularErrors', 'LuminanceDiffs', 'EstiLuminances');
    
    tic
    [AngularErrors, LuminanceDiffs, EstiLuminances] = ColourConstancyReportGehlershi(CurrentMethod, false);
    toc
    save(['Gehlershi-', prefix, suffix], 'AngularErrors', 'LuminanceDiffs', 'EstiLuminances');
  end
end

%% ours
AlgorithmName = 'gao';
SuffixName = 'DOFixArash';
[AngularErrors, LuminanceDiffs, EstiLuminances] = ColourConstancyReportSfuLab(AlgorithmName, false);
save(['SfuLab-', SuffixName, '.mat'], 'AngularErrors', 'LuminanceDiffs', 'EstiLuminances');

[AngularErrors, LuminanceDiffs, EstiLuminances] = ColourConstancyReportGreyBall(AlgorithmName, false);
save(['GreyBall-', SuffixName, '.mat'], 'AngularErrors', 'LuminanceDiffs', 'EstiLuminances');

[AngularErrors, LuminanceDiffs, EstiLuminances] = ColourConstancyReportGehlershi(AlgorithmName, false);
save(['ColourChecker-', SuffixName, '.mat'], 'AngularErrors', 'LuminanceDiffs', 'EstiLuminances');

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

[AngularErrors, LuminanceDiffs, EstiLuminances] = ColourConstancyReportGehlershi('white patch', false);
save('Gehlershi-WhitePatch.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportGehlershi('hist white patch', false);
save('Gehlershi-HistWhitePatch.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportGehlershi('gao', false);
save('Gehlershi-Gao.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs] = ColourConstancyReportGehlershi('joost', false);
save('Gehlershi-Joost.mat', 'AngularErrors', 'LuminanceDiffs');

[AngularErrors, LuminanceDiffs, EstiLuminances] = ColourConstancyReportGehlershi('grey world', false);
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