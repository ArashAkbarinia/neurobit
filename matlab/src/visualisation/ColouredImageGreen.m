function OutputImage = ColouredImageGreen(InputImage)
%ColouredImageGreen  converts a gray level image into a green image.
%
% inputs
%   InputImage  the input gray scale image
%
% outputs
%   OutputImage  the RGB image which is green.
%

InputImage = NormaliseChannel(InputImage, 0, 1, [], []);

OutputImage = InputImage;
OutputImage(:, :, 2) = OutputImage;
OutputImage(:, :, [1, 3]) = 0;
OutputImage = uint8(OutputImage .* 255);

end
