function [LoG,LoGonoff]=filter_definitions_LGN(sigma,weightScale)
if nargin<1, sigma=1.5; end

%Laplacian of Gaussians
LoG=-fspecial('log',odd(9*sigma),sigma);
%To avoid using Image Processing toolbox try:
%LoG=gauss2D(sigma-0.0001,0,1,1,odd(9*sigma))-gauss2D(sigma+0.0001,0,1,1,odd(9*sigma));
%LoG=gauss2D(sigma./sqrt(2),0,1,1,odd(9*sigma))-gauss2D(sigma.*sqrt(2),0,1,1,odd(9*sigma))

%use single precision for speed
LoG=single(LoG);

%normalise weights
tmp=LoG;
tmp(find(tmp<0))=0;
LoG=LoG./sum(sum(tmp));

if nargout>1
  if nargin<2, weightScale=0.5; end
  weightScale

  wCent=LoG;
  wCent(wCent<0)=0;
  wCentr=weightScale.*wCent./sum(sum(wCent));
  
  wSurr=LoG;
  wSurr(wSurr>0)=0;
  wSurr=abs(wSurr);
  wSurr=weightScale.*wSurr./sum(sum(wSurr));
  
  LoGonoff{1,1}=wCent; LoGonoff{1,2}=wSurr; %on-centre/off-surround
  LoGonoff{2,2}=wCent; LoGonoff{2,1}=wSurr; %off-centre/on-surround
end
