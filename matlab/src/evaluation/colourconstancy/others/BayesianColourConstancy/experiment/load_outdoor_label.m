% interface to the outdoor.txt file. Returns a vector 'outdoor' of
% the same length as the input 'Xfiles' with 1 indicating an
% outdoor scene and 0 an indoor scene.
function outdoor = load_outdoor_label(Xfiles)

fid = fopen('~/colorconstancy/ColorCheckerDatabase/outdoor.txt','r');
files = textscan(fid,'%s %d\n');
fclose(fid);
outd = files{2};
files = files{1};


if nargin > 0

    files = lower(files);
    for i=1:numel(Xfiles)
	fname1 = strrep(lower(Xfiles{i}),'.tif','');;
	
	ind = find(strcmp(fname1,files));
	if ~numel(ind)
	    fname1
	    error('no correspinding entry found');
	end
	
	outdoor(i) = outd(ind);
	
    end
    

else
    load_directories;



    fid = fopen('~/colorconstancy/ColorCheckerDatabase/files.txt','r');
    imfiles = textscan(fid,'%s\n');
    fclose(fid);
    imfiles = imfiles{1};

    for i=1:length(imfiles)
	found = 0;
	for j=1:length(files)
	    if strfind(lower(imfiles{i}),lower(files{j}))>0
		outdoor(i,1) = outd(j);
		found = 1;
		break;
	    end
	end
	if found == 0 
	    error('no corresponding entry');
	end
    end
end