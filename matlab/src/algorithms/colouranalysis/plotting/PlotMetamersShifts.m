function [] = PlotMetamersShifts(IllumPairsShiftStats)
%PlotMetamersShifts Summary of this function goes here
%   Detailed explanation goes here

nIllums = size(IllumPairsShiftStats.labhist, 1);

figure;
rows = round(sqrt(nIllums));
cols = ceil(sqrt(nIllums));

for i = 1:nIllums
  r11s = 0;
  r12s = 0;
  r21s = 0;
  r22s = 0;
  for j = 1:nIllums
    if isempty(IllumPairsShiftStats.shifts)
      continue;
    end
    if i < j
      mxnx = 'm1n2';
      rxx11 = 'r11';
      rxx12 = 'r12';
      rxx21 = 'r21';
      rxx22 = 'r22';
    else
      mxnx = 'm2n1';
      rxx11 = 'r21';
      rxx12 = 'r22';
      rxx21 = 'r11';
      rxx22 = 'r12';
    end
    if isfield(IllumPairsShiftStats.shifts{i, j}, mxnx)
      r11s = r11s + IllumPairsShiftStats.shifts{i, j}.(mxnx).(rxx11);
      r12s = r12s + IllumPairsShiftStats.shifts{i, j}.(mxnx).(rxx12);
      r21s = r21s + IllumPairsShiftStats.shifts{i, j}.(mxnx).(rxx21);
      r22s = r22s + IllumPairsShiftStats.shifts{i, j}.(mxnx).(rxx22);
    end
  end
  
  subplot(rows, cols, i);
%   figure;
  
%   r11s = r11s ./ max(r11s(:));
%   r21s = r21s ./ max(r21s(:));
%   % normalise it with the dataset bias
%   r11s = r11s ./ IllumPairsShiftStats.labhist{i}.RatRadius;
%   r11s(isnan(r11s) | isinf(r11s)) = 0;
%   r21s = r21s ./ IllumPairsShiftStats.labhist{i}.RatRadius;
%   r21s(isnan(r21s) | isinf(r21s)) = 0;
  
  MaxRadius = max([r11s(:), ; r21s(:)]);
  DrawHueCircle(MaxRadius);
  hold on;
  polar(IllumPairsShiftStats.shifts{1, 2}.m1n2.t11, r11s, 'black');
  polar(IllumPairsShiftStats.shifts{1, 2}.m1n2.t11, r21s, '--white');
end

end

