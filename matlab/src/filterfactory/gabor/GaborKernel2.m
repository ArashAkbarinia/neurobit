function kernel = GaborKernel2(theta, sigmax, sigmay, bandwidth, frequency, offset, scale)
%GaborKernel2  creates a gabor kernel with the passed parameters.
%
% inputs
%   theta      orientations in radians.
%   sigmax     the sigma in x direction.
%   sigmay     the sigma in y direction.
%   bandwidth  the bandwidth captured by the filter.
%   frequency  wavelength of the sinusoidal factor.
%   offset     controls the phase offset.
%   scale      scale factor to be multiplied by the kernel.
%
% outputs
%   kernel  the computed Gabor kernel
%
%   See also GaborBank
%

if nargin < 1 || isempty(theta)
  theta = 0;
end
if nargin < 2 || isempty(sigmax)
  if nargin < 4 || isempty(frequency)
    frequency = 0.05;
  end
  if nargin < 5 || isempty(bandwidth)
    bandwidth = 1.0;
  end
  sigmax = SigmaPrefactor(bandwidth) / frequency;
end
if nargin < 3 || isempty(sigmay)
  sigmay = sigmax;
end
if nargin < 4 || isempty(bandwidth)
  bandwidth = 1.0;
end
if nargin < 5 || isempty(frequency)
  frequency = FrequencyPrefacotr(sigmax, bandwidth);
end
if nargin < 6 || isempty(offset)
  offset = 0.0;
end
if nargin < 7 || isempty(scale)
  scale = 1.0;
end

nstds = 1;
ct = cos(theta);
st = sin(theta);

sizex = CalculateGaussianWidth(sigmax);
sizey = CalculateGaussianWidth(sigmay);

% bounding box
if sizex > 0
  xmax = floor(sizex / 2);
else
  xmax = round(max(abs(nstds * sigmax * ct), abs(nstds * sigmay * st)));
end

if sizey > 0
  ymax = floor(sizey / 2);
else
  ymax = round(max(abs(nstds * sigmax * st), abs(nstds * sigmay * ct)));
end

xmin = -xmax;
ymin = -ymax;

[x, y] = meshgrid(xmin:xmax, ymin:ymax);

% rotation
xs =  x * ct + y * st;
ys = -x * st + y * ct;

kernel = scale * exp(-0.5 * ((xs ./ sigmax) .^ 2 + (ys ./ sigmay) .^ 2)) ./ (2 * pi * sigmax * sigmay) ...
  .* exp(1i * (2 * pi * xs * frequency + offset));

end

function sigma = SigmaPrefactor(bandwidth)
%SigmaPrefactor  calculates the sigma based on the bandwith
%
% inputs
%   bandiwdth    the bandwidth captured by the filter.
%
% outputs
%   sigma        the computed sigma
%

b2 = 2.0 ^ bandwidth;
% See http://www.cs.rug.nl/~imaging/simplecell.html
sigma = (1.0 / pi) * sqrt(log(2) / 2.0) * (b2 + 1) / (b2 - 1);

end

function frequency = FrequencyPrefacotr(sigma, bandwidth)

frequency = SigmaPrefactor(bandwidth) / sigma;

end
