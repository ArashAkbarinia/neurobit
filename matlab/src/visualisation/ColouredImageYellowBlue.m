function OutputImage = ColouredImageYellowBlue(InputImage)
%ColouredImageYellowBlue  converts a gray image into a yellow-blue image.
%
% inputs
%   InputImage  the input gray scale image
%
% outputs
%   OutputImage  the RGB image which is yellow-blue opponency.
%

InputImage = InputImage ./ max(abs(InputImage(:)));

OutputImage(:, :, 1) = max(InputImage, 0);
OutputImage(:, :, 2) = OutputImage(:, :, 1);
OutputImage(:, :, 3) = max(-InputImage, 0);
OutputImage = uint8(NormaliseChannel(OutputImage, 0, 1, [], []) .* 255);

end
