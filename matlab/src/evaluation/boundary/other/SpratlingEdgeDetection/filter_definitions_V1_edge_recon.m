function [wRecon]=filter_definitions_V1_edge_recon(edgeWidth,edgeLength,phaseVals)
%Define weights of straight edge elements used for edge reconstruction.  Weights
%are based on prediction neuron filters. Function assumes that 1st prediction
%node has even symmetric weights. It uses central positive segement of these
%weights (averaged over scales) to define reconstruction weights.
GP=global_parameters;
angleVals=GP.V1angles;
if nargin<3 || isempty(phaseVals), phaseVals=[0,180,90,270]; end
if nargin<1 || isempty(edgeWidth), edgeWidth=1; end
if nargin<2 || isempty(edgeLength), edgeLength=GP.V1sigmaLength; end
disp('filter_definitions_V1_edge_recon');
disp(['  edgeWidth=',num2str(edgeWidth),' edgeLength=',num2str(edgeLength)]);

%define even-symmetric weights, at zero angle
order=2;offset=0;norm=1;
evenFilter=-gauss2D(edgeLength,0,1,norm,odd(7*edgeLength),0,offset,order);

%extract central 'line' from the prediction node weight
[a,b]=size(evenFilter);
line=zeros(a,b,'single');
line(ceil(a/2),:)=evenFilter(ceil(a/2),:);
line=line./max(max(line));
line=line.^0.25;
for w=1:floor((edgeWidth-1)/2) %copy weights to make line wider, if required.
  line(ceil(a/2)+w,:)=line(ceil(a/2),:);
  line(ceil(a/2)-w,:)=line(ceil(a/2),:);
end


%define reconstruction weights are all angles and phases, by copying and
%rotating the weights just defined for an angle of zero.
[a,b]=size(line);
blank=zeros(a,b,'single');
k=0;
for phase=phaseVals(:)'
  for angle=angleVals
    k=k+1;
    wRecon{k}=draw_line(blank,ceil(a/2),ceil(b/2),line,angle,1,0);
  end
end


function I=draw_line(I,x,y,line,angle,contrast,binary)
if nargin<6, contrast=1; end
if nargin<7, binary=1; end
line=imrotate(line,angle,'bilinear','crop');
line=line(2:size(line)-1,2:size(line)-1);
if binary
  line(find(line<=0.5))=0;
  line(find(line>0.5))=1;
end
line=line.*contrast;
length=size(line,1);
hlen=fix(length/2);
I(x-hlen:x+hlen,y-hlen:y+hlen)=max(I(x-hlen:x+hlen,y-hlen:y+hlen),line);
