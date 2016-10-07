function OutputImage = ColouredImageRed(InputImage)
%ColouredImageRed  converts a gray level image into a red image.
%
% inputs
%   InputImage  the input gray scale image
%
% outputs
%   OutputImage  the RGB image which is red.
%

InputImage = NormaliseChannel(InputImage, 0, 1, [], []);

OutputImage = InputImage;
OutputImage(:, :, 2:3) = 0;
OutputImage = uint8(OutputImage .* 255);

end
