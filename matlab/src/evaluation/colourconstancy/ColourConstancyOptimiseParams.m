function [OptimisedParams, RSS, exitflag, output] = ColourConstancyOptimiseParams()
%COLOURCONSTANCYOPTIMISEPARAMS Summary of this function goes here
%   Detailed explanation goes here



lb = ...
  [
  -0.87, -0.75, 0.9, 0.95, -0.61, -0.25
  ];
ub = ...
  [
  -0.43, -0.24, 1, 1.1, 0, 0.08
  ];
options = optimoptions(@fmincon,'Algorithm', 'sqp', 'Display', 'off', 'MaxIter', 10, 'TolFun', 1e-10, 'MaxFunEvals', 1e10);

initial = [-0.87, -0.67, 0.95, 1, 0, 0];
[OptimisedParams, RSS, exitflag, output] = fmincon(@(x) TmpColourConstancyOptimiseParams(x), initial, [], [], [], [], lb, ub, [], options);

end

function RSS = TmpColourConstancyOptimiseParams(x)

params = {'arash', 3, 1.5, 2, 5, x(1), x(2), x(3), x(4), 4, x(5), x(6)};
[AngularErrors, ~, ~] = ColourConstancyReportSfuLab(params, false);

% MeanError = double(uint8(mean(AngularErrors(:)) * 10)) / 10;
% MediError = double(uint8(median(AngularErrors(:)) * 10)) / 10;

RSS = median(AngularErrors(:));%(MeanError + MediError) / 2;

end
