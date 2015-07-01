
clear all

imdirs = {'dcraw_autowb_scaled','canon_autowb_scaled'};
lambdas = [0.1,0.5,1,Inf];
locs = [-1,1,0];


for i=1:numel(imdirs);
	for o=1:numel(locs)
    for l=1:numel(lambdas)
	    ex.imdir = imdirs{i};
	    ex.nr_cv_splits = 3;
	    ex.outside = locs(o);
	    ex.tanh_lambda = lambdas(l);

	    expfile = experiments_find(ex);
	    if ~numel(expfile)
		error('no such experiment found');
	    end

	    load(expfile,'ex');

	    fprintf('%s : lam%.1g, loc%d : ',imdirs{i},lambdas(l),locs(o));
	    
	    fprintf(' %.4f\n',ex.rms);
	end 
    end
end
