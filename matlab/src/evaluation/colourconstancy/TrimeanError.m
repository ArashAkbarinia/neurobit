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

AngularErrors = sort(AngularErrors);

l = floor(length(AngularErrors) / 4);

m1 = AngularErrors(l);
m2 = AngularErrors(l * 2);
m3 = AngularErrors(l * 3);
OutputTrimean = (0.25 * m1) + (0.5 * m2) + (0.25 * m3);

end
