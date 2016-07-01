function r = AngularError(l1, l2)
%AngularError  calculated the recover angular error.
%
% inputs
%   l1  the estimated illuminant.
%   l2  the ground truth illuminant.
%
% outputs
%   r   the recovery angular error.
%

l1 = l1 ./ sum(l1(:));
l2 = l2 ./ sum(l2(:));

l1 = l1 / sqrt(sum(l1 .^ 2));
l2 = l2 / sqrt(sum(l2 .^ 2));

r = acosd(sum(l1(:) .* l2(:)));

end
