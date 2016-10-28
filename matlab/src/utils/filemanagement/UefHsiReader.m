function hsi = UefHsiReader(FilePath, wavelength)
%UefHsiReader  reading the ascii files from hyperspectral images from UEF.
%

hsi = struct();

fid = fopen(FilePath);

tline = fgets(fid);
while ischar(tline)
  ItemNoSpace = regexprep(tline, '[^\w'']', '');
  if isstrprop(ItemNoSpace, 'xdigit')
    tmp = textscan(tline, '%f');
    hsi.spectra.(CurrentItem) = [hsi.spectra.(CurrentItem), tmp{1}(:)'];
  else
    CurrentItem = ItemNoSpace;
    hsi.spectra.(CurrentItem) = [];
  end
  
  tline = fgets(fid);
end

hsi.wavelength = wavelength;
fclose(fid);

end
