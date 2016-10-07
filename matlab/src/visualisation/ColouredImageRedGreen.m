function OutputImage = ColouredImageRedGreen(InputImage)
%ColouredImageRedGreen  converts a gray level image into a red-green image.
%
% inputs
%   InputImage  the input gray scale image
%
% outputs
%   OutputImage  the RGB image which is red-green opponency.
%

InputImage = InputImage ./ max(abs(InputImage(:)));

OutputImage(:, :, 1) = max(InputImage, 0);
OutputImage(:, :, 2) = max(-InputImage, 0);
OutputImage(:, :, 3) = 0;
OutputImage = uint8(NormaliseChannel(OutputImage, 0, 1, [], []) .* 255);

end
