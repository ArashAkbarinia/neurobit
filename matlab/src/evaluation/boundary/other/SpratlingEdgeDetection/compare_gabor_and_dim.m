function compare_gabor_and_dim
%LGNsigma=1.5; V1sigmaLength=2

I{1}=zeros(31,41);
I{1}(16,21)=1;

I{2}=zeros(31,41);
I{2}(16,20:22)=1;

I{3}=zeros(31,41);
I{3}(16,15:27)=1;

I{4}=zeros(31,41);
I{4}(16,19)=1;
%I{4}(21,21)=1;
I{4}(16,23)=1;

I{5}=im2single(imread('../Data/Images/elephant.png')); 
I{5}=I{5}(210:350,240:380);
I{5}=1-I{5}; %make image negative, so that we can invert colormap

for i=1:length(I)
  figure(i),clf
  sparsity(i,:)=do_compare(I{i});
end
sparsity


function sparsity=do_compare(I)
GP=global_parameters
crop=ceil(4*min(GP.V1sigmaWidth));
[reconFilters]=filter_definitions_V1_edge_recon;


I=single(I);
maxsubplot(1,7,1), plot_cropped_image(I,crop,[0,1]); 


%linear filtering with Gabor functions
[ymax,c,ymaxsup]=find_edges_linear(I,GP.V1sigmaWidth);
sparsity(1,1)=calc_sparsity(c);

maxsubplot(1,7,2), plot_cropped_image(ymax,crop,[0,0.3]);
r=reconstruct_edges(c,reconFilters);
maxsubplot(1,7,3), plot_cropped_image(r,crop,[0,1.5]);

%linear filtering with non-max suppression
maxsubplot(1,7,4), plot_cropped_image(ymaxsup,crop,[0,0.3]);
r=reconstruct_edges(c,reconFilters,[],1);
maxsubplot(1,7,5), plot_cropped_image(r,crop,[0,1.5]); 

%dim
X=preprocess_V1_input(I);
phases=[0,180,90,270];
[v1Filters,v1FiltersFB]=filter_definitions_V1_simple_diffGauss([],[],1,0,phases);
y=dim_activation_conv_recurrent(v1Filters,X,[],GP.iterations,v1FiltersFB);
ymax=max(cat(3,y{:}),[],3);
sparsity(1,2)=calc_sparsity(y);

maxsubplot(1,7,6), plot_cropped_image(ymax,crop,[0,0.3]); 
[reconFilters]=filter_definitions_V1_edge_recon([],[],phases);
r=reconstruct_edges(y,reconFilters,[],0);
maxsubplot(1,7,7), plot_cropped_image(r,crop,[0,1.5]); 



function [ymax,c,ymaxsup]=find_edges_linear(I,sigmaV1)
nScales=length(sigmaV1);
[a,b]=size(I);
aspect=1./sqrt(2);
GP=global_parameters;
angles=GP.V1angles;

k=0;
for phase=[0,90]
  for angle=angles
    k=k+1;
    for s=1:nScales
      sigma=sigmaV1(s);
      wavel=2*sigma;
      intensityFilters{k,s}=gabor2D(sigma,angle,wavel,phase,aspect);
      intensityFilters{k,s}=intensityFilters{k,s}./sum(sum(abs(intensityFilters{k,s})));
      intensityFilters{k,s}=intensityFilters{k,s}.*(sigmaV1(s));
    end
  end
end

[nMasks,nChannels]=size(intensityFilters);
for i=1:nMasks
  y{i}=zeros(a,b,'single');
  for j=1:nChannels
    y{i}=y{i}+filter2(intensityFilters{i,j},I,'same');
  end
end
%complex cell outputs
for o=1:8
  c{o}=sqrt((y{o}.^2)+(y{o+8}.^2));
  %reconFilters{o}=visFilters{o};
end

[ymax,angmax]=max(cat(3,c{:}),[],3);
ymaxsup=nonmax(ymax,(360-angles(mod(angmax-1,8)+1)).*pi/180);


%sigma=sigmaV1(1);
%LoG=-fspecial('log',odd(9*sigma),sigma);
%ymax=abs(filter2(LoG,I,'same'));


function s=calc_sparsity(y)
if iscell(y)
  yall=cat(3,y{:});
else
  yall=y;
end
yall=yall(:);
sqrtn=sqrt(length(yall));
s=(sqrtn-(norm(yall,1)/norm(yall,2)))/(sqrtn-1); %Hoyer's sparsity measure
