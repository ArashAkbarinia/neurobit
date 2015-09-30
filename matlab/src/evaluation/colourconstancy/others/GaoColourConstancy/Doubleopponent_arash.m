function DO = Doubleopponent_arash(SO,Sgaus,Lgaus,k)

[rows, cols] = size(SO);

contraststd = LocalStdContrast(SO, 3);
zctr = 1 - contraststd;

nContrastLevels = 4;
StartingSigma = 1.25;
FinishingSigma = 12 * StartingSigma;
sigmas = linspace(StartingSigma, FinishingSigma, nContrastLevels);
% StartingSigma = 1.5;
% sigmas = zeros(1, nContrastLevels);
% for i = 1:nContrastLevels
%   sigmas(i) = StartingSigma ^ i;
% end
sigmas = sigmas(end:-1:1);

levels = 0:(1.0 / nContrastLevels):1;
levels = levels(2:end-1);
ContrastLevels = imquantize(zctr, levels);

nContrastLevels = max(ContrastLevels(:));
DO = zeros(rows, cols);

for i = 1:nContrastLevels
  sigma = sigmas(i);
  Sgaus = Gauss1D(sigma);
  Lgaus = Gauss1D(3*sigma);

  Sx=imfilter(SO,Sgaus,'conv','replicate');   % run the filter accross rows
  Csmooth=imfilter(Sx,Sgaus','conv','replicate'); % and then accross columns
  Lx=imfilter(SO,Lgaus,'conv','replicate');   % run the filter accross rows
  Ssmooth=imfilter(Lx,Lgaus','conv','replicate'); % and then accross columns
  DO(ContrastLevels == i) = Csmooth(ContrastLevels == i) - k*Ssmooth(ContrastLevels == i);
end

end
