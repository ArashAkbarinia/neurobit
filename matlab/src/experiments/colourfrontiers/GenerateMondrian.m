function [mondrianmeanlum, RGB_colors, mymondrian, palette, Height, Width] = ...
  GenerateMondrian(BackgroundType, refillum, numsamples, MondrianParameters, CRS, ExperimentParameters, ...
  Black_palette_name, Central_patch_name, current_angle, current_radius, frame_name, shadow_name, D65_RGB, ...
  theplane)

if BackgroundType >= 0 %make a grey background Lum = BackgroundType
  testedcolours = Lab2CRSRGB([BackgroundType, 0, 0], refillum);
  RGB_colors = repmat(testedcolours, numsamples, 1);
  mondrianmeanlum = BackgroundType;
elseif BackgroundType == -1 % make a greyscale mondrian
  [testedcolours, mondrianmeanlum] = sample_lab_space(numsamples, refillum);
  testedcolours(:, 2) = 0;
  testedcolours(:, 3) = 0;
  RGB_colors = Lab2CRSRGB(testedcolours, refillum);
elseif BackgroundType == -2 % make the normal colour mondrian
  [testedcolours, mondrianmeanlum] = sample_lab_space(numsamples, refillum);
  RGB_colors = Lab2CRSRGB(testedcolours, refillum);
end

[~, Colour_assignment, ~, mymondrian] = get_simple_mondrian(MondrianParameters, CRS, ExperimentParameters);

kk = 1;
for i = 1:length(Colour_assignment(:, 1))
  mymondrian(mymondrian == Colour_assignment(i, 1)) = mod(kk, 250) + 5;
  kk = kk + 1;
end

palette = zeros(256, 3);
cont = 1 ;
for i = 1:251
  palette(i + 4, :) = RGB_colors(cont, :);
  cont = cont + 1 ;
  if cont > length(RGB_colors(:, 1))
    cont = 1;
  end
end
palette(1, :) = D65_RGB;

Height = crsGetScreenHeightPixels;
Width = crsGetScreenWidthPixels;

% drawing the central patch test:
% frist we draw a black square and then the smaller color test patch.
Central_w = floor(Width * 0.5);
Central_h = floor(Height * 0.5);
Width_Central_Patch_h = 80 ;
Width_Central_Patch_w = 80 ;

ini_h = Central_h - Width_Central_Patch_h;
fin_h = Central_h + Width_Central_Patch_h;
ini_w = Central_w - Width_Central_Patch_w;
fin_w = Central_w + Width_Central_Patch_w;

mymondrian(ini_h:fin_h , ini_w:fin_w) = Black_palette_name;

offset_black_patch_frame = 10;
ini_h = ini_h + offset_black_patch_frame;
fin_h = fin_h - offset_black_patch_frame;
ini_w = ini_w + offset_black_patch_frame;
fin_w = fin_w - offset_black_patch_frame;

mymondrian(ini_h:fin_h, ini_w:fin_w) = Central_patch_name;
startingLabcolour = Lab2CRSRGB(pol2cart3([current_angle, current_radius, theplane], 1), refillum); %D65_RGB*0.5;
palette(Central_patch_name, :) = startingLabcolour;

% drawing the white frame and the shadow.
offline_h = 80;
offline_w = offline_h;

shadow_width = 10;
shadow_offset = 10; %this should be smaller than offline_h

mymondrian(1:Height, 1:offline_w) = frame_name;
mymondrian(1:Height, Width - offline_w:Width) = frame_name;
mymondrian(1:offline_h, 1:Width) = frame_name;
mymondrian(Height - offline_h:Height, 1:Width) = frame_name;
mymondrian(offline_h + shadow_offset:Height - offline_h + shadow_offset, Width-offline_w:Width-offline_w + shadow_width) = shadow_name;
mymondrian(Height - offline_h:Height - offline_h + shadow_width, offline_w + shadow_offset:Width-offline_w + shadow_width) = shadow_name;

crsPaletteSet(palette');
crsSetDrawPage(1);
crsDrawMatrixPalettised(mymondrian);
crsSetDisplayPage(1);

end
