function berkeley_benchmark_postprocess
benchdir='BENCH';
pres='gray'
alg='full_cpcp_anglesstep15'
%alg='mini_cpcp'

%directory from which raw data is read
sourcedirname = fullfile(benchdir,pres,alg); 

%directories in which post-processed edge images are stored
algpp=alg; %'full_cpcp_test'
dirnameout = fullfile(benchdir,pres,algpp);
						 
iids = imgList('test'); %read list of test images from Berkeley dataset

[visFilters]=filter_definitions_V1_edge_recon;
%post-process edge images
for i = 1:numel(iids),
  iid = iids(i);
  fprintf(2,'Computing Pb for image %d/%d (iid=%d) \n',i,numel(iids),iid);
  
  load(fullfile(sourcedirname,sprintf('%d.mat',iid)));
  
  reduceRange=0.25;
  nonmax=1;
  %pb=reconstruct_edges(y,visFilters);
  pb=reconstruct_edges(y,visFilters,[1:length(y)/2],0,reduceRange,nonmax);
  %pb=reconstruct_edges(y,visFilters,[],1);
  %nScales=5;scales=(1/sqrt(2)).^[0:nScales-1]
  %pb=reconstruct_edges_multiscale(scales,y,visFilters,[1:length(y{1})/2],0,reduceRange,nonmax);
  
  %ensure pb is same size as original (incase v1 model has resized it)
  I=imgRead(iid,pres);
  [a,b]=size(I);
  pb=pb(1:a,1:b);
  
  imwrite(pb,fullfile(dirnameout,sprintf('%d.bmp',iid)),'bmp');
end

%perform benchmarking on each set of post-processed images

%compare results with human segmentations
fprintf(2,'Benchmarking algorithm (takes a while!)...\n');
boundaryBench(dirnameout,pres);

%create precision/recall graphs
fprintf(2,'Generating benchmark graphs for this algorithm...\n');
boundaryBenchGraphs(dirnameout);

%compare results for each pair of algorithms
%fprintf(2,'Generating benchmark graphs to compare algorithms...\n');
%boundaryBenchGraphsMulti(benchdir);

%create webpages for the benchmark
fprintf(2,'Generating benchmark web pages...\n');
boundaryBenchHtml(benchdir);
