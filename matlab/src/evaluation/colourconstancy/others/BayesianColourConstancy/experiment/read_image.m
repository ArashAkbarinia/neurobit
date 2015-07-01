% [I,mask] = read_image(filename,imdir)
% 
% load the the image file [imdir,filename] and also return the mask
% of the image
function [I,mask] = read_image(filename,imdir)

if ~strcmp(imdir(end),'/')
    imdir(end+1) = '/';
end

try
    I = imread([imdir,filename]);
catch
    I = imread(['~/projects/colorconstancy/ColorCheckerDatabase/' imdir filename]);
end

if nargout > 1

    warning off
    addpath ~/colorconstancy/ColorCheckerTools
    warning on

    fname = strrep(filename,'.tif','_macbeth.txt');
    dat = load(['~/projects/colorconstancy/ColorCheckerDatabase/coordinates/' fname]);

    if size(dat,1) ~= 101 || size(dat,2) ~=2 
	error('coordinate data in invalid format')
    end

    n2 = dat(1,1);
    n1 = dat(1,2);

    [nn1,nn2,nn3] = size(I);

    if nn2~=n2
	%fprintf('read_image: scale = %g\n',nn2/n2);

	dat(:,1) = dat(:,1) * nn1/n1;
	dat(:,2) = dat(:,2) * nn2/n2;
    end
    
    dat(1,:) = [];
    
    mask = getMask(I,dat(1:4,:));
end

