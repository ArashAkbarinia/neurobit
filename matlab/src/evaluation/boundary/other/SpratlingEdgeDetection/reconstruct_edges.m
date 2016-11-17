function ReconVis=reconstruct_edges(y,wVis,selectedFilters,maxOnly,reduceRange,nonmaxSuppression)
nMasks=length(y);

if nargin<3 || isempty(selectedFilters), selectedFilters=[1:nMasks]; end
if nargin<4 || isempty(maxOnly), maxOnly=0; end
if nargin<5 || isempty(reduceRange), reduceRange=1; end
if nargin<6 || isempty(nonmaxSuppression), nonmaxSuppression=0; end

if maxOnly, disp('maxonly'); end
ReconVis=zeros(size(y{1}));
ymax=max(cat(3,y{:}),[],3);
for i=selectedFilters
  if maxOnly, y{i}(y{i}<ymax)=0; end
  r{i}=conv2(y{i},wVis{i},'same'); %separate reconstruction for each RF type
  ReconVis=ReconVis+r{i}; %sum reconstruction over each RF type
end
[poo,angmaxIndex]=max(cat(3,r{:}),[],3);

if nonmaxSuppression==1
  disp('nonmax')
  GP=global_parameters;
  angmax=zeros(size(y{1}));
  Isum_over_line_width=zeros(size(y{1}));
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
