function OutputPyramid = LaplacianPyramid(InputImage, nlevels, sigma, plotme)
%LaplacianPyramid  creates the Laplacian pyramid.

if nargin < 4
  plotme = false;
end
if nargin < 3
  sigma = 0.5;
end

GaussPyramid = GaussianPyramid(InputImage, nlevels + 1, sigma, false);

OutputPyramid = cell(nlevels, 1);
for i = 1:nlevels
  [rows, cols, ~] = size(GaussPyramid{i, 1});
  NextGauss = imresize(GaussPyramid{i + 1, 1}, [rows, cols], 'nearest');
  OutputPyramid{i, 1} = GaussPyramid{i, 1} - NextGauss;
end

if plotme
  figure;
  for i = 1:nlevels
    subplot(1, nlevels, i); imshow(OutputPyramid{i, 1}, []); title([' (level=', num2str(i), ')']);
  end
end

end
