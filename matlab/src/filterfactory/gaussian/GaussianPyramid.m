function OutputPyramid = GaussianPyramid(InputImage, nlevels, sigma, plotme)
%GaussianPyramid  creates the Gaussian pyramid.

if nargin < 4
  plotme = false;
end
if nargin < 3
  sigma = 0.5;
end

OutputPyramid = cell(nlevels, 1);
OutputPyramid{1, 1} = InputImage;
for i = 2:nlevels
  GaussianFilter = GaussianFilter2(sigma);
  CurrentGauss = imfilter(OutputPyramid{i - 1, 1}, GaussianFilter, 'replicate');
  OutputPyramid{i, 1} = imresize(CurrentGauss, 0.5, 'nearest');
end

if plotme
  figure;
  for i = 1:nlevels
    subplot(1, nlevels, i); imshow(OutputPyramid{i, 1}, []); title([' (level=', num2str(i), ')']);
  end
end

end
