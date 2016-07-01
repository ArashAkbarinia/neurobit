function r = ReproductionAngularError(l1, l2)
%ReproductionAngularError  calculated the reproduction angular error.
%   http://www.bmva.org/bmvc/2014/papers/paper047/
%
% inputs
%   l1  the estimated illuminant.
%   l2  the ground truth illuminant.
%
% outputs
%   r   the reproduction angular error.
%

% normalising the illuminants
l1 = l1 ./ sum(l1(:));
l2 = l2 ./ sum(l2(:));

l2l1 = l2 ./ l1;
w1 = l2l1 ./ (sqrt(sum(l2l1 .^ 2)));
w2 = 1 ./ sqrt(3);

r = acosd(sum(w1(:) .* w2(:)));

end