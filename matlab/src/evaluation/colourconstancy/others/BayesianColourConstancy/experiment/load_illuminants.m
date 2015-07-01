function rg = load_illuminants(imdir,filelist)

load(['~/colorconstancy/ColorCheckerDatabase/' imdir '_whitepoints'],'L','Xfiles');

for i=1:numel(Xfiles)
    Xfiles{i} = strrep(lower(Xfiles{i}),'.tif','');
end
for i=1:numel(filelist)
    filelist{i} = strrep(lower(filelist{i}),'.tif','');
end

for i=1:numel(filelist)
    ind = find(strcmp(filelist{i},Xfiles));
    if numel(ind)==0
	rg(i,:) = [NaN,NaN];
    else
	rg(i,:) = L(ind,:);
    end
end
