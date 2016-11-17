function [X]=preprocess_V1_input(I,X)
GP=global_parameters;

[a,b,z]=size(I);
I=single(I);

if nargin<2 || isempty(X)
  nChannelsInitial=0;
else
  nChannelsInitial=length(X)
end
k=0;
for sigma=GP.LGNsigma
  k=k+1;
  LoG=filter_definitions_LGN(sigma);

  for t=1:z %at each time step
    %calculate LGN neuron responses to input image
    Xonoff=conv2(I(:,:,t),LoG,'same');

    %the edge of the image often contains strong discontinuities, so don't calculate
    %responses here. Would be better the use the 'valid' paramenter in the
    %convolution, but this produces problems when image is being analysed at
    %different scales.
    Xonoff=suppress_response_near_edges(Xonoff,odd(2.5*sigma));
    
    %apply gain to response
    Xonoff=GP.LGNresponseGain.*Xonoff;

    %apply saturation to response
    Xonoff=tanh(Xonoff);

    %split into ON and OFF channels
    Xon=Xonoff;
    Xon(find(Xon<0))=0;
    Xoff=-Xonoff;
    Xoff(find(Xoff<0))=0;
  
    X{nChannelsInitial+2*k-1}(:,:,t)=Xon;
    X{nChannelsInitial+2*k}(:,:,t)=Xoff;  
  end
end


function y=suppress_response_near_edges(y,crop)

if ~iscell(y)
  y=suppress_edges(y,crop);
else
  [nMasks]=length(y);
  for i=1:nMasks
    y{i}=suppress_edges(y{i},crop);
  end
end

function y=suppress_edges(y,crop)
[a,b]=size(y);

y(1:crop,:)=0;
y(:,1:crop)=0;
y(a-crop+1:a,:)=0;
y(:,b-crop+1:b)=0;

if 0
%linear reduction in response to zero at edges
for c=1:crop
  scale=(c/(crop+1)).^2;
  if c<=a
    y(c,:)=y(c,:).*scale;  
    y(a-c+1,:)=y(a-c+1,:).*scale;
  end
  if c<=b
    y(:,c)=y(:,c).*scale;  
    y(:,b-c+1)=y(:,b-c+1).*scale;  
  end
end
end