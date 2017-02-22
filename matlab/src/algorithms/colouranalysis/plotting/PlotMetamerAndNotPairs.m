function ShiftStats = PlotMetamerAndNotPairs(lab11, lab21, lab12, lab22, DeltaE2000, IllumNames, OrgHist1, OrgHist2, DeltaELabels)

de = abs(DeltaE2000(:, 1) - DeltaE2000(:, 2));
[MaxDe, SortedDe] = sort(de, 'descend');
TopDe = 100;
TopDe = min(TopDe, length(de));

DeltaE2000 = DeltaE2000(SortedDe(1:TopDe), :);
minds = DeltaE2000(:, 1) < DeltaE2000(:, 2);
lab11 = lab11(SortedDe(1:TopDe), :);
lab21 = lab21(SortedDe(1:TopDe), :);
lab12 = lab12(SortedDe(1:TopDe), :);
lab22 = lab22(SortedDe(1:TopDe), :);

r1 = OrgHist1.AbsRadius;
r2 = OrgHist2.AbsRadius;

AllPol11 = cart2pol3(lab11(:, [2, 3, 1]));
AllPol21 = cart2pol3(lab21(:, [2, 3, 1]));
AllPol12 = cart2pol3(lab12(:, [2, 3, 1]));
AllPol22 = cart2pol3(lab22(:, [2, 3, 1]));

pol11 = [AllPol11(minds, :); AllPol21(~minds, :)];
pol12 = [AllPol12(minds, :); AllPol22(~minds, :)];
pol21 = [AllPol11(~minds, :); AllPol21(minds, :)];
pol22 = [AllPol12(~minds, :); AllPol22(minds, :)];

% for title compute the radius and theta differences
t1d = mean(AbsAngDiff(pol11(:, 1)', pol12(:, 1)'));
t1d = num2str(rad2deg(t1d), 2);
r1d = mean(abs(pol11(:, 2)' - pol12(:, 2)'));
r1d = num2str(r1d, 2);
t2d = mean(AbsAngDiff(pol21(:, 1)', pol22(:, 1)'));
t2d = num2str(rad2deg(t2d), 2);
r2d = mean(abs(pol21(:, 2)' - pol22(:, 2)'));
r2d = num2str(r2d, 2);

% compute the shifts
ShiftBins = 36;
t1s = AngDiff(pol11(:, 1), pol12(:, 1));
r1s = pol11(:, 2) - pol12(:, 2);
t2s = AngDiff(pol21(:, 1), pol22(:, 1));
r2s = pol21(:, 2) - pol22(:, 2);

% saving the shifts in the output
ShiftStats.t1s = t1s;
ShiftStats.r1s = r1s;
ShiftStats.t2s = t2s;
ShiftStats.r2s = r2s;

% compute the histograms
nbins = length(r1) / 4;
[t11, r11] = rose(pol11(:, 1), nbins);
[t21, r21] = rose(pol21(:, 1), nbins);
[t12, r12] = rose(pol12(:, 1), nbins);
[t22, r22] = rose(pol22(:, 1), nbins);

% saving the absolute hist counts in the output
ShiftStats.r11 = r11;
ShiftStats.t11 = t11;
ShiftStats.r12 = r12;
ShiftStats.t12 = t12;
ShiftStats.r21 = r21;
ShiftStats.t21 = t21;
ShiftStats.r22 = r22;
ShiftStats.t22 = t22;

MaxAll1(1) = max(max(pol11(:, 1:2)));
MaxAll1(2) = max(max(pol12(:, 1:2)));
MaxAll2(1) = max(max(pol21(:, 1:2)));
MaxAll2(2) = max(max(pol22(:, 1:2)));
MaxRadius1 = max(MaxAll1);
MaxRadius2 = max(MaxAll2);

cols = 2;
rows = 2;

subplot(rows, cols, 1);
DrawHueCircle(MaxRadius1);
hold on;
h = polar(pol11(:, 1), pol11(:, 2), '.');
set(h, 'MarkerEdgeColor', [0.5, 0.5, 0.5]);
polar(pol12(:, 1), pol12(:, 2), 'oblack');
title(['\DeltaE<', num2str(DeltaELabels(1), 2), ' under one illuminant']);

h = subplot(rows, cols, 2);
WindRose(rad2deg(t1s), r1s, 'parent', h, 'cmap', jet, 'n', ShiftBins, 'di', -6:2:6)
title(['Average colour shifts: \Delta\rho=', r1d, ' \Delta\Theta=', t1d, '^\circ']);

subplot(rows, cols, 3);
DrawHueCircle(MaxRadius2);
hold on;
h = polar(pol21(:, 1), pol21(:, 2), '.');
set(h, 'MarkerEdgeColor', [0.5, 0.5, 0.5]);
polar(pol22(:, 1), pol22(:, 2), 'oblack');
title(['\DeltaE>', num2str(DeltaELabels(2), 2), ' under another illuminant']);

h = subplot(rows, cols, 4);
WindRose(rad2deg(t2s), r2s, 'parent', h, 'cmap', jet, 'n', ShiftBins, 'di', -6:2:6)
title(['Colour shifts under: \Delta\rho=', r2d, ' \Delta\Theta=', t2d, '^\circ']);

suptitle(['Metameric pairs under illuminants ''', IllumNames{1}, '''-''', IllumNames{2}, '''']);

end
