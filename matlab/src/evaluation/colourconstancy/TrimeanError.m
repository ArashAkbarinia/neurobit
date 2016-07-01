function OutputTrimean = TrimeanError(AngularErrors)
%TrimeanError  calculates the Trimean error of a dataset.
%   Explanation  https://explorable.com/trimean
%
% inputs
%   AngularErrors  a set of data.
%
% outputs
%   TrimeanError  the Trimean value.
%

cols = size(AngularErrors, 2);
OutputTrimean = zeros(1, cols);

for i = 1:cols
  AngularErrorsColI = sort(AngularErrors(:, i));
  
  l = floor(length(AngularErrorsColI) / 4);
  
  m1 = AngularErrorsColI(l);
  m2 = AngularErrorsColI(l * 2);
  m3 = AngularErrorsColI(l * 3);
  OutputTrimean(1, i) = (0.25 * m1) + (0.5 * m2) + (0.25 * m3);
end

end
