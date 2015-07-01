% e = rmsstderr(err)
%
% computes the root mean squared standard error
% v = std(sqrt(err))/sqrt(numel(err));
function v = rmsstderr(err);

v = std(sqrt(err))/sqrt(numel(err));