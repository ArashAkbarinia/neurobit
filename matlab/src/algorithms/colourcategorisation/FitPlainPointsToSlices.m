function slices = FitPlainPointsToSlices(ColourBorderPoints)
%FitPlanePointsToSlices  fits the colour frontiers poitns to slices.

% lums = fieldnames(ColourBorderPoints);
% slices = struct();
%
% for i = 1:numel(lums)
%   CurrentLumPoints3 = ColourBorderPoints.(lums{i});
%   if isempty(CurrentLumPoints3)
%     continue;
%   end
%   CurrentLumPoints2 = CurrentLumPoints3(:, 1:2);
%   slices.(lums{i}) = OptimiseSlice(CurrentLumPoints2);
% end

slices = OptimiseSlice(ColourBorderPoints(:, 1:2));

end

function slice = OptimiseSlice(CurrentLumPoints2)

[~, indsmin] = min(CurrentLumPoints2);
minx = CurrentLumPoints2(indsmin(1), :);
CurrentLumPoints2(:, 1) = CurrentLumPoints2(:, 1) - minx(1);
CurrentLumPoints2(:, 2) = CurrentLumPoints2(:, 2) - minx(2);
[~, indsmax] = max(CurrentLumPoints2);
[th1, ~] = cart2pol(CurrentLumPoints2(indsmin(2), 1), CurrentLumPoints2(indsmin(2), 2));
[th2, ~] = cart2pol(CurrentLumPoints2(indsmax(2), 1), CurrentLumPoints2(indsmax(2), 2));
midth = (th1 + th2) / 2;
if th1 < 0
  th1 = (2 * pi) + th1;
end
if th2 < 0
  th2 = (2 * pi) + th2;
end
if midth < 0
  midth = (2 * pi) + midth;
end

options = optimoptions(@fmincon,'Algorithm', 'interior-point', 'Display', 'iter-detailed', 'MaxIter', 1e6, 'TolFun', 1e-10, 'MaxFunEvals', 1e6, 'InitBarrierParam', 1e10, 'TolX', 1e-2);
initial = [th1, th2];
lb = [min(th1, midth), min(th2, midth)];
ub = [max(th1, midth), min(th2, midth)];
[angles, rss, exitflag, output] = fmincon(@(x) SliceFitting(x, CurrentLumPoints2), initial, [], [], [], [], lb, ub, @(x) SliceConditions(x), options)

slice = struct();
slice.angle1 = angles(1);
slice.angle2 = angles(2);
slice.error = rss

figure;
hold on;
grid on;
plot(CurrentLumPoints2(:, 1), CurrentLumPoints2(:, 2), '*');
s = [0, 0];
[x1, y1] = pol2cart(angles(1), 10);
[x2, y2] = pol2cart(angles(2), 10);
plot([s(1), x1], [s(2), y1], 'r');
plot([s(1), x2], [s(2), y2], 'r');
plot([s(1), (CurrentLumPoints2(indsmin(2), 1))], [s(2), (CurrentLumPoints2(indsmin(2), 2))], 'black');
plot([s(1), (CurrentLumPoints2(indsmax(2), 1))], [s(2), (CurrentLumPoints2(indsmax(2), 2))], 'black');
[m1, m2] = pol2cart(midth, 10);
plot([s(1), m1], [s(2), m2], 'cyan');

end

function [c, ceq] = SliceConditions(x)

c(1) = x(1) - x(2);
ceq = [];

end

function rss = SliceFitting(angles, points)

StartPoint = [0, 0];
[x1, y1] = pol2cart(angles(1), 1000);
[x2, y2] = pol2cart(angles(2), 1000);

distance1 = DistanceLine(StartPoint, [x1, y1], points);
distance2 = DistanceLine(StartPoint, [x2, y2], points);

rss = mean([distance1; distance2]);
% rss = sum([distance1; distance2]);

end
