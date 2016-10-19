function MetamerGroups = FindMetamerGroups(SignalResponses, SignalThreshold)
%FindMetamerGroups  finds group of metamers containg more than two signals.
%
% inputs
%   SignalResponses  the tristimulus respones.
%   SignalThreshold  the threshold to be considered for metamerism.
%
% outputs
%   MetamerGroups  a vector containing the metamer group number (we have
%                  considered a group contains more than two metamers).
%

IntConeResponses = round(SignalResponses .* (1 / SignalThreshold));

[~, ~, MetamerGroups] = unique(IntConeResponses, 'rows');

IndCounts = histcounts(MetamerGroups, 1:length(MetamerGroups) + 1);
PositiveMetamers = find(IndCounts > 2);
MetamerGroups(~ismember(MetamerGroups, PositiveMetamers)) = 0;

end
