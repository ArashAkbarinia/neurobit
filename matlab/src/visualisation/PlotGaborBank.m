function [FigureReal, FigureComplex] = PlotGaborBank(GaborKernels)
%PlotGaborBank  plots all the kernes in the Gabor bank.
%
% inputs
%   GaborKernels  the Gabor bank.
%
% outputs
%   FigureReal     the id of the figure for the real part.
%   FigureComplex  the id of the figure for the compelx part.
%

FigureReal = DisplayMat4D(GaborKernels, true);
FigureComplex = DisplayMat4D(GaborKernels, false);

end

function FigureHandler = DisplayMat4D(GaborKernels, isreal)

[z, w] = size(GaborKernels);

if isreal
  title = 'real';
else
  title = 'compelx';
end

k = 1;
FigureHandler = figure('NumberTitle', 'Off', 'Name', [title, ' part of Gabor Bank']);
for i = 1:z
  for j = 1:w
    subplot(z, w, k);
    if isreal
      imshow(real(GaborKernels{i, j}), []);
    else
      imshow(abs(GaborKernels{i, j}), []);
    end
    k = k + 1;
  end
end

end
