function ShiftStats = PlotMetamerPairsUnderTwoIllumsHist(lab11, lab21, lab12, lab22, minds, IllumNames, OrgHist1, OrgHist2)

r1 = OrgHist1.AbsRadius;
r2 = OrgHist2.AbsRadius;

pol11 = cart2pol3(lab11(minds, [2, 3, 1]));
pol21 = cart2pol3(lab21(minds, [2, 3, 1]));
pol12 = cart2pol3(lab12(minds, [2, 3, 1]));
pol22 = cart2pol3(lab22(minds, [2, 3, 1]));

% for title compute the radius and theta differences
t1d = pdist2(pol11(:, 1)', pol12(:, 1)', @PdistAbsAngDiff);
t1d = num2str(rad2deg(t1d));
r1d = pdist2(pol11(:, 2)', pol12(:, 2)');
r1d = num2str(r1d);
t2d = pdist2(pol21(:, 1)', pol22(:, 1)', @PdistAbsAngDiff);
t2d = num2str(rad2deg(t2d));
r2d = pdist2(pol21(:, 2)', pol22(:, 2)');
r2d = num2str(r2d);

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

% normalising the histograms for visualisation
r11 = r11 ./ r1;
r11(isnan(r11) | isinf(r11)) = 0;

r21 = r21 ./ r2;
r21(isnan(r21) | isinf(r21)) = 0;

r12 = r12 ./ r1;
r12(isnan(r12) | isinf(r12)) = 0;

r22 = r22 ./ r2;
r22(isnan(r22) | isinf(r22)) = 0;

% computing the maximu radius
MaxAll1(1) = max(r11);
MaxAll1(2) = max(r12);
MaxAll2(1) = max(r21);
MaxAll2(2) = max(r22);
MaxRadius1 = max(MaxAll1);
MaxRadius2 = max(MaxAll2);

cols = 2;
rows = 2;

subplot(rows, cols, 1);
DrawHueCircle(MaxRadius1);
hold on;
polar(t11, r11, 'black');
polar(t12, r12, '--white');
title(['P1 (black) P2 (white) ''', IllumNames{1}, '''', ' rd=[', r1d,']', ' td=[', t1d,']']);

h = subplot(rows, cols, 2);
WindRose(rad2deg(t1s), r1s, 'parent', h, 'cmap', gray, 'n', ShiftBins)
title(['Theta and radius shift ''', IllumNames{1}, '''', ' rd=[', r1d,']', ' td=[', t1d,']']);

subplot(rows, cols, 3);
DrawHueCircle(MaxRadius2);
hold on;
polar(t21, r21, 'black');
polar(t22, r22, '--white');
title(['P1 (black) P2 (white) ''', IllumNames{2}, '''', ' rd=[', r2d,']', ' td=[', t2d,']']);

h = subplot(rows, cols, 4);
WindRose(rad2deg(t2s), r2s, 'parent', h, 'cmap', gray, 'n', ShiftBins)
title(['Theta and radius shift ''', IllumNames{2}, '''', ' rd=[', r2d,']', ' td=[', t2d,']']);

end
