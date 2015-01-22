function ColourConstantImage = ColourConstancy(InputImage, algorithm, plotme, varargin)
%ColourConstancy  wrapper for all the existing colour constancy algorithms.
%
% Inputs
%   InputImage  the input image.
%   algorithm   the name of the algorithm.
%   plotme      if you want the results be plotted.
%   varargin    the specific parameters for each algorithm.
%
% Outputs
%   ColourConstantImage  the colour constant image in range of [0, 1].
%
% See also: ColourConstancyACE, ColourConstancyGreyWorld,
%           ColourConstancyHisteq, ColourConstancyModifiedWhitePatch,
%           ColourConstancyMSRCR, ColourConstancyMultiScaleRetinex,
%           ColourConstancyProgressive, ColourConstancySingleScaleRetinex,
%           ColourConstancyWhitePatch
%

InputImage = im2double(InputImage);

algorithm = lower(algorithm);

switch algorithm
  case 'histeq'
    ColourConstantImage = ColourConstancyHisteq(InputImage);
  case 'grey world'
    ColourConstantImage = ColourConstancyGreyWorld(InputImage);
  case 'white patch'
    ColourConstantImage = ColourConstancyWhitePatch(InputImage);
  case 'modified white patch'
    if ~isempty(varargin)
      thresholds(1) = varargin{1};
      if length(varargin) == 3
        thresholds(2) = varargin{2};
        thresholds(3) = varargin{3};
      else
        thresholds(2) = thresholds(1);
        thresholds(3) = thresholds(1);
      end
      ColourConstantImage = ColourConstancyModifiedWhitePatch(InputImage, thresholds);
    else
      ColourConstantImage = InputImage;
      disp('Modified white patch algorithm must have another parameter.');
    end
  case 'progressive'
    if length(varargin) > 1
      h1 = varargin{1};
      h2 = varargin{2};
      ColourConstantImage = ColourConstancyProgressive(InputImage, h1, h2);
    else
      ColourConstantImage = InputImage;
      disp('Modified white patch algorithm must have another parameter.');
    end
  case 'single scale retinex'
    ColourConstantImage = ColourConstancySingleScaleRetinex(InputImage);
  case 'multi scale retinex'
    ColourConstantImage = ColourConstancyMultiScaleRetinex(InputImage);
  case 'msrcr'
    ColourConstantImage = ColourConstancyMSRCR(InputImage);
  case 'ace'
    ColourConstantImage = ColourConstancyACE(InputImage);
  otherwise
    ColourConstantImage = InputImage;
    disp('Unknown alogrithm, please check name.');
end

ColourConstantImage = uint8(ColourConstantImage .* 255);

if plotme
  figure('NumberTitle', 'Off', 'Name', 'Colour Constancy');
  subplot(1, 2, 1);
  imshow(InputImage);
  title('Original image');
  subplot(1, 2, 2);
  imshow(ColourConstantImage);
  title(['Algorithm ', algorithm]);
end

end
