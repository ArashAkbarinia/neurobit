function ReconVis=reconstruct_edges_multiscale(scales,y,wVis,selectedFilters,maxOnly,reduceRange,nonmaxSuppression)
nScales=length(scales)
nMasks=length(y{1});
[a,b]=size(y{1}{1});%assumes 1st set of responses are for smallest scale

if nargin<4 || isempty(selectedFilters), selectedFilters=[1:nMasks]; end
if nargin<5 || isempty(maxOnly), maxOnly=0; end
if nargin<6 || isempty(reduceRange), reduceRange=1; end
if nargin<7 || isempty(nonmaxSuppression), nonmaxSuppression=0; end

if maxOnly, disp('maxonly'); end
ReconVis=zeros(a,b); %assumes 1st set of responses are for smallest scale
for i=selectedFilters
  r{i}=zeros(a,b);
  for scale=1:nScales
    ymax=max(cat(3,y{scale}{:}),[],3);
    if maxOnly, y{scale}{i}(y{scale}{i}<ymax)=0; end
    rtmp=imresize(conv2(y{scale}{i},wVis{i},'same'),1/scales(scale));
    r{i}=r{i}+rtmp(1:a,1:b); %separate reconstruction for each RF type
  end
  ReconVis=ReconVis+r{i}; %sum reconstruction over each RF type
end
[poo,angmaxIndex]=max(cat(3,r{:}),[],3);

if nonmaxSuppression==1
  disp('nonmax')
  GP=global_parameters;
  angmax=zeros(a,b);
  for i=min(angmaxIndex):max(angmaxIndex)
    angmax(angmaxIndex==i)=GP.V1angles(mod(i-1,length(GP.V1angles))+1);
  end
  angmax=mod((180-angmax).*pi/180,pi); ReconVis=nonmax(ReconVis,angmax);
  %angmax=mod(90-angmax,180); ReconVis=nonmaxsup(ReconVis,angmax,1.4); %Kovesi's
end
if reduceRange<1
  disp('reduce')
  %ReconVis=ReconVis.^reduceRange;
  %ReconVis=log(1+ReconVis);
  thres=reduceRange.*max(max(ReconVis)); ReconVis(ReconVis>=thres)=thres;
end

ReconVis=ReconVis./max(max(ReconVis)); 
