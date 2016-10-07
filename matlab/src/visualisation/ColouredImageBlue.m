function OutputImage = ColouredImageBlue(InputImage)
%ColouredImageBlue  converts a gray level image into a blue image.
%
% inputs
%   InputImage  the input gray scale image
%
% outputs
%   OutputImage  the RGB image which is blue.
%

InputImage = NormaliseChannel(InputImage, 0, 1, [], []);

OutputImage = InputImage;
OutputImage(:, :, 3) = OutputImage(:, :, 1);
OutputImage(:, :, 1:2) = 0;
OutputImage = uint8(OutputImage .* 255);

end
