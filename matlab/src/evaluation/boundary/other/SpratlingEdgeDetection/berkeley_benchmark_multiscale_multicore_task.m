function [resultsCell]=berkeley_benchmark_multiscale_multicore_task(iid,pres,dirname)
fprintf(2,'Computing Pb for image iid=%d \n',iid);

clf 
I=imgRead(iid,pres); %load image to process
I=single(I); 
maxsubplot(2,2,3); plot_cropped_image(abs(I-1),6,[0,1]); 

[a,b]=size(I);
nScales=5;scales=(1/sqrt(2)).^[0:nScales-1]
Ip=I;
Ip=padarray(I,fix(abs([a-ceil(min(a*scales))./min(scales),b-ceil(min(b*scales))./min(scales)])),'replicate','post');
[ap,bp]=size(Ip);
[visFilters]=filter_definitions_V1_edge_recon;

k=0;
for scale=scales
  k=k+1;
  Is=imresize(Ip,scale);
  
  X=preprocess_V1_input(Is);
  
  [y{k},s(k)]=v1_edge_detection(X);
end
save(fullfile(dirname,sprintf('%d.mat',iid)),'y');

reduceRange=0.25;
nonmax=1;
pb=reconstruct_edges_multiscale(scales,y,visFilters,[1:length(y{1})/2],0,reduceRange,nonmax);

%ensure pb is same size as original (incase v1 model has resized it)
pb=pb(1:a,1:b);

imwrite(pb,fullfile(dirname,sprintf('%d.bmp',iid)),'bmp');
resultsCell={iid,mean(s)};
