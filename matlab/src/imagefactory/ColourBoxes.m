function ColourBoxesImage = ColourBoxes(scale)
%ColourBoxes creates set of focal colours.
%
% Inputs
%   scale  should the 2x11 board be scaled, default is 1.
%
% Outputs
%   ColourBoxesImage  the Macbeth colour checker if scale is not given in
%                     size 2x11.
%

if nargin < 1
  scale = 1;
end

cboxes = zeros(2, 11, 3);
cboxes(:, :, 1) = ...
  [
  0,   128, 255, 255, 255, 0, 0, 0, 255, 255, 128;
  255, 192, 128, 128, 128, 0, 0, 0, 128, 128, 255;
  ];
cboxes(:, :, 2) = ...
  [
  0,   128, 0, 128, 255, 255, 255, 0, 0, 128, 255;
  255, 192, 0, 64,  128, 128, 128, 0, 0, 128, 255;
  ];
cboxes(:, :, 3) = ...
  [
  0,   128, 0, 0, 0, 0, 255, 255, 255, 128, 128;
  255, 192, 0, 0, 0, 0, 128, 128, 128, 255, 128;
  ];

cbox1 = kron(cboxes(:, :, 1), ones(1, scale));
ColourBoxesImage(:, :, 1) = kron(cbox1, ones(scale, 1));
cbox2 = kron(cboxes(:, :, 2), ones(1, scale));
ColourBoxesImage(:, :, 2) = kron(cbox2, ones(scale, 1));
cbox3 = kron(cboxes(:, :, 3), ones(1, scale));
ColourBoxesImage(:, :, 3) = kron(cbox3, ones(scale, 1));

ColourBoxesImage = uint8(ColourBoxesImage);

end