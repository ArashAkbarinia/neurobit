function PlotMetamerPairsUnderTwoIllumsPoint(lab11, lab21, lab12, lab22, minds, IllumNames)

pol11 = cart2pol3(lab11(minds, [2, 3, 1]));
pol21 = cart2pol3(lab21(minds, [2, 3, 1]));
pol12 = cart2pol3(lab12(minds, [2, 3, 1]));
pol22 = cart2pol3(lab22(minds, [2, 3, 1]));

MaxAll(1) = max(max(pol11(:, 1:2)));
MaxAll(2) = max(max(pol21(:, 1:2)));
MaxAll(3) = max(max(pol12(:, 1:2)));
MaxAll(4) = max(max(pol22(:, 1:2)));
MaxRadius = max(MaxAll);

cols = 2;
rows = 2;

subplot(rows, cols, 1);
DrawHueCircle(MaxRadius);
hold on;
polar(pol11(:, 1), pol11(:, 2), '.black');
title(['Pair 1 ''', IllumNames{1}, '''']);

subplot(rows, cols, 2);
DrawHueCircle(MaxRadius);
hold on;
polar(pol12(:, 1), pol12(:, 2), '.black');
title(['Pair 2 ''', IllumNames{1}, '''']);

subplot(rows, cols, 3);
DrawHueCircle(MaxRadius);
hold on;
polar(pol21(:, 1), pol21(:, 2), '.black');
title(['Pair 1 ''', IllumNames{2}, '''']);

subplot(rows, cols, 4);
DrawHueCircle(MaxRadius);
hold on;
polar(pol22(:, 1), pol22(:, 2), '.black');
title(['Pair 2 ''', IllumNames{2}, '''']);

end
