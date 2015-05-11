function r = AngularError(l1, l2)

l1 = l1 / sqrt(sum(l1 .^ 2));
l2 = l2 / sqrt(sum(l2 .^ 2));
r = acosd(sum(l1(:) .* l2(:)));

end
