function [NamingImage, MaxProbabilityImage] = belonging2naming(BelongingImage, DecideAllPixels)
%BELONGING2NAMING  gets the maximum value of the all channels in the
%                  belonging image.
%
% Inputs
%   BelongingImage  the belonging image each channel for one colour.
%
% Outputs
%   NamingImage          index of the salient colour.
%   MaxProbabilityImage  the probability of each pixel.
%

if nargin < 2
  DecideAllPixels = false;
end

[~, ~, chns] = size(BelongingImage);

[vals, inds] = max(BelongingImage(:, :, 1:chns), [], 3);

if ~DecideAllPixels
  % if the maximum value is 0 it means neither of the colours did categorise
  % this pixel.
  inds(vals == 0) = -1;
  vals(vals == 0) = -1;
end

NamingImage = inds;
MaxProbabilityImage = vals;

end
