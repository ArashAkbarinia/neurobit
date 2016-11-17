function berkeley_benchmark_multicore
benchdir='BENCH';
pres='gray'
alg='full_cpcp'

iids = imgList('test') %read list of test images from Berkeley dataset
dirname = fullfile(benchdir,pres,alg); %directory in which edge images are stored

parameterCell = cell(1, numel(iids));
for i = 1:numel(iids),
  iid = iids(i);
  parameterCell{1,i}={iid,pres,dirname};
end

%run algorithm to calculate edge images
resultCell=startmulticoremaster(@berkeley_benchmark_multicore_task, parameterCell);

%compare results with human segmentations
fprintf(2,'Benchmarking algorithm (takes a while!)...\n');
boundaryBench(dirname,pres);

%create precision/recall graphs
fprintf(2,'Generating benchmark graphs for this algorithm...\n');
boundaryBenchGraphs(dirname);

%compare results for each pair of algorithms
%fprintf(2,'Generating benchmark graphs to compare algorithms...\n');
%boundaryBenchGraphsMulti(benchdir);

%create webpages for the benchmark
fprintf(2,'Generating benchmark web pages...\n');
boundaryBenchHtml(benchdir);

sparsity=cat(1,resultCell{:});
sparsity=cell2mat(sparsity(:,2))
save(fullfile(dirname,'sparsity.mat'),'sparsity');
clf
hist(sparsity)
h = findobj(gca,'Type','patch');
set(h,'FaceColor','b','EdgeColor','w');
set(gca,'FontSize',22);
xlabel('sparseness','FontSize',28);
ylabel('number of images','FontSize',28);
