

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

savefile = sprintf('results/kmeans2_greyworld_%s.mat',imdir);

if ~exist(savefile,'file')
    
    Ps = [1,-1,13,1,1];
    Ns = [0,0,0,1,2];
    sigs = [0,0,2,6,5];
    
    for i=1:numel(Xfiles)
	[I,mask] = read_image(Xfiles{i},imdir);

	imagesc(I.*repmat(uint8(mask==0),[1,1,3]));
	drawnow
	tic
	I = double(I);
	for pp=1:numel(Ps)
	    L(pp,i,:) = general_cc(I,Ns(pp),Ps(pp),sigs(pp),'mask',mask,'where','srgb');
	end
	toc
    end
    save(savefile,'L','Ps','Ns','sigs');
else
    load(savefile)
end

    
load features/weibull_srgb8bit.mat

% performance bound
min_err = Inf(numel(Xfiles),1);
for i=1:numel(Xfiles)
    for pp=1:numel(Ps)
	tmp_err = report_error(squeeze(L(pp,i,:))',Ltrue(i,:));
	if tmp_err < min_err(i)
	    min_err(i) = tmp_err;
	end
    end
end
min_err(tmp_err<min_err) = tmp_err;
fprintf('performance bound: %.4g +- %.04g\n',1000*rms(min_err),1000*mean(rmsstderr(min_err)));


nImages = size(feat,1);

nRepetitions = 100;

if (0)
    % best alg overall
min_err = Inf;
for pp=1:numel(Ps)
    tmp_err = report_error(squeeze(L(pp,:,:)),Ltrue);
    ttt(pp) = rms(tmp_err);
    if rms(tmp_err) < min_err
	min_err = rms(tmp_err);
	bestP = pp;
    end
end
err = report_error(squeeze(L(bestP,:,:)),Ltrue);
bestP
fprintf('best fixed algorithm , rms = %2.0f +- %.2f\n',1000*mean(rms(err)),1000*mean(rmsstderr(err)))
end

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
	    tmp_err = report_error(squeeze(L(pp,tr_split{fold},:)),Ltrue(tr_split{fold},:));
	    if rms(tmp_err) < min_err
		min_err = rms(tmp_err);
		bestP = pp;
	    end
	end
	err(te_split{fold}) = report_error(squeeze(L(bestP,te_split{fold},:)),Ltrue(te_split{fold},:));
    end 
    
    re(nR) = rms(err);
    restd(nR) = rmsstderr(err);
    
    Ps(bestP);
end
fprintf('best fixed algorithm , rms = %2.0f +- %.2f\n',1000*mean(re),1000*mean(restd))


for K = [5,15,Inf]
    for nR = 1:nRepetitions
	
	
	shuff = randperm(nImages);
        
	te_split{1} = shuff(0 + (1:ceil(nImages/3)));
	te_split{2} = shuff(ceil(nImages/3) + (1:ceil(nImages/3)));
	te_split{3} = shuff(2*ceil(nImages/3):nImages);


	tr_split{1} = setdiff(1:nImages,te_split{1});
	tr_split{2} = setdiff(1:nImages,te_split{2});
	tr_split{3} = setdiff(1:nImages,te_split{3});
	
	
	for fold=1:3

	    % compute clustering 
	    if ~isinf(K)
		Cx = mpi_kmeans(feat(tr_split{fold},:)',K,0,100);
	    else
		Cx = feat(tr_split{fold},:)';
	    end
	    indx = mpi_assign(feat',Cx);

	    folderr = [];
	    for k=1:max(indx)
		
		ind = find(indx==k);
		if ~numel(ind), continue; end
		
		test_ind = intersect(te_split{fold},ind);
		train_ind = intersect(tr_split{fold},ind);
		
		% there is no test image in this class
		if ~numel(test_ind) 
		    continue;
		end

		
		min_err = Inf;
		for pp=1:numel(Ps)
		    tmp_err = report_error(squeeze(L(pp,train_ind,:)),Ltrue(train_ind,:));
		    tmp_err = rms(tmp_err);
		    if tmp_err < min_err
			min_err = tmp_err;
			bestP = pp;
		    end
		end
		
		folderr = [folderr;report_error(squeeze(L(bestP,test_ind,:)),Ltrue(test_ind,:))];
	    end

	    err(te_split{fold}) = folderr;
	end
	re(nR) = rms(err);
	restd(nR) = rmsstderr(err);
    end
    fprintf('K = %d, rms = %2.0f +- %.2f\n',K,1000*mean(re),1000*mean(restd))
    clear rmserr err re restd
end


