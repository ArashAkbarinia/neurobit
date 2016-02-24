function ch = CircularAverage(radius)
%CircularAverage  creates a circual average filter
%
% inputs
%   radius  the length of the radius in pixels.
%
% outputs
%   ch  the circle average filter
%

x = radius * 2 + 1;
[rr, cc] = meshgrid(1:x - 1);
ch = sqrt((rr - x / 2) .^ 2 + (cc - x / 2) .^ 2) <= radius;

ch = ch ./ sum(ch(:));

end
