function NamingImage = belonging2naming(BelongingImage)
%BELONGING2NAMING  gets the maximum value of the all channels in the
%                  belonging image.
%
% Inputs
%   BelongingImage  the belonging image each channel for one colour.
%
% Outputs
%   NamingImage  index of the salient colour.
%

[~, ~, chns] = size(BelongingImage);

[vals, inds] = max(BelongingImage(:, :, 1:chns), [], 3);
% if the maximum value is 0 it means neither of the colours did categorise
% this pixel.
inds(vals == 0) = -1;

NamingImage = inds;

end
