
clear all

warning off
addpath ~/mpi_kmeans/
addpath ~/colorconstancy/greyworld
addpath ~/colorconstancy/utils
warning on

imdir = 'srgb8bit'
load(['~/colorconstancy/ColorCheckerDatabase/',imdir,'_whitepoints.mat'],'L','Xfiles')
Ltrue = L;
clear L

savefile = sprintf('results/kmeans_greyworld_%s.mat',imdir);


if ~exist(savefile,'file')
    Ps = [2,12,20];
    Ns = [0,1,2];
    sig = 1;

    
    for i=1:numel(Xfiles)
	[I,mask] = read_image(Xfiles{i},imdir);

	imagesc(I.*repmat(uint8(mask==0),[1,1,3]));
	drawnow
	tic
	I = double(I);
	for pp=1:numel(Ps)
	    for nn=1:numel(Ns)
		L(pp,nn,i,:) = general_cc(I,Ns(nn),Ps(pp),sig,'mask',mask,'where','srgb');
	    end
	end
	Lsbm(i,:) = general_cc(I,0,-1,1,'mask',mask,'where','srgb');
	toc
    end
    save(savefile,'L','Lsbm','Ps','Ns','sig');
else
    load(savefile)
end

    
load features/weibull_srgb8bit.mat

% performance bound
min_err = Inf(numel(Xfiles),1);
for i=1:numel(Xfiles)
    for pp=1:numel(Ps)
	for nn=1:numel(Ns)
	    tmp_err = report_error(squeeze(L(pp,nn,i,:))',Ltrue(i,:));
	    if tmp_err < min_err(i)
		min_err(i) = tmp_err;
	    end
	end
    end
end
tmp_err = report_error(Lsbm,Ltrue);
min_err(tmp_err<min_err) = tmp_err;
fprintf('performance bound: %.4g\n',rms(min_err));


nImages = size(feat,1);

nRepetitions = 100;


for nR = 1:nRepetitions
    
    shuff = randperm(nImages);
        
    te_split{1} = shuff(0 + (1:ceil(nImages/3)));
    te_split{2} = shuff(ceil(nImages/3) + (1:ceil(nImages/3)));
    te_split{3} = shuff(2*ceil(nImages/3):nImages);

    tr_split{1} = setdiff(1:nImages,te_split{1});
    tr_split{2} = setdiff(1:nImages,te_split{2});
    tr_split{3} = setdiff(1:nImages,te_split{3});
    
    err = zeros(nImages,1);
    for fold=1:3
	min_err = Inf;
	for pp=1:numel(Ps)
	    for nn=1:numel(Ns)
		tmp_err = report_error(squeeze(L(pp,nn,tr_split{fold},:)),Ltrue(tr_split{fold},:));
		if rms(tmp_err) < min_err
		    min_err = rms(tmp_err);
		    bestP = pp;
		    bestN = nn;
		end
	    end
	end
	err(te_split{fold}) = report_error(squeeze(L(bestP,bestN,te_split{fold},:)),Ltrue(te_split{fold},:));
    end 
    
    re(nR) = rms(err);
    restd(nR) = rmsstderr(err);
    
    Ps(bestP)
    Ns(bestN)
end

fprintf('best fixed algorithm , rms = %2.0f +- %.2f\n',1000*mean(re),1000*mean(restd))




for K = [5,15]
    for nR = 1:nRepetitions
	
	
	shuff = randperm(nImages);
        
	te_split{1} = shuff(0 + (1:ceil(nImages/3)));
	te_split{2} = shuff(ceil(nImages/3) + (1:ceil(nImages/3)));
	te_split{3} = shuff(2*ceil(nImages/3):nImages);


	tr_split{1} = setdiff(1:nImages,te_split{1});
	tr_split{2} = setdiff(1:nImages,te_split{2});
	tr_split{3} = setdiff(1:nImages,te_split{3});
	
	
	for fold=1:3

	    
	    
	    if ~isinf(K)
		Cx = mpi_kmeans(feat(tr_split{fold},:)',K,0,100);
	    else
		Cx = feat(tr_split{fold},:)';
	    end
	    
	    train_indx = mpi_assign(feat(tr_split{fold},:)',Cx);
	    test_indx = mpi_assign(feat(te_split{fold},:)',Cx);

	    folderr = [];
	    for k=1:K
		
		train_ind = find(train_indx==k);
		test_ind = find(test_indx==k);
		
		if ~numel(test_ind) 
		    continue;
		end
		
		min_err = Inf;
		for pp=1:numel(Ps)
		    for nn=1:numel(Ns)
			tmp_err = report_error(squeeze(L(pp,nn,train_ind,:)),Ltrue(train_ind,:));
			tmp_err = rms(tmp_err);
			if tmp_err < min_err
			    min_err = tmp_err;
			    bestP = pp;
			    bestN = nn;
			end
		    end
		end
		

		folderr = [folderr;report_error(squeeze(L(bestP,bestN,test_ind,:)),Ltrue(test_ind,:))];
	    end

	    err(te_split{fold}) = folderr;
	end
	
	re(nR) = rms(err);
	restd(nR) = rmsstderr(err);
    end
    fprintf('K = %d, rms = %2.0f +- %.2f\n',K,1000*mean(re),1000*mean(restd))
    clear rmserr
end


