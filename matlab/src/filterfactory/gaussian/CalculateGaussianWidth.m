function FilterWidth = CalculateGaussianWidth(sigma, MaxWidth)
%CalculateGaussianWidth  calculates the descrete width of Gaussian filter.
%
% inputs
%   sigma     the sigma of Gaussian filter.
%   MaxWidth  the maximum allowed width of the filter, default is 100.
%
% outputs
%   FilterWidth  the descrete width of the filter
%


if nargin < 2
  MaxWidth = 100;
end

threshold = 0.0001;
pw = 1:MaxWidth;
FilterWidth = find(exp(-(pw .^ 2) / (2 * sigma .^ 2)) > threshold, 1, 'last');
if isempty(FilterWidth)
  warning(['input sigma ', num2str(sigma), ' is too small, returning width 5.'], 'CalculateGaussianWidth:SmallSigma');
  FilterWidth = 5;
end
FilterWidth = FilterWidth .* 2 + 1;

end
