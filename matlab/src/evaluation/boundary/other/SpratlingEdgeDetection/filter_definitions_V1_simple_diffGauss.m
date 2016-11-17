function [wFF,wFB,wFFonoff,wFBonoff]=filter_definitions_V1_simple_diffGauss(wFF,wFB,weightScale,appendToChannels,phaseVals)
%Define weights for V1 simple cell RFs. Weights are defined using derivatives of Gaussians. Note, this function only produces masks with phases of 0,90,180, and 270 degrees, it can not produce masks with other phases. 
disp('filter_definitions_V1_simple_diffGauss');
GP=global_parameters;
angleVals=GP.V1angles;

norm=1; %normalise individual masks to sum to unity (prior to subsequent normalisation across scales).

if nargin<5 || isempty(phaseVals), phaseVals=[0,180,90,270]; end

if nargin<3 || isempty(weightScale), weightScale=1; end
disp(['  weightScale=',num2str(weightScale)]);

if nargin<1 || isempty(wFF)
  nMasksInitial=0;
  nChannelsInitial=0;
else %append new filters onto those already defined
  if appendToChannels
    nMasksInitial=0;
    nChannelsInitial=size(wFF,2);
  else
    nMasksInitial=size(wFF,1); 
    nChannelsInitial=0;
  end
end

sc=0;
for sigma=GP.V1sigmaWidth
  sc=sc+1;
  aspect=GP.V1sigmaLength/sigma;
  k=nMasksInitial;
  for phase=phaseVals
    %define Gaussian differenial masks at angle zero
    if phase==90 || phase==270
      
      order=1;offset=0; %-0.5
      mask=gauss2D(sigma,0,aspect,norm,odd(7*sigma*max(1,aspect)),0,offset,order);
      
      if phase==270
        %rotate mask (odd masks defined for 0 to 360 degrees)
        mask=flipud(fliplr(mask)); %imrotate(mask,180,'bilinear','crop'); 
      end
    elseif phase==0 || phase==180

      order=2;offset=0;
      mask=gauss2D(sigma,0,aspect,norm,odd(7*sigma*max(1,aspect)),0,offset,order);

      if phase==180
        mask=-mask; %invert mask
      end  
    end
    mask=single(mask); %use single precision for speed

    for angle=angleVals
      %rotate mask and split into positive and negative parts
      k=k+1;
      rotmask=imrotate(mask,angle,'bicubic','crop');
      rotmask=rotmask./sum(sum(abs(rotmask)));%normalise FF weights to sum to 1
      wFFonoff{k,nChannelsInitial+sc}=rotmask;
      wFF{k,nChannelsInitial+2*sc-1}=max(0,rotmask); %ON channel (+ve part)
      wFF{k,nChannelsInitial+2*sc}=max(0,-rotmask); %OFF channel (-ve part)
      rotmask=weightScale.*rotmask./max(max(abs(rotmask)));%normalise FB weights to have max of 1
  	  wFBonoff{k,nChannelsInitial+sc}=rotmask;
  	  wFB{k,nChannelsInitial+2*sc-1}=max(0,rotmask); %ON channel (+ve part)
  	  wFB{k,nChannelsInitial+2*sc}=max(0,-rotmask); %OFF channel (-ve part)
    end
  end
end
