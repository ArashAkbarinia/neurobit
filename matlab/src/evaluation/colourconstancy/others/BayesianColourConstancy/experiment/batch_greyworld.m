% Computes all results for the Greyworld algorithms on the
% ColorChecker Database.
%

clear all

imdir = 'srgb8bit';

load(['~/colorconstancy/ColorCheckerDatabase/srgb8bit_whitepoints.mat'],'L','Xfiles')
Ltrue = L;
clear L

% set to 0 if you do not have a cluster :)
USE_CLUSTER = 1;

if USE_CLUSTER
    s= sgejob;
    s.nargout = 2;
    s.timereq = 2;
end

warning off
addpath ~/colorconstancy/greyworld/
addpath ~/colorconstancy/utils
addpath ~/colorconstancy/colorspaces
warning on


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             %
%      STANDARD GW            %
%                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

savefile = sprintf('results/batch_greyworld_%s.mat',imdir);
if ~exist(savefile,'file')
    Ps = [1,5,20];
    Ns = [0,1,2];
    sig = 1;


    for i=1:numel(Xfiles)
	[I,mask] = read_image(Xfiles{i},imdir);

	imagesc(I.*repmat(uint8(mask==0),[1,1,3]));

	I = double(I);
	Ilin = srgb2rgb(double(I));

	tic
	for pp=1:numel(Ps)
	    for nn=1:numel(Ns)
		L(pp,nn,i,:) = general_cc(I,Ns(nn),Ps(pp),sig,'mask',mask,'where','srgb');
		Llin(pp,nn,i,:) = general_cc(Ilin,Ns(nn),Ps(pp),sig,'mask',mask,'where','srgb');
	    end
	end
	toc
	
    end

    save(savefile,'L','Llin','Xfiles','Ps','Ns','sig');
end
clear L Llin



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             %
%       PRIORs for GW         %
%         OUTDOOR             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

outdoor = load_outdoor_label(Xfiles);
cvfile = 'threefoldCVsplit.mat';
load(cvfile,'te_split','tr_split','Xfiles');
for fold=1:3
    
    tr_ind = tr_split{fold};
    tr_ind = tr_ind(find(outdoor(tr_ind)==1));

    rg = Ltrue(tr_ind,:);
%    rg(:,3) = 1-sum(rg,2);

    [ignore,g] = train(gauss,data(rg));
    mu = g.mean;
    Cov = g.cov;
    
    savefile = sprintf('gwprior_outdoor_fold%d_cc_2d.mat',fold);
    save(savefile,'mu','Cov');

    rg(:,3) = 1-sum(rg,2);
    [ignore,g] = train(gauss,data(rg));
    mu = g.mean;
    Cov = g.cov + 1e-5*eye(3);
    
    savefile = sprintf('gwprior_outdoor_fold%d_cc_3d.mat',fold);
    save(savefile,'mu','Cov');
    
    
    tr_ind = tr_split{fold};
    tr_ind = tr_ind(find(outdoor(tr_ind)==0));

    rg = Ltrue(tr_ind,:);
    rg(:,3) = 1-sum(rg,2);

    [ignore,g] = train(gauss,data(rg));
    mu = g.mean;
    Cov = g.cov;
    
    savefile = sprintf('gwprior_indoor_fold%d_cc_2d.mat',fold);
    save(savefile,'mu','Cov');
    
    rg(:,3) = 1-sum(rg,2);
    [ignore,g] = train(gauss,data(rg));
    mu = g.mean;
    Cov = g.cov + 1e-5*eye(3);
    
    savefile = sprintf('gwprior_indoor_fold%d_cc_3d.mat',fold);
    save(savefile,'mu','Cov');

    
end
clear L Llin


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             %
%       GW + PRIOR            %
%         OUTDOOR             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

etas = [0.0001,0.001,0.01,0.1];
Ps = [1,5,20];
Ns = [0,1,2];
sig = 1;

savefile = sprintf('results/greyworld_outdoor_2d_%s.mat',imdir);
if ~exist(savefile,'file')
    for i=1:numel(Xfiles)

	if (outdoor(i) == 0)
	    continue;
	end
	
	
	% find the split this image is in
	priorfile = [];clear mu Cov;
	for fold=1:3
	    if sum(te_split{fold}==i)>0
		priorfile = sprintf('gwprior_outdoor_fold%d_cc_2d.mat',fold);
	    end
	end
	% ... and load the prior ...
	assert(numel(priorfile)>0);
	load(priorfile,'mu','Cov');
	
	[I,mask] = read_image(Xfiles(i).name,imdir);

	imagesc(I.*repmat(uint8(mask==0),[1,1,3]));

	I = double(I);
	%Ilin = srgb2rgb(double(I));

	if USE_CLUSTER
	    job(i) = qsub(s,'compute_greyworld',I,Ns,Ps,etas,sig,mask,Cov,mu);
	else
	    [L{i},Llin{i}] = compute_greyworld(I,Ns,Ps,etas,sig,mask,Cov,mu);
	end

    end
    
    if USE_CLUSTER
	while ~all(finished(job(find(outdoor==1))))
	    pause(20);
	end
	indx = find(outdoor==1);
	for i=1:numel(indx)
	    [L{indx(i)},Llin{indx(i)}] = collect(job(indx(i)));
	end
	
	clean(job(indx));
    end

    
    save(savefile,'L','Llin','Xfiles','Ps','Ns','sig','etas');
end
clear L Llin job


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             %
%       GW + PRIOR            %
%         INDOOR              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

etas = [0.0001,0.001,0.01,0.1];
Ps = [1,5,20];
Ns = [0,1,2];
sig = 1;

savefile = sprintf('results/greyworld_indoor_2d_%s.mat',imdir);
if ~exist(savefile,'file')
    for i=1:numel(Xfiles)
	
	if (outdoor(i) == 1)
	    continue;
	end
	
	% find the split this image is in
	priorfile = [];clear mu Cov;
	for fold=1:3
	    if sum(te_split{fold}==i)>0
		priorfile = sprintf('gwprior_indoor_fold%d_cc_2d.mat',fold);
	    end
	end
	% ... and load the prior ...
	assert(numel(priorfile)>0);
	load(priorfile,'mu','Cov');
	
	[I,mask] = read_image(Xfiles(i).name,imdir);

	imagesc(I.*repmat(uint8(mask==0),[1,1,3]));

	I = double(I);

	if USE_CLUSTER
	    job(i) = qsub(s,'compute_greyworld',I,Ns,Ps,etas,sig,mask,Cov,mu);
	else
	    [L{i},Llin{i}] = compute_greyworld(I,Ns,Ps,etas,sig,mask,Cov,mu);
	end
	i
    end
    
    if USE_CLUSTER
	while ~all(finished(job(find(outdoor==0))))
	    pause(20);
	end
	indx = find(outdoor==0);
	for i=1:numel(indx)
	    [L{indx(i)},Llin{indx(i)}] = collect(job(indx(i)));
	end
	
	clean(job(indx));

    end
    
    save(savefile,'L','Llin','Xfiles','Ps','Ns','sig','etas');
end
clear L Llin





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             %
%       GW + PRIOR 3D         %
%         OUTDOOR             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

etas = [0.0001,0.001,0.01,0.1];
Ps = [1,5,20];
Ns = [0,1,2];
sig = 1;

savefile = sprintf('results/greyworld_outdoor_3d_%s.mat',imdir);
if ~exist(savefile,'file')
    for i=1:numel(Xfiles)

	if (outdoor(i) == 0)
	    continue;
	end
	
	
	% find the split this image is in
	priorfile = [];clear mu Cov;
	for fold=1:3
	    if sum(te_split{fold}==i)>0
		priorfile = sprintf('gwprior_outdoor_fold%d_cc_3d.mat',fold);
	    end
	end
	% ... and load the prior ...
	assert(numel(priorfile)>0);
	load(priorfile,'mu','Cov');
	
	[I,mask] = read_image(Xfiles(i).name,imdir);

	imagesc(I.*repmat(uint8(mask==0),[1,1,3]));

	I = double(I);
	%Ilin = srgb2rgb(double(I));

	if USE_CLUSTER
	    job(i) = qsub(s,'compute_greyworld',I,Ns,Ps,etas,sig,mask,Cov,mu);
	else
	    [L{i},Llin{i}] = compute_greyworld(I,Ns,Ps,etas,sig,mask,Cov,mu);
	end

    end
    
    if USE_CLUSTER
	while ~all(finished(job(find(outdoor==1))))
	    pause(20);
	end
	indx = find(outdoor==1);
	for i=1:numel(indx)
	    [L{indx(i)},Llin{indx(i)}] = collect(job(indx(i)));
	end
	
	clean(job(indx));
    end

    
    save(savefile,'L','Llin','Xfiles','Ps','Ns','sig','etas');
end
clear L Llin job


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             %
%       GW + PRIOR 3D         %
%         INDOOR              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

etas = [0.0001,0.001,0.01,0.1];
Ps = [1,5,20];
Ns = [0,1,2];
sig = 1;

savefile = sprintf('results/greyworld_indoor_3d_%s.mat',imdir);
if ~exist(savefile,'file')
    for i=1:numel(Xfiles)
	
	if (outdoor(i) == 1)
	    continue;
	end
	
	% find the split this image is in
	priorfile = [];clear mu Cov;
	for fold=1:3
	    if sum(te_split{fold}==i)>0
		priorfile = sprintf('gwprior_indoor_fold%d_cc_3d.mat',fold);
	    end
	end
	% ... and load the prior ...
	assert(numel(priorfile)>0);
	load(priorfile,'mu','Cov');
	
	[I,mask] = read_image(Xfiles(i).name,imdir);

	imagesc(I.*repmat(uint8(mask==0),[1,1,3]));

	I = double(I);

	if USE_CLUSTER
	    job(i) = qsub(s,'compute_greyworld',I,Ns,Ps,etas,sig,mask,Cov,mu);
	else
	    [L{i},Llin{i}] = compute_greyworld(I,Ns,Ps,etas,sig,mask,Cov,mu);
	end
	i
    end
    
    if USE_CLUSTER
	while ~all(finished(job(find(outdoor==0))))
	    pause(20);
	end
	indx = find(outdoor==0);
	for i=1:numel(indx)
	    [L{indx(i)},Llin{indx(i)}] = collect(job(indx(i)));
	end
	
	clean(job(indx));

    end
    
    save(savefile,'L','Llin','Xfiles','Ps','Ns','sig','etas');
end
clear L Llin

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             %
%       PRIORs for GW         %
%       2D OUTDOOR SFU        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outd = outdoor;
load('sfu_prior.mat','rg','outdoor');
sfu_outdoor = outdoor; 
outdoor = outd; clear outd;


[ignore,g] = train(gauss,data(rg(sfu_outdoor==1,:)));
mu_out = g.mean;
Cov_out = g.cov;

[ignore,g] = train(gauss,data(rg(sfu_outdoor==0,:)));
mu_in = g.mean;
Cov_in = g.cov;





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             %
%       GW + PRIOR            %
%         OUTDOOR             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

etas = [0.0001,0.001,0.01,0.1];
Ps = [1,5,20];
Ns = [0,1,2];
sig = 1;

savefile = sprintf('results/greyworld_outdoor_2d_sfu_%s.mat',imdir);
if ~exist(savefile,'file')
    mu = mu_out;
    Cov = Cov_out;
    for i=1:numel(Xfiles)

	if (outdoor(i) == 0)
	    continue;
	end
	
	[I,mask] = read_image(Xfiles(i).name,imdir);

	imagesc(I.*repmat(uint8(mask==0),[1,1,3]));

	I = double(I);

	if USE_CLUSTER
	    job(i) = qsub(s,'compute_greyworld',I,Ns,Ps,etas,sig,mask,Cov,mu);
	else
	    [L{i},Llin{i}] = compute_greyworld(I,Ns,Ps,etas,sig,mask,Cov,mu);
	end

    end
    
    if USE_CLUSTER
	while ~all(finished(job(find(outdoor==1))))
	    pause(20);
	end
	indx = find(outdoor==1);
	for i=1:numel(indx)
	    [L{indx(i)},Llin{indx(i)}] = collect(job(indx(i)));
	end
	
	clean(job(indx));
    end

    
    save(savefile,'L','Llin','Xfiles','Ps','Ns','sig','etas');
end
clear L Llin job


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             %
%       GW + PRIOR            %
%         INDOOR              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

etas = [0.0001,0.001,0.01,0.1];
Ps = [1,5,20];
Ns = [0,1,2];
sig = 1;

savefile = sprintf('results/greyworld_indoor_2d_sfu_%s.mat',imdir);
if ~exist(savefile,'file')

    mu = mu_in;
    Cov = Cov_in;

    for i=1:numel(Xfiles)
	
	if (outdoor(i) == 1)
	    continue;
	end
	
	[I,mask] = read_image(Xfiles(i).name,imdir);

	imagesc(I.*repmat(uint8(mask==0),[1,1,3]));

	I = double(I);

	if USE_CLUSTER
	    job(i) = qsub(s,'compute_greyworld',I,Ns,Ps,etas,sig,mask,Cov,mu);
	else
	    [L{i},Llin{i}] = compute_greyworld(I,Ns,Ps,etas,sig,mask,Cov,mu);
	end
	i
    end
    
    if USE_CLUSTER
	while ~all(finished(job(find(outdoor==0))))
	    pause(20);
	end
	indx = find(outdoor==0);
	for i=1:numel(indx)
	    [L{indx(i)},Llin{indx(i)}] = collect(job(indx(i)));
	end
	
	clean(job(indx));

    end
    
    save(savefile,'L','Llin','Xfiles','Ps','Ns','sig','etas');
end
clear L Llin

