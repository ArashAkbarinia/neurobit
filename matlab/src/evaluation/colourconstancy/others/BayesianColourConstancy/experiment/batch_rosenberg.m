% File to generate the Bayesian CC results on all the images in the
% Color Checker Database with. Compute Reflectance distributions if
% not already done so.
%


clear all


imdir = 'srgb8bit';

warning off
addpath ~/colorconstancy/rosenberg/
addpath ~/colorconstancy/colorspaces
addpath ~/colorconstancy/utils
warning on

USE_CLUSTER = 1;

if USE_CLUSTER
    s = sgejob;
end

cvfile = 'threefoldCVsplit.mat';
if ~exist(cvfile,'file')
    Xfiles = dir(['~/colorconstancy/ColorCheckerDatabase/' imdir '/*.tif']);
    for i=1:numel(Xfiles)
	files{i} = Xfiles(i).name;
    end
    outdoor = load_outdoor_label(files);
    Ltrue = load_illuminants(imdir,files);

    ind = find(outdoor==1);
    ind = ind(randperm(numel(ind)));
    te_split{1} = ind(1:107);
    te_split{2} = ind(108:215);
    te_split{3} = ind(216:end);
    ind = find(outdoor==0);
    ind = ind(randperm(numel(ind)));
    te_split{1} = [te_split{1},ind(1:82)];
    te_split{2} = [te_split{2},ind(83:165)];
    te_split{3} = [te_split{3},ind(166:end)];
    
    ind = 1:numel(outdoor);
    for i=1:3
	tr_split{i} = setdiff(ind,te_split{i});
    end

    save(cvfile,'tr_split','te_split','Xfiles')
else
    load(cvfile,'te_split','tr_split','Xfiles');
    for i=1:numel(Xfiles)
	files{i} = Xfiles(i).name;

    end
    outdoor = load_outdoor_label(files);
    Ltrue = load_illuminants(imdir,files);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                 %
% Estimate all reflectance priors %
%                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:3
    
    tmp_files = files(tr_split{i});

    %
    % OUTDOOR
    %
    indx = find(outdoor(tr_split{i})==1);
    f = sprintf('empdistr/logemp_cv%d_gt_out.mat',i);
    if ~exist(f,'file')
	logemp = calc_reflectance_distr(imdir,tmp_files(indx),'proxy','gt');
	save(f,'logemp');
    end
    f = sprintf('empdistr/logemp_cv%d_sbm_out.mat',i);
    if ~exist(f,'file')
	logemp = calc_reflectance_distr(imdir,tmp_files(indx),'proxy','sbm');
	save(f,'logemp');
    end
    
    %
    % INDOOR
    %
    indx = find(outdoor(tr_split{i})==0);
    f = sprintf('empdistr/logemp_cv%d_gt_in.mat',i);
    if ~exist(f,'file')
	logemp = calc_reflectance_distr(imdir,tmp_files(indx),'proxy','gt');
	save(f,'logemp');
    end
    f = sprintf('empdistr/logemp_cv%d_sbm_in.mat',i);
    if ~exist(f,'file')
	logemp = calc_reflectance_distr(imdir,tmp_files(indx),'proxy','sbm');
	save(f,'logemp');
    end
    

    %
    % combined
    %
    f = sprintf('empdistr/logemp_cv%d_gt_combined.mat',i);
    if ~exist(f,'file')
	logemp = calc_reflectance_distr(imdir,tmp_files,'proxy','gt');
	save(f,'logemp');
    end
    

    %
    % OUTDOOR re-estimate
    %
    indx = find(outdoor(tr_split{i})==1);
    f = sprintf('empdistr/logemp_cv%d_gt_em_out.mat',i);
    if ~exist(f,'file')
	logemp = calc_reflectance_distr_em(imdir,tmp_files(indx),'proxy','gt');
	save(f,'logemp');
    end
    %  f = sprintf('empdistr/logemp_cv%d_sbm_em_out.mat',i);
    %  if ~exist(f,'file')
    %	logemp = calc_reflectance_distr_em(imdir,tmp_files(indx),'proxy','sbm');
    %	save(f,'logemp');
    %    end

    %
    % INDOOR re-estimate
    %
    indx = find(outdoor(tr_split{i})==0);
    f = sprintf('empdistr/logemp_cv%d_gt_em_in.mat',i);
    if ~exist(f,'file')
	logemp = calc_reflectance_distr_em(imdir,tmp_files(indx),'proxy','gt');
	save(f,'logemp');
    end
    %    f = sprintf('empdistr/logemp_cv%d_sbm_em_in.mat',i);
    %    if ~exist(f,'file')
    %	logemp = calc_reflectance_distr_em(imdir,tmp_files(indx),'proxy','sbm');
    %	save(f,'logemp');
    %    end

    
    lambdas = [0.001,0.01,0.1,1,2,5];
    %
    % OUTDOOR, tanh
    %
    for l=1:numel(lambdas)
	lambda = lambdas(l);
	indx = find(outdoor(tr_split{i})==1);
	f = sprintf('empdistr/logemp_cv%d_gt_lam%g_out.mat',i,lambda);
 	if ~exist(f,'file')
	    logemp = calc_reflectance_distr(imdir,tmp_files(indx),'proxy','gt','lambda',lambda);
	    save(f,'logemp');
	end
    end

    %
    % INDOOR, tanh
    %
    for l=1:numel(lambdas)
	lambda = lambdas(l);
	indx = find(outdoor(tr_split{i})==0);
	f = sprintf('empdistr/logemp_cv%d_gt_lam%g_in.mat',i,lambda);
	if ~exist(f,'file')
	    logemp = calc_reflectance_distr(imdir,tmp_files(indx),'proxy','gt','lambda',lambda);
	    save(f,'logemp');
	end
    end
end



%%%%%%%%%%%%%%%%%%%
%                 %
% COMBINED IMAGES %
%                 %
%%%%%%%%%%%%%%%%%%%
resultfile = ['results/combined_',imdir,'.mat'];
if ~exist(resultfile,'file')

    for fold=1:3
	
	fname = sprintf('empdistr/logemp_cv%d_gt_combined.mat',fold);
	load(fname,'logemp');
	
	prior = Ltrue(tr_split{fold},:);
	
	te_ind = te_split{fold};
	for i=1:numel(te_ind)
	    tic
	    [I,mask] = read_image(Xfiles(te_ind(i)).name,imdir);
	    if USE_CLUSTER
		jobs(te_ind(i)) = qsub(s,'rosenberg',I,mask,logemp,'prior',prior);
	    else
		L(te_ind(i),:) = rosenberg(I,mask,logemp,'prior',prior);
	    
	    end
 	    toc
	end
    end
    
    if USE_CLUSTER
	while(~all(finished(jobs)))
	    pause(10);
	end
	for i=1:numel(jobs)
	    L(i,:) = collect(jobs(i));
	end
    end
    
    save(resultfile,'L')
end
clear L jobs


%%%%%%%%%%%%%%%%%%
%                %
% OUTDOOR IMAGES %
%                %
%%%%%%%%%%%%%%%%%%
resultfile = ['results/outdoor_',imdir,'.mat'];
if ~exist(resultfile,'file')

    for fold=1:3
	
	fname = sprintf('empdistr/logemp_cv%d_gt_out.mat',fold);
	load(fname,'logemp');
	
	
	te_ind = te_split{fold};
	te_ind = te_ind(find(outdoor(te_ind)==1));

	tr_ind = tr_split{fold};
	tr_ind = tr_ind(find(outdoor(tr_ind)==1));
	
	prior = Ltrue(tr_ind,:);
	
	for i=1:numel(te_ind)
	    tic
	    [I,mask] = read_image(Xfiles(te_ind(i)).name,imdir);
	    imagesc(I);title('outdoor');
	    drawnow
	    
	    if USE_CLUSTER
		jobs(te_ind(i)) = qsub(s,'rosenberg',I,mask,logemp,'prior',prior);
	    else
		L(te_ind(i),:) = rosenberg(I,mask,logemp,'prior',prior);
	    
	    end
 	    toc
	end
    end

    te_ind = find(outdoor==1);

    if USE_CLUSTER
	while(~all(finished(jobs(te_ind))))
	    pause(10);
	end
	for i=1:numel(te_ind)
	    L(te_ind(i),:) = collect(jobs(te_ind(i)));
	end
	clean(jobs);
    end
    
    save(resultfile,'L')
end
clear L jobs

%%%%%%%%%%%%%%%%%%
%                %
% INDOOR IMAGES  %
%                %
%%%%%%%%%%%%%%%%%%
resultfile = ['results/indoor_',imdir,'.mat'];
if ~exist(resultfile,'file')

    for fold=1:3
	
	fname = sprintf('empdistr/logemp_cv%d_gt_in.mat',fold);
	load(fname,'logemp');
	
	
	te_ind = te_split{fold};
	te_ind = te_ind(find(outdoor(te_ind)==0));

	tr_ind = tr_split{fold};
	tr_ind = tr_ind(find(outdoor(tr_ind)==0));
	
	prior = Ltrue(tr_ind,:);
	
	for i=1:numel(te_ind)
	    tic
	    [I,mask] = read_image(Xfiles(te_ind(i)).name,imdir);
	    imagesc(I);title('indoor');
	    drawnow
	    
	    if USE_CLUSTER
		jobs(te_ind(i)) = qsub(s,'rosenberg',I,mask,logemp,'prior',prior);
	    else
		L(te_ind(i),:) = rosenberg(I,mask,logemp,'prior',prior);
	    
	    end
 	    toc
	end
    end
    
    te_ind = find(outdoor==0);
    
    if USE_CLUSTER
	while(~all(finished(jobs(te_ind))))
	    pause(10);
	end
	for i=1:numel(te_ind)
	    L(te_ind(i),:) = collect(jobs(te_ind(i)));
	end
	clean(jobs);
    end
    
    save(resultfile,'L')
end
clear L jobs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             %
% OUTDOOR IMAGES Scale-by-Max %
%                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
resultfile = ['results/outdoor_sbm_',imdir,'.mat'];
if ~exist(resultfile,'file')

    for fold=1:3
	
	fname = sprintf('empdistr/logemp_cv%d_sbm_out.mat',fold);
	load(fname,'logemp');
	
	
	te_ind = te_split{fold};
	te_ind = te_ind(find(outdoor(te_ind)==1));

	tr_ind = tr_split{fold};
	tr_ind = tr_ind(find(outdoor(tr_ind)==1));
	
	prior = Ltrue(tr_ind,:);
	
	for i=1:numel(te_ind)
	    tic
	    [I,mask] = read_image(Xfiles(te_ind(i)).name,imdir);
	    imagesc(I);	    title('outdoor');
	    drawnow
	    if USE_CLUSTER
		jobs(te_ind(i)) = qsub(s,'rosenberg',I,mask,logemp,'prior',prior);
	    else
		L(te_ind(i),:) = rosenberg(I,mask,logemp,'prior',prior);
		
	    end
 	    toc
	end
    end
    
    te_ind = find(outdoor==1);
    
    if USE_CLUSTER
	while(~all(finished(jobs(te_ind))))
	    pause(10);
	end
	for i=1:numel(te_ind)
	    L(te_ind(i),:) = collect(jobs(te_ind(i)));
	end
	clean(jobs);
    end
    
    save(resultfile,'L')
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            %
% INDOOR IMAGES Scale-by-Max %
%                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
resultfile = ['results/indoor_sbm_',imdir,'.mat'];
if ~exist(resultfile,'file')

    for fold=1:3
	
	fname = sprintf('empdistr/logemp_cv%d_sbm_in.mat',fold);
	load(fname,'logemp');
	
	
	te_ind = te_split{fold};
	te_ind = te_ind(find(outdoor(te_ind)==0));

	tr_ind = tr_split{fold};
	tr_ind = tr_ind(find(outdoor(tr_ind)==0));
	
	prior = Ltrue(tr_ind,:);
	
	for i=1:numel(te_ind)
	    tic
	    [I,mask] = read_image(Xfiles(te_ind(i)).name,imdir);
	    imagesc(I);title('indoor');
	    drawnow
	    
	    if USE_CLUSTER
		jobs(te_ind(i)) = qsub(s,'rosenberg',I,mask,logemp,'prior',prior);
	    else
		L(te_ind(i),:) = rosenberg(I,mask,logemp,'prior',prior);
	    
	    end
 	    toc
	end
    end
    
    te_ind = find(outdoor==0);
    
    if USE_CLUSTER
	while(~all(finished(jobs(te_ind))))
	    pause(10);
	end
	for i=1:numel(te_ind)
	    L(te_ind(i),:) = collect(jobs(te_ind(i)));
	end
	clean(jobs);
    end
    
    save(resultfile,'L')
end



%%%%%%%%%%%%%%%%%%%%%%%
%                     %
% OUTDOOR IMAGES TANH %
%                     %
%%%%%%%%%%%%%%%%%%%%%%&
lambdas = [0.001,0.01,0.1,1,2,5];
for t=1:numel(lambdas)
    lambda = lambdas(t);
    resultfile = ['results/outdoor_',imdir,'_tanh',num2str(lambda),'.mat'];
    if ~exist(resultfile,'file')

	for fold=1:3
	    
	    fname = sprintf('empdistr/logemp_cv%d_gt_out.mat',fold);
	    load(fname,'logemp');
	    
	    
	    te_ind = te_split{fold};
	    te_ind = te_ind(find(outdoor(te_ind)==1));

	    tr_ind = tr_split{fold};
	    tr_ind = tr_ind(find(outdoor(tr_ind)==1));
	    
	    prior = Ltrue(tr_ind,:);
	    
	    for i=1:numel(te_ind)
		tic
		[I,mask] = read_image(Xfiles(te_ind(i)).name,imdir);
		imagesc(I);	    title('outdoor');
		drawnow
		if USE_CLUSTER
		    jobs(te_ind(i)) = qsub(s,'rosenberg',I,mask,logemp,'prior',prior,'lambda',lambda);
		else
		    L(te_ind(i),:) = rosenberg(I,mask,logemp,'prior',prior,'lambda',lambda);
		    
		end
		toc
	    end
	end
	
	te_ind = find(outdoor==1);
	
	if USE_CLUSTER
	    while(~all(finished(jobs(te_ind))))
		pause(10);
	    end
	    for i=1:numel(te_ind)
		L(te_ind(i),:) = collect(jobs(te_ind(i)));
	    end
	    clean(jobs);
	end
	
	save(resultfile,'L')
    end
end



%%%%%%%%%%%%%%%%%%%%%%
%                    %
% INDOOR IMAGES TANH %
%                    %
%%%%%%%%%%%%%%%%%%%%%&
lambdas = [0.001,0.01,0.1,1,2,5];
for t=1:numel(lambdas)
    lambda = lambdas(t);
    resultfile = ['results/indoor_',imdir,'_tanh',num2str(lambda),'.mat'];
    if ~exist(resultfile,'file')

	for fold=1:3
	    
	    fname = sprintf('empdistr/logemp_cv%d_gt_in.mat',fold);
	    load(fname,'logemp');
	    
	    
	    te_ind = te_split{fold};
	    te_ind = te_ind(find(outdoor(te_ind)==0));

	    tr_ind = tr_split{fold};
	    tr_ind = tr_ind(find(outdoor(tr_ind)==0));
	    
	    prior = Ltrue(tr_ind,:);
	    
	    for i=1:numel(te_ind)
		tic
		[I,mask] = read_image(Xfiles(te_ind(i)).name,imdir);
		imagesc(I);	    title('indoor');
		drawnow
		if USE_CLUSTER
		    jobs(te_ind(i)) = qsub(s,'rosenberg',I,mask,logemp,'prior',prior,'lambda',lambda);
		else
		    L(te_ind(i),:) = rosenberg(I,mask,logemp,'prior',prior,'lambda',lambda);
		    
		end
		toc
	    end
	end
	
	te_ind = find(outdoor==0);
	
	if USE_CLUSTER
	    while(~all(finished(jobs(te_ind))))
		pause(10);
	    end
	    for i=1:numel(te_ind)
		L(te_ind(i),:) = collect(jobs(te_ind(i)));
	    end
	    clean(jobs);
	end
	
	save(resultfile,'L')
    end
end



%%%%%%%%%%%%%%%%%%%%%%%
%                     %
% OUTDOOR IMAGES TANH %
%   LOGEMP with TANH  %
%%%%%%%%%%%%%%%%%%%%%%&
lambdas = [0.001,0.01,0.1,1,2,5];
for t=1:numel(lambdas)
    lambda = lambdas(t);
    resultfile = ['results/outdoor_softclipped_',imdir,'_tanh',num2str(lambda),'.mat'];
    if ~exist(resultfile,'file')

	for fold=1:3
	    
	    fname = sprintf('empdistr/logemp_cv%d_gt_lam%g_out.mat',fold,lambda);
	    load(fname,'logemp');
	    
	    
	    te_ind = te_split{fold};
	    te_ind = te_ind(find(outdoor(te_ind)==1));

	    tr_ind = tr_split{fold};
	    tr_ind = tr_ind(find(outdoor(tr_ind)==1));
	    
	    prior = Ltrue(tr_ind,:);
	    
	    for i=1:numel(te_ind)
		tic
		[I,mask] = read_image(Xfiles(te_ind(i)).name,imdir);
		imagesc(I);	    title('outdoor');
		drawnow
		if USE_CLUSTER
		    jobs(te_ind(i)) = qsub(s,'rosenberg',I,mask,logemp,'prior',prior,'lambda',lambda);
		else
		    L(te_ind(i),:) = rosenberg(I,mask,logemp,'prior',prior,'lambda',lambda);
		    
		end
		toc
	    end
	end
	
	te_ind = find(outdoor==1);
	
	if USE_CLUSTER
	    while(~all(finished(jobs(te_ind))))
		pause(10);
	    end
	    for i=1:numel(te_ind)
		L(te_ind(i),:) = collect(jobs(te_ind(i)));
	    end
	    clean(jobs);
	end
	
	save(resultfile,'L')
    end
end



%%%%%%%%%%%%%%%%%%%%%%
%                    %
% INDOOR IMAGES TANH %
%   LOGEMP with TANH  %
%%%%%%%%%%%%%%%%%%%%%&
lambdas = [0.001,0.01,0.1,1,2,5];
lambdas = [2,5];
for t=1:numel(lambdas)
    lambda = lambdas(t);
    resultfile = ['results/indoor_softclipped_',imdir,'_tanh',num2str(lambda),'.mat'];
    if ~exist(resultfile,'file')

	for fold=1:3
	    
	    fname = sprintf('empdistr/logemp_cv%d_gt_lam%g_in.mat',fold,lambda);
	    load(fname,'logemp');
	    
	    
	    te_ind = te_split{fold};
	    te_ind = te_ind(find(outdoor(te_ind)==0));

	    tr_ind = tr_split{fold};
	    tr_ind = tr_ind(find(outdoor(tr_ind)==0));
	    
	    prior = Ltrue(tr_ind,:);
	    
	    for i=1:numel(te_ind)
		tic
		[I,mask] = read_image(Xfiles(te_ind(i)).name,imdir);
		imagesc(I);	    title('indoor');
		drawnow
		if USE_CLUSTER
		    jobs(te_ind(i)) = qsub(s,'rosenberg',I,mask,logemp,'prior',prior,'lambda',lambda);
		else
		    L(te_ind(i),:) = rosenberg(I,mask,logemp,'prior',prior,'lambda',lambda);
		    
		end
		toc
	    end
	end
	
	te_ind = find(outdoor==0);
	
	if USE_CLUSTER
	    while(~all(finished(jobs(te_ind))))
		pause(10);
	    end
	    for i=1:numel(te_ind)
		L(te_ind(i),:) = collect(jobs(te_ind(i)));
	    end
	    clean(jobs);
	end
	
	save(resultfile,'L')
    end
end



%%%%%%%%%%%%%%%%%%
%                %
% OUTDOOR IMAGES %
%    re-est      %
%%%%%%%%%%%%%%%%%%
resultfile = ['results/outdoor_em_',imdir,'.mat'];
if ~exist(resultfile,'file')

    for fold=1:3
	
	fname = sprintf('empdistr/logemp_cv%d_gt_em_out.mat',fold);
	load(fname,'logemp');
	
	
	te_ind = te_split{fold};
	te_ind = te_ind(find(outdoor(te_ind)==1));

	tr_ind = tr_split{fold};
	tr_ind = tr_ind(find(outdoor(tr_ind)==1));
	
	prior = Ltrue(tr_ind,:);
	
	for i=1:numel(te_ind)
	    tic
	    [I,mask] = read_image(Xfiles(te_ind(i)).name,imdir);
	    imagesc(I);title('outdoor');
	    drawnow
	    
	    if USE_CLUSTER
		jobs(te_ind(i)) = qsub(s,'rosenberg',I,mask,logemp,'prior',prior);
	    else
		L(te_ind(i),:) = rosenberg(I,mask,logemp,'prior',prior);
	    
	    end
 	    toc
	end
    end

    te_ind = find(outdoor==1);

    if USE_CLUSTER
	while(~all(finished(jobs(te_ind))))
	    pause(10);
	end
	for i=1:numel(te_ind)
	    L(te_ind(i),:) = collect(jobs(te_ind(i)));
	end
	clean(jobs);
    end
    
    save(resultfile,'L')
end
clear L jobs

%%%%%%%%%%%%%%%%%%
%                %
% INDOOR IMAGES  %
%                %
%%%%%%%%%%%%%%%%%%
resultfile = ['results/indoor_em_',imdir,'.mat'];
if ~exist(resultfile,'file')

    for fold=1:3
	
	fname = sprintf('empdistr/logemp_cv%d_gt_em_in.mat',fold);
	load(fname,'logemp');
	
	
	te_ind = te_split{fold};
	te_ind = te_ind(find(outdoor(te_ind)==0));

	tr_ind = tr_split{fold};
	tr_ind = tr_ind(find(outdoor(tr_ind)==0));
	
	prior = Ltrue(tr_ind,:);
	
	for i=1:numel(te_ind)
	    tic
	    [I,mask] = read_image(Xfiles(te_ind(i)).name,imdir);
	    imagesc(I);title('indoor');
	    drawnow
	    
	    if USE_CLUSTER
		jobs(te_ind(i)) = qsub(s,'rosenberg',I,mask,logemp,'prior',prior);
	    else
		L(te_ind(i),:) = rosenberg(I,mask,logemp,'prior',prior);
	    
	    end
 	    toc
	end
    end
    
    te_ind = find(outdoor==0);
    
    if USE_CLUSTER
	while(~all(finished(jobs(te_ind))))
	    pause(10);
	end
	for i=1:numel(te_ind)
	    L(te_ind(i),:) = collect(jobs(te_ind(i)));
	end
	clean(jobs);
    end
    
    save(resultfile,'L')
end
clear L jobs
