function IsoilluminatedImage = isoilluminate(InputImage)
%ISOILLUMINATE  convert a chromatic image into an isoilluminant one.
%
% inputs
%   InputImage  the input chromatic image.
%
% outputs
%   IsoilluminatedImage  the coloured isoilluminated output image.
%

InputImge = double(InputImage);
MeanImage = sum(InputImge, 3);

IsoilluminatedImage = InputImge ./ repmat(MeanImage, [1, 1, 3]);

IsoilluminatedImage(isnan(IsoilluminatedImage)) = 0;

end
