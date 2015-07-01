function rg = load_gt(file_list,imdir)

load(['~/colorconstancy/ColorCheckerDatabase/' imdir '_whitepoints.mat'],'L','Xfiles');
for i=1:numel(file_list)
    ind = find(strcmp(file_list{i},Xfiles));
    if ~numel(ind)
	error('no corresponding entry found');
    end
    rg(i,:) = L(ind,:);
end


