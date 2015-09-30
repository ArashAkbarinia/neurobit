function [Rw,Gw,Bw]=norm_derivative_arash(in, sigma, order)

if(nargin<3)
  order=1;
end

R=in(:,:,1);
G=in(:,:,2);
B=in(:,:,3);

Rw = norm_derivative_onechannel(R, sigma, order);
Gw = norm_derivative_onechannel(G, sigma, order);
Bw = norm_derivative_onechannel(B, sigma, order);

end

function Rw = norm_derivative_onechannel(in, sigma, order)

if(nargin<3)
  order=1;
end

R=in(:,:,1);

ContrastImx = GetContrastImage(R, [17, 1]);
ContrastImy = GetContrastImage(R, [1, 17]);

nContrastLevels = 4;
StartingSigma = sigma;
FinishingSigma = sigma * 2;
sigmas = linspace(StartingSigma, FinishingSigma, nContrastLevels);

ContrastLevelsX = GetContrastLevels(ContrastImx, nContrastLevels);
ContrastLevelsY = GetContrastLevels(ContrastImy, nContrastLevels);

nContrastLevelsX = unique(ContrastLevelsX(:));
nContrastLevelsX = nContrastLevelsX';

nContrastLevelsY = unique(ContrastLevelsY(:));
nContrastLevelsY = nContrastLevelsY';

[rows, cols, ~] = size(R);
Rw = zeros(rows, cols);
for i = nContrastLevelsX
  sigmax = sigmas(i);
  for j = nContrastLevelsY
    sigmay = sigmas(j);
    if(order==1)
      Rx=gDer(R,sigmax,1,0);
      Ry=gDer(R,sigmay,0,1);
      rfresponsei=sqrt(Rx.^2+Ry.^2);
      Rw(ContrastLevelsX == i & ContrastLevelsY == j) = rfresponsei(ContrastLevelsX == i & ContrastLevelsY == j);
    end
    
    if(order==2)        %computes frobius norm
      Rxx=gDer(R,sigmax,2,0);
      Ryy=gDer(R,sigmay,0,2);
      Rxy=gDer(R,(sigmax + sigmay) / 2,1,1);
      rfresponsei=sqrt(Rxx.^2+4*Rxy.^2+Ryy.^2);
      Rw(ContrastLevelsX == i & ContrastLevelsY == j) = rfresponsei(ContrastLevelsX == i & ContrastLevelsY == j);
    end
  end
end

end

function ContrastLevels = GetContrastLevels(ContrastIm, nContrastLevels)

MinPix = min(ContrastIm(:));
MaxPix = max(ContrastIm(:));
step = ((MaxPix - MinPix) / nContrastLevels);
levels = MinPix:step:MaxPix;
levels = levels(2:end-1);
ContrastLevels = imquantize(ContrastIm, levels);

end

function ContrastImage = GetContrastImage(isignal, SurroundSize)

if nargin < 2
  SurroundSize = [3, 3];
end
contraststd = LocalStdContrast(isignal, SurroundSize);

% contraststd = stdfilt(isignal);
% rf = dog2(GaussianFilter2(0.5), GaussianFilter2(2.5));
% rf = GaussianGradient2(GaussianFilter2(2.5));
% contraststd = imfilter(isignal, rf, 'replicate');
% contraststd = contraststd + abs(min(contraststd(:)));
% contraststd = contraststd ./ max(contraststd(:));

% [rgc, rgs] = RelativePixelContrast(isignal, 3);
% contraststd = rgc ./ rgs;
% contraststd(isnan(contraststd)) = 0;
% contraststd(isinf(contraststd)) = 1;
% contraststd(contraststd > 1) = 1;

% contraststd = WeberContrast(isignal);
% contraststd = contraststd ./ max(contraststd(:));

ContrastImage = 1 - contraststd;

end