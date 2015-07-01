function feat = compute_weibull_parameters(imdir)

load(['~/colorconstancy/ColorCheckerDatabase/',imdir,'_whitepoints.mat']);


warning off
addpath ~/colorconstancy/image_statistics/
warning on

for k=1:numel(Xfiles)
    [I,mask] = read_image(Xfiles{k},imdir);

    feat(k,:) = fit_weibull(I,mask);
    
    if ~mod(k,10)
	disp(sprintf('%d of %d done',k,numel(Xfiles)));
    end
    
end

save(['features/weibull_',imdir,'.mat'], 'feat');

