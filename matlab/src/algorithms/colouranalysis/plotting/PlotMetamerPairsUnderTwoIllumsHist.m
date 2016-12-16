function PlotMetamerPairsUnderTwoIllumsHist(lab11, lab21, lab12, lab22, minds, IllumNames)

pol11 = cart2pol3(lab11(minds, [2, 3, 1]));
pol21 = cart2pol3(lab21(minds, [2, 3, 1]));
pol12 = cart2pol3(lab12(minds, [2, 3, 1]));
pol22 = cart2pol3(lab22(minds, [2, 3, 1]));

nbins = 20;
[t11, r11] = rose(pol11(:, 1), nbins);
r11 = r11 ./ sum(r11);

[t21, r21] = rose(pol21(:, 1), nbins);
r21 = r21 ./ sum(r21);

[t12, r12] = rose(pol12(:, 1), nbins);
r12 = r12 ./ sum(r12);

[t22, r22] = rose(pol22(:, 1), nbins);
r22 = r22 ./ sum(r22);

MaxAll(1) = max(r11);
MaxAll(2) = max(r21);
MaxAll(3) = max(r12);
MaxAll(4) = max(r22);
MaxRadius = max(MaxAll);

cols = 2;
rows = 2;

subplot(rows, cols, 1);
DrawHueCircle(MaxRadius);
hold on;
polar(t11, r11, 'black');
title(['Pair 1 ''', IllumNames{1}, '''']);

subplot(rows, cols, 2);
DrawHueCircle(MaxRadius);
hold on;
polar(t12, r12, 'black');
title(['Pair 2 ''', IllumNames{1}, '''']);

subplot(rows, cols, 3);
DrawHueCircle(MaxRadius);
hold on;
polar(t21, r21, 'black');
title(['Pair 1 ''', IllumNames{2}, '''']);

subplot(rows, cols, 4);
DrawHueCircle(MaxRadius);
hold on;
polar(t22, r22, 'black');
title(['Pair 2 ''', IllumNames{2}, '''']);

end
