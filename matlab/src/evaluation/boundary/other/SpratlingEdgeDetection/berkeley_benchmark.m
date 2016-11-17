function berkeley_benchmark
benchdir='BENCH';
pres='gray'
alg='full_cpcp'

iids = imgList('test'); %read list of test images from Berkeley dataset
dirname = fullfile(benchdir,pres,alg); %directory in which edge images are stored

[visFilters]=filter_definitions_V1_edge_recon;
%run algorithm to calculate edge images
for i = 1:numel(iids),
  iid = iids(i);
  fprintf(2,'Computing Pb for image %d/%d (iid=%d) \n',i,numel(iids),iid);
  if ~exist(fullfile(dirname,sprintf('%d.mat',iid)),'file')
    clf
    I=imgRead(iid,pres); %load image to process
    I=single(I); 
    maxsubplot(2,2,3); plot_cropped_image(abs(I-1),6,[0,1]); 
    
    X=preprocess_V1_input(I);
    
    [y,sparsity(i)]=v1_edge_detection(X);
    
    save(fullfile(dirname,sprintf('%d.mat',iid)),'y');
    
    reduceRange=0.25;
    nonmax=1;
    pb=reconstruct_edges(y,visFilters,[1:length(y)/2],0,reduceRange,nonmax);
    
    %ensure pb is same size as original (incase v1 model has resized it)
    [a,b]=size(I);
    pb=pb(1:a,1:b);
    
    imwrite(pb,fullfile(dirname,sprintf('%d.bmp',iid)),'bmp');
  end
end

%compare results with human segmentations
fprintf(2,'Benchmarking algorithm (takes a while!)...\n');
boundaryBench(dirname,pres);

%create precision/recall graphs
fprintf(2,'Generating benchmark graphs for this algorithm...\n');
boundaryBenchGraphs(dirname);

%compare results for each pair of algorithms
fprintf(2,'Generating benchmark graphs to compare algorithms...\n');
boundaryBenchGraphsMulti(benchdir);

%create webpages for the benchmark
fprintf(2,'Generating benchmark web pages...\n');
boundaryBenchHtml(benchdir);

save(fullfile(dirname,'sparsity.mat'),'sparsity');
clf
hist(sparsity,[0.005:0.01:0.995])
h = findobj(gca,'Type','patch');
set(h,'FaceColor','b','EdgeColor','w');
set(gca,'FontSize',22);
xlabel('sparseness','FontSize',28);
ylabel('number of images','FontSize',28);
