function AngularErrorDist = PixelAngularError(im1, im2)
%PixelAngularError  Pixelwise Angular distance between images.
%
% inputs
%   im1  Ground Truth (Pixels with zero value in GT are not considered).
%   im2  Estimate illuminant image.
%
% outputs
%   AngularErrorDist  the angular errors.
%

[r1, c1, ~] = size(im1);
[r2, c2, ~] = size(im2);
if r1 * c1 ~= r2 * c2
  error('sizes of input images do not match.\n');
end

% vectorise
im1 = reshape(im1, r1 * c1, 3);
im2 = reshape(im2, r2 * c2, 3);

% normalise
im1n = im1 ./ repmat(sqrt(sum(im1 .^ 2, 2)) + eps, [1, 3]);
im2n = im2 ./ repmat(sqrt(sum(im2 .^ 2, 2)) + eps, [1, 3]);

% DOT product and angular error
dotp = sum(im1n .* im2n, 2);
AngularErrorDist=real(acos(dotp));

% removing the zero pixels (zero in GT image)
indx = sum(im1, 2) == 0;
AngularErrorDist(indx) = [];

end
