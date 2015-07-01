% creates 'nfolds' splits of 'npts' points
%
%
function [ind_tr,ind_te] = make_cvsplit(npts,nfolds)

shuff = randperm(npts);
nptsperfold = ceil(npts/nfolds);

for cv=1:nfolds-1
    ind_te{cv} = shuff( (cv-1) * nptsperfold+1:cv*nptsperfold);
    ind_tr{cv} = setdiff(shuff,ind_te{cv});
end

ind_te{nfolds} = shuff( (nfolds-1) * nptsperfold+1:end);
ind_tr{nfolds} = setdiff(shuff,ind_te{nfolds});


