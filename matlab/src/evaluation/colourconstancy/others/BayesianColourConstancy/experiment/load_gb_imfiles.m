function imfiles = load_imfiles

load_directories;

fid = fopen([imdir 'file.txt']);
i = 1;
while(1)
    line = fgetl(fid);
    if ~ischar(line), break; end
    imfiles{i} = strrep(line,'\','/');
    i = i + 1;
end
fclose(fid);
