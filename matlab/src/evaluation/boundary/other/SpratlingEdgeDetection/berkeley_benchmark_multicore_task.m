function [resultsCell]=berkeley_benchmark_multicore_task(iid,pres,dirname)
  fprintf(2,'Computing Pb for image iid=%d \n',iid);

  clf 
  I=imgRead(iid,pres); %load image to process
  I=single(I); 
  maxsubplot(2,2,3); plot_cropped_image(abs(I-1),6,[0,1]); 
  X=preprocess_V1_input(I);

  [y,s]=v1_edge_detection(X);
  %[y,s]=v1_edge_detection_multiscalelateral(X);
  
  save(fullfile(dirname,sprintf('%d.mat',iid)),'y');

  reduceRange=0.25;
  nonmax=1;
  [visFilters]=filter_definitions_V1_edge_recon;
  pb=reconstruct_edges(y,visFilters,[1:length(y)/2],0,reduceRange,nonmax);

  %ensure pb is same size as original (incase v1 model has resized it)
  [a,b]=size(I);
  pb=pb(1:a,1:b);

  imwrite(pb,fullfile(dirname,sprintf('%d.bmp',iid)),'bmp');
  resultsCell={iid,s};