function ShiftStats = PlotMetamerPairsUnderTwoIllumsPoint(lab11, lab21, lab12, lab22, minds, IllumNames, OrgHist1, OrgHist2)

r1 = OrgHist1.AbsRadius;
r2 = OrgHist2.AbsRadius;

pol11 = cart2pol3(lab11(minds, [2, 3, 1]));
pol21 = cart2pol3(lab21(minds, [2, 3, 1]));
pol12 = cart2pol3(lab12(minds, [2, 3, 1]));
pol22 = cart2pol3(lab22(minds, [2, 3, 1]));

% for title compute the radius and theta differences
t1d = pdist2(pol11(:, 1)', pol12(:, 1)', @PdistAbsAngDiff);
t1d = num2str(rad2deg(t1d), 2);
r1d = pdist2(pol11(:, 2)', pol12(:, 2)');
r1d = num2str(r1d, 2);
t2d = pdist2(pol21(:, 1)', pol22(:, 1)', @PdistAbsAngDiff);
t2d = num2str(rad2deg(t2d), 2);
r2d = pdist2(pol21(:, 2)', pol22(:, 2)');
r2d = num2str(r2d, 2);

% compute the shifts
ShiftBins = 180;
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
polar(pol12(:, 1), pol12(:, 2), 'o');
title(['Pair-1 (black) and Pair-2 (white) under ''', IllumNames{1}, '''']);

h = subplot(rows, cols, 2);
WindRose(rad2deg(t1s), r1s, 'parent', h, 'cmap', jet, 'n', ShiftBins, 'di', -6:2:6)
title(['Colour shifts under ''', IllumNames{1}, '''', ' \DeltaR=', r1d, ' \Delta\Theta=', t1d]);

subplot(rows, cols, 3);
DrawHueCircle(MaxRadius2);
hold on;
h = polar(pol21(:, 1), pol21(:, 2), '.');
set(h, 'MarkerEdgeColor', [0.5, 0.5, 0.5]);
polar(pol22(:, 1), pol22(:, 2), 'o');
title(['Pair-1 (black) and Pair-2 (white) under ''', IllumNames{2}, '''']);

h = subplot(rows, cols, 4);
WindRose(rad2deg(t2s), r2s, 'parent', h, 'cmap', jet, 'n', ShiftBins, 'di', -6:2:6)
title(['Colour shifts under ''', IllumNames{2}, '''', ' \DeltaR=', r2d, ' \Delta\Theta=', t2d]);

end
