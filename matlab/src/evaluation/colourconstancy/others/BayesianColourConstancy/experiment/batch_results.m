clear all

imdir = 'srgb8bit';
scale = 1;

cvfile = 'threefoldCVsplit.mat';
load(cvfile,'te_split','tr_split','Xfiles');
for i=1:numel(Xfiles)
    files{i} = Xfiles(i).name;

end
outdoor = load_outdoor_label(files);
Ltrue = load_illuminants(imdir,files);

outside = 0;

if outside == 1
    str = 'outdoor';
else
    str = 'indoor';
end

fprintf([upper(str),'\n']);


ind = find(outdoor==outside);

%
% CANON AUTOWB
% 
err = report_error(Ltrue(ind,:),ones(numel(ind),2)/3);
rms_err(1,1) = rms(err);
rms_errstd(1,1) = rmsstderr(err);
descr{1} = 'Canon AutoWB';
print_error(descr{1},err);


%
% MEAN PREDICTION 
%
err = zeros(max(ind),1);
for fold=1:3
    tmp_ind = tr_split{fold};
    tmp_ind = tmp_ind(find(outdoor(tmp_ind)==outside));
    Lpred = mean(Ltrue(tmp_ind,:));
    
    tmp_ind = te_split{fold};
    tmp_ind = tmp_ind(find(outdoor(tmp_ind)==outside));
    
    err(tmp_ind) = report_error(repmat(Lpred,numel(tmp_ind),1),Ltrue(tmp_ind,:));
end
err = sort(err(ind),'ascend');
rms_err(end+1,1) = rms(err);
rms_errstd(end+1,1) = rmsstderr(err);
descr{end+1} = sprintf('Mean Prediction');

print_error(descr{end},err);



%
% GreyWorld
%
err = zeros(max(ind),1);
load(['results/batch_greyworld_',imdir,'.mat'],'L','Ps','Ns');
for fold=1:3
    tmp_ind = tr_split{fold};
    tmp_ind = tmp_ind(find(outdoor(tmp_ind)==outside));

    for p=1:numel(Ps)
	for n=1:numel(Ns)
	    tmp_err = report_error(squeeze(L(p,n,tmp_ind,:)),Ltrue(tmp_ind,:));
	    tmp_rmserr(p,n) = rms(tmp_err);
	end
    end
    tmp_rmserr = tmp_rmserr + 1e-9*randn(size(tmp_rmserr));
    D = (tmp_rmserr == min(tmp_rmserr(:)));

    [bestN,bestP] = ind2sub(size(D),find(D));
    
    tmp_ind = te_split{fold};
    tmp_ind = tmp_ind(find(outdoor(tmp_ind)==outside));

    err(tmp_ind) = report_error(squeeze(L(bestP,bestN,tmp_ind,:)),Ltrue(tmp_ind,:));

    chosenP(fold) = Ps(bestP);
    chosenN(fold) = Ns(bestN);
end
err = err(ind);
assert(all(err~=0));
fprintf('GREYWORLD N = %d %d %d\n',chosenN);
fprintf('GREYWORLD P = %d %d %d\n',chosenP);
rms_err(end+1,1) = rms(err);
rms_errstd(end+1,1) = rmsstderr(err);
descr{end+1} = sprintf('Greyworld');

print_error(descr{end},err);


%
% Greyworld performance bound
%

min_err = Inf(max(ind),1);
load(['results/batch_greyworld_',imdir,'.mat'],'L','Ps','Ns');
for i=1:numel(ind)
    for p=1:numel(Ps)
	for n=1:numel(Ns)
	    tmp_err = report_error(squeeze(L(p,n,ind(i),:))',Ltrue(ind(i),:));
	    if tmp_err < min_err(ind(i))
		min_err(ind(i)) = tmp_err;
	    end
	end
    end
end

assert(all(~isinf(min_err(ind))));
print_error('Greyworld performance bound',min_err(ind));

%
% Greyworld + Prior
%
priordim = '2d';
switch outside
 case 0
  load(['results/greyworld_indoor_',priordim,'_',imdir,'.mat'],'L','Ps','Ns','etas');
 case 1
  load(['results/greyworld_outdoor_',priordim,'_',imdir,'.mat'],'L','Ps','Ns','etas');
end
err = zeros(max(ind),1);

for fold=1:3
    tmp_ind = tr_split{fold};
    tmp_ind = tmp_ind(find(outdoor(tmp_ind)==outside));
    
    for e=1:numel(etas)
	for p=1:numel(Ps)
	    for n=1:numel(Ns)

		tmpL = [];
		for i=1:numel(tmp_ind)
		    tmpL(i,:) = L{tmp_ind(i)}(e,p,n,:);
		end
		
		tmp_err = report_error(tmpL,Ltrue(tmp_ind,:));
		tmp_rmserr(e,p,n) = rms(tmp_err);
	    end
	end
    end
    
    tmp_rmserr = tmp_rmserr + 1e-9*randn(size(tmp_rmserr));
    D = (tmp_rmserr == min(tmp_rmserr(:)));

    [bestEta,bestN,bestP] = ind2sub(size(D),find(D));
    
    tmp_ind = te_split{fold};
    tmp_ind = tmp_ind(find(outdoor(tmp_ind)==outside));

    tmpL = [];
    for i=1:numel(tmp_ind)
	tmpL(i,:) = L{tmp_ind(i)}(bestEta,bestP,bestN,:);
    end
    err(tmp_ind) = report_error(tmpL,Ltrue(tmp_ind,:));

    chosenEta(fold) = etas(bestEta);
    chosenP(fold) = Ps(bestP);
    chosenN(fold) = Ns(bestN);
end

err = err(ind);
assert(all(err~=0));

fprintf('GREYWORLD + Prior N = %d %d %d\n',chosenN);
fprintf('GREYWORLD + Prior P = %d %d %d\n',chosenP);
fprintf('GREYWORLD + Prior Eta = %d %d %d\n',chosenEta);
rms_err(end+1,1) = rms(err);
rms_errstd(end+1,1) = rmsstderr(err);
descr{end+1} = sprintf('Greyworld + Prior (CC)');
print_error(descr{end},err);

%
% Greyworld + Prior + GB
%
priordim = '2d';
switch outside
 case 0
  load(['results/greyworld_indoor_',priordim,'_sfu_',imdir,'.mat'],'L','Ps','Ns','etas');
 case 1
  load(['results/greyworld_outdoor_',priordim,'_sfu_',imdir,'.mat'],'L','Ps','Ns','etas');
end
err = zeros(max(ind),1);

for fold=1:3
    tmp_ind = tr_split{fold};
    tmp_ind = tmp_ind(find(outdoor(tmp_ind)==outside));
    
    for e=1:numel(etas)
	for p=1:numel(Ps)
	    for n=1:numel(Ns)

		tmpL = [];
		for i=1:numel(tmp_ind)
		    tmpL(i,:) = L{tmp_ind(i)}(e,p,n,:);
		end
		
		tmp_err = report_error(tmpL,Ltrue(tmp_ind,:));
		tmp_rmserr(e,p,n) = rms(tmp_err);
	    end
	end
    end
    
    tmp_rmserr = tmp_rmserr + 1e-9*randn(size(tmp_rmserr));
    D = (tmp_rmserr == min(tmp_rmserr(:)));

    [bestEta,bestN,bestP] = ind2sub(size(D),find(D));
    
    tmp_ind = te_split{fold};
    tmp_ind = tmp_ind(find(outdoor(tmp_ind)==outside));

    tmpL = [];
    for i=1:numel(tmp_ind)
	tmpL(i,:) = L{tmp_ind(i)}(bestEta,bestP,bestN,:);
    end
    err(tmp_ind) = report_error(tmpL,Ltrue(tmp_ind,:));

    chosenEta(fold) = etas(bestEta);
    chosenP(fold) = Ps(bestP);
    chosenN(fold) = Ns(bestN);
end

err = err(ind);
assert(all(err~=0));
rms_err(end+1,1) = rms(err);
rms_errstd(end+1,1) = rmsstderr(err);
descr{end+1} = sprintf('Greyworld + Prior (GB)');
fprintf('GREYWORLD + Prior (GB) N = %d %d %d\n',chosenN);
fprintf('GREYWORLD + Prior (G) P = %d %d %d\n',chosenP);
fprintf('GREYWORLD + Prior (GB) Eta = %d %d %d\n',chosenEta);

print_error(descr{end},err);




%
% BAYES re-estimate
%
switch outside
 case 0
  resultfile = ['results/indoor_em_',imdir,'.mat'];
 case 1
  resultfile = ['results/outdoor_em_',imdir,'.mat'];
end

load(resultfile,'L');
err = report_error(L(ind,:),Ltrue(ind,:),'measure','mse');
rms_err(end+1,1) = rms(err);
rms_errstd(end+1,1) = rmsstderr(err);
descr{end+1} = sprintf('Bayes (re-estimate)');
print_error(descr{end},err);

%
% NO INDOOR/OUTDOOR
%
resultfile = ['results/combined_',imdir,'.mat'];
load(resultfile,'L');
err = report_error(L(ind,:),Ltrue(ind,:),'measure','mse');
rms_err(end+1,1) = rms(err);
rms_errstd(end+1,1) = rmsstderr(err);
descr{end+1} = sprintf('Bayes (no indoor/outdoor)');
print_error(descr{end},err);


%
% BAYES SBM
%
resultfile = ['results/',str,'_sbm_',imdir,'.mat'];
load(resultfile,'L');
err = report_error(L(ind,:),Ltrue(ind,:),'measure','mse');
rms_err(end+1,1) = rms(err);
rms_errstd(end+1,1) = rmsstderr(err);
descr{end+1} = sprintf('Bayes (SBM proxy)');
print_error(descr{end},err);


if (0)
    %
    % BAYES TANH
    %
    clear L err tmp_rms_err best_rms_err
    lambdas = [0.001,0.01,0.1,1,2,5];
    best_rms_err = Inf;
    for l=1:numel(lambdas)
	lambda = lambdas(l);
	switch outside
	 case 0
	  resultfile = ['results/indoor_softclipped_',imdir,'_tanh',num2str(lambda),'.mat'];
	 case 1
	  resultfile = ['results/outdoor_softlipped_',imdir,'_tanh',num2str(lambda),'.mat'];
	end
	load(resultfile,'L');
	
	tmp_err = report_error(L(ind,:),Ltrue(ind,:),'measure','mse');

	tmp_rms_err = rms(tmp_err);
	if tmp_rms_err < best_rms_err
	    bestLambda = lambda;
	    best_rms_err = tmp_rms_err;
	    err = tmp_err;
	end
    end

    rms_err(end+1,1) = rms(err);
    rms_errstd(end+1,1) = rmsstderr(err);
    descr{end+1} = sprintf('Bayes (tanh,lambda=%g)',bestLambda);
end

%
% BAYES TANH
%
clear L err tmp_rms_err best_rms_err
lambdas = [0.001,0.01,0.1,1,2,5];
best_rms_err = Inf;

for fold=1:3
    train_ind = intersect(ind,tr_split{fold});
    test_ind = intersect(ind,te_split{fold});

    for l=1:numel(lambdas)
	lambda = lambdas(l);
	switch outside
	 case 0
	  resultfile = ['results/indoor_softclipped_',imdir,'_tanh',num2str(lambda),'.mat'];
	 case 1
	  resultfile = ['results/outdoor_softclipped_',imdir,'_tanh',num2str(lambda),'.mat'];
	end
	load(resultfile,'L');

	%	tmp_err = report_error(L(ind,:),Ltrue(ind,:),'measure','mse');
	tmp_err = report_error(L(train_ind,:),Ltrue(train_ind,:),'measure','mse');
	tmp_rms_err(l) = rms(tmp_err);
    end
    %    tmp_rms_err = tmp_rms_err - (1:numel(tmp_rms_err))*1e-9;
    [ignore,bestL] = min(tmp_rms_err);
    tmp_rms_err
    bestL
    chosenLambda(fold) = lambdas(bestL);
    switch outside
     case 0
      resultfile = ['results/indoor_softclipped_',imdir,'_tanh',num2str(chosenLambda(fold)),'.mat'];
     case 1
      resultfile = ['results/outdoor_softclipped_',imdir,'_tanh',num2str(chosenLambda(fold)),'.mat'];
    end
    load(resultfile,'L');
    err(test_ind) =  report_error(L(test_ind,:),Ltrue(test_ind,:),'measure','mse');
end

err = err(ind);
rms_err(end+1,1) = rms(err);
rms_errstd(end+1,1) = rmsstderr(err);
descr{end+1} = sprintf('Bayes (tanh)');
print_error(descr{end},err);


%
% BAYES GT
%
resultfile = ['results/',str,'_',imdir,'.mat'];
load(resultfile,'L');
err = report_error(L(ind,:),Ltrue(ind,:),'measure','mse');
rms_err(end+1,1) = rms(err);
rms_errstd(end+1,1) = rmsstderr(err);
descr{end+1} = sprintf('Bayes (GT)');

print_error(descr{end},err);



for i=1:numel(descr)
    descr2{i} = descr{numel(descr)-i+1};
end

figure(1);clf
errorbarplot(rms_err(end:-1:1),rms_errstd(end:-1:1),descr2)
if outside
    title('Outdoor Images');
else
    title('Indoor Images');
end


if (1)
    set(gcf,'PaperPositionMode','auto');
    if outside
	title('Outdoor images');
	print -depsc2 outdoorresults.eps
    else
	title('Indoor images');
	print -depsc2 indoorresults.eps
    end 
end
