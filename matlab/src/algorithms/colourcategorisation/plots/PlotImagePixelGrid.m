function h = PlotImagePixelGrid(InputImage, gts)
%PlotImagePixelGrid  plotting the results with gts on top
%
% inputs
%   InputImage  the labelled imaged.
%   gts         {berlin, sturge}.
%
% outputs
%   h  the figure number.
%

InputImage([1, 10], 2:end, :) = 128;
figure(2);
h = imshow(InputImage, 'InitialMagnification', 'fit');

hold on;

if strcmpi(gts, 'berlin')
  PlotGreenBerlin();
  PlotBlueBerlin();
  PlotPurpleBerlin();
  PlotPinkBerlin();
  PlotRedBerlin();
  PlotOrangeBerlin();
  PlotYellowBerlin();
  PlotBrownBerlin();
  PlotGreyBerlin();
  PlotWhiteBerlin();
  PlotBlackBerlin();
end

if strcmpi(gts, 'sturge')
  PlotGreenSturge();
  PlotBlueSturge();
  PlotPurpleSturge();
  PlotPinkSturge();
  PlotRedSturge();
  PlotOrangeSturge();
  PlotYellowSturge();
  PlotBrownSturge();
  PlotGreySturge();
  PlotWhiteSturge();
  PlotBlackSturge();
end

hold off;

end

function [] = PlotGreenBerlin()

x = [13.5, 20.5];
y = [3.5, 3.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [20.5, 22.5];
y = [5.5, 5.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [22.5, 23.5];
y = [7.5, 7.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [13.5, 15.5];
y = [8.5, 8.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [15.5, 23.5];
y = [9.5, 9.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');

x = [13.5, 13.5];
y = [3.5, 8.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [15.5, 15.5];
y = [8.5, 9.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [20.5, 20.5];
y = [3.5, 5.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [22.5, 22.5];
y = [5.5, 7.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [23.5, 23.5];
y = [7.5, 9.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');

end

function [] = PlotBlueBerlin()

x = [23.5, 23.5];
y = [1.5, 9.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [31.5, 31.5];
y = [1.5, 9.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [23.5, 31.5];
y = [1.5, 1.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [23.5, 31.5];
y = [9.5, 9.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');

end

function [] = PlotPurpleBerlin()

x = [32.5, 37.5];
y = [4.5, 4.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [37.5, 38.5];
y = [5.5, 5.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [38.5, 39.5];
y = [6.5, 6.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [39.5, 40.5];
y = [7.5, 7.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [40.5, 41.5];
y = [8.5, 8.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [32.5, 41.5];
y = [9.5, 9.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');

x = [32.5, 32.5];
y = [4.5, 9.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [37.5, 37.5];
y = [4.5, 5.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [38.5, 38.5];
y = [5.5, 6.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [39.5, 39.5];
y = [6.5, 7.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [40.5, 40.5];
y = [7.5, 8.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [41.5, 41.5];
y = [8.5, 9.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');

end

function [] = PlotPinkBerlin()

x = [1.5, 1.5];
y = [1.5, 4.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [3.5, 3.5];
y = [1.5, 4.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [1.5, 3.5];
y = [1.5, 1.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [1.5, 3.5];
y = [4.5, 4.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');

x = [37.5, 41.5];
y = [1.5, 1.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [37.5, 38.5];
y = [4.5, 4.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [38.5, 41.5];
y = [5.5, 5.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [37.5, 37.5];
y = [1.5, 4.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [38.5, 38.5];
y = [4.5, 5.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [41.5, 41.5];
y = [1.5, 5.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');

end

function [] = PlotRedBerlin()

x = [2.5, 4.5];
y = [5.5, 5.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [1.5, 2.5];
y = [6.5, 6.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [2.5, 2.5];
y = [5.5, 6.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [1.5, 1.5];
y = [6.5, 8.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [4.5, 4.5];
y = [5.5, 8.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [1.5, 4.5];
y = [8.5, 8.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');

end

function [] = PlotOrangeBerlin()

x = [3.5, 6.5];
y = [3.5, 3.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [3.5, 4.5];
y = [5.5, 5.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [4.5, 6.5];
y = [6.5, 6.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [3.5, 3.5];
y = [3.5, 5.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [4.5, 4.5];
y = [5.5, 6.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [6.5, 6.5];
y = [3.5, 6.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');

end

function [] = PlotYellowBerlin()

x = [10.5, 12.5];
y = [1.5, 1.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [8.5, 10.5];
y = [2.5, 2.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [11.5, 12.5];
y = [2.5, 2.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [8.5, 11.5];
y = [3.5, 3.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [10.5, 10.5];
y = [1.5, 2.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [12.5, 12.5];
y = [1.5, 2.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [11.5, 11.5];
y = [2.5, 3.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [8.5, 8.5];
y = [2.5, 3.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');

end

function [] = PlotBrownBerlin()

x = [6.5, 8.5];
y = [6.5, 6.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [5.5, 6.5];
y = [7.5, 7.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [5.5, 8.5];
y = [9.5, 9.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [6.5, 6.5];
y = [6.5, 7.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [5.5, 5.5];
y = [7.5, 9.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [8.5, 8.5];
y = [6.5, 9.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');

end

function [] = PlotGreyBerlin()

x = [0.5, 0.5];
y = [2.5, 8.5];
plot(x, y, 'Color', 'blue', 'LineStyle', '--');
x = [1.5, 1.5];
y = [2.5, 8.5];
plot(x, y, 'Color', 'blue', 'LineStyle', '--');
x = [0.5, 1.5];
y = [2.5, 2.5];
plot(x, y, 'Color', 'blue', 'LineStyle', '--');
x = [0.5, 1.5];
y = [8.5, 8.5];
plot(x, y, 'Color', 'blue', 'LineStyle', '--');

end

function [] = PlotWhiteBerlin()

x = [0.5, 0.5];
y = [0.5, 2.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [1.5, 1.5];
y = [0.5, 2.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [0.5, 1.5];
y = [0.5, 0.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [0.5, 1.5];
y = [2.5, 2.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');

end

function [] = PlotBlackBerlin()

x = [0.5, 0.5];
y = [8.5, 10.5];
plot(x, y, 'Color', 'white', 'LineStyle', '--');
x = [1.5, 1.5];
y = [8.5, 10.5];
plot(x, y, 'Color', 'white', 'LineStyle', '--');
x = [0.5, 1.5];
y = [8.5, 8.5];
plot(x, y, 'Color', 'white', 'LineStyle', '--');
x = [0.5, 1.5];
y = [10.5, 10.5];
plot(x, y, 'Color', 'white', 'LineStyle', '--');

end

function [] = PlotGreenSturge()

x = [13.5, 20.5];
y = [3.5, 3.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [20.5, 22.5];
y = [5.5, 5.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [22.5, 23.5];
y = [7.5, 7.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [13.5, 15.5];
y = [8.5, 8.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [15.5, 23.5];
y = [9.5, 9.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');

x = [13.5, 13.5];
y = [3.5, 8.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [15.5, 15.5];
y = [8.5, 9.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [20.5, 20.5];
y = [3.5, 5.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [22.5, 22.5];
y = [5.5, 7.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [23.5, 23.5];
y = [7.5, 9.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');

end

function [] = PlotBlueSturge()

x = [23.5, 23.5];
y = [1.5, 9.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [31.5, 31.5];
y = [1.5, 9.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [23.5, 31.5];
y = [1.5, 1.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [23.5, 31.5];
y = [9.5, 9.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');

end

function [] = PlotPurpleSturge()

x = [32.5, 37.5];
y = [4.5, 4.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [37.5, 38.5];
y = [5.5, 5.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [38.5, 39.5];
y = [6.5, 6.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [39.5, 40.5];
y = [7.5, 7.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [40.5, 41.5];
y = [8.5, 8.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [32.5, 41.5];
y = [9.5, 9.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');

x = [32.5, 32.5];
y = [4.5, 9.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [37.5, 37.5];
y = [4.5, 5.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [38.5, 38.5];
y = [5.5, 6.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [39.5, 39.5];
y = [6.5, 7.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [40.5, 40.5];
y = [7.5, 8.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [41.5, 41.5];
y = [8.5, 9.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');

end

function [] = PlotPinkSturge()

x = [1.5, 1.5];
y = [2.5, 4.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [2.5, 2.5];
y = [2.5, 4.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [1.5, 2.5];
y = [2.5, 2.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [1.5, 2.5];
y = [4.5, 4.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');

x = [40.5, 41.5];
y = [2.5, 2.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [39.5, 40.5];
y = [3.5, 3.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [38.5, 39.5];
y = [4.5, 4.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [38.5, 41.5];
y = [5.5, 5.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');

x = [38.5, 38.5];
y = [4.5, 5.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [39.5, 39.5];
y = [3.5, 4.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [40.5, 40.5];
y = [2.5, 3.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [41.5, 41.5];
y = [2.5, 5.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');

end

function [] = PlotRedSturge()

x = [2.5, 4.5];
y = [6.5, 6.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [2.5, 3.5];
y = [7.5, 7.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [3.5, 4.5];
y = [8.5, 8.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [2.5, 2.5];
y = [6.5, 7.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [3.5, 3.5];
y = [7.5, 8.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [4.5, 4.5];
y = [6.5, 8.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');

end

function [] = PlotOrangeSturge()

x = [5.5, 5.5];
y = [3.5, 5.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [7.5, 7.5];
y = [3.5, 5.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [5.5, 7.5];
y = [3.5, 3.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [5.5, 7.5];
y = [5.5, 5.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');

end

function [] = PlotYellowSturge()

x = [10.5, 12.5];
y = [1.5, 1.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [9.5, 10.5];
y = [2.5, 2.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [11.5, 12.5];
y = [2.5, 2.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [9.5, 11.5];
y = [3.5, 3.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [10.5, 10.5];
y = [1.5, 2.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [12.5, 12.5];
y = [1.5, 2.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [11.5, 11.5];
y = [2.5, 3.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [9.5, 9.5];
y = [2.5, 3.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');

end

function [] = PlotBrownSturge()

x = [6.5, 8.5];
y = [6.5, 6.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [5.5, 6.5];
y = [7.5, 7.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [5.5, 8.5];
y = [9.5, 9.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [6.5, 6.5];
y = [6.5, 7.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [5.5, 5.5];
y = [7.5, 9.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [8.5, 8.5];
y = [6.5, 9.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');

end

function [] = PlotGreySturge()

x = [0.5, 0.5];
y = [4.5, 6.5];
plot(x, y, 'Color', 'blue', 'LineStyle', '--');
x = [1.5, 1.5];
y = [4.5, 6.5];
plot(x, y, 'Color', 'blue', 'LineStyle', '--');
x = [0.5, 1.5];
y = [4.5, 4.5];
plot(x, y, 'Color', 'blue', 'LineStyle', '--');
x = [0.5, 1.5];
y = [6.5, 6.5];
plot(x, y, 'Color', 'blue', 'LineStyle', '--');

end

function [] = PlotWhiteSturge()

x = [0.5, 0.5];
y = [0.5, 1.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [1.5, 1.5];
y = [0.5, 1.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [0.5, 1.5];
y = [0.5, 0.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');
x = [0.5, 1.5];
y = [1.5, 1.5];
plot(x, y, 'Color', 'black', 'LineStyle', '--');

end

function [] = PlotBlackSturge()

x = [0.5, 0.5];
y = [9.5, 10.5];
plot(x, y, 'Color', 'white', 'LineStyle', '--');
x = [1.5, 1.5];
y = [9.5, 10.5];
plot(x, y, 'Color', 'white', 'LineStyle', '--');
x = [0.5, 1.5];
y = [9.5, 9.5];
plot(x, y, 'Color', 'white', 'LineStyle', '--');
x = [0.5, 1.5];
y = [10.5, 10.5];
plot(x, y, 'Color', 'white', 'LineStyle', '--');

end
