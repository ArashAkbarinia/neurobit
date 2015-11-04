function g1 = Gaussian1Gradient1(GaussianKernel)
%Gaussian1Gradient1  calculating the gradient of 1D Gaussian.
%
% inputs
%   GaussianKernel  the Gaussian filter.
%
% outputs
%   g1  the derivative at angle theta.
%

g1 = gradient(GaussianKernel);

end
