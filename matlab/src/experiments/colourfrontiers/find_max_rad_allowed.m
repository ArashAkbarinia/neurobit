function radius = find_max_rad_allowed(crs, startangle, endangle, labplane)

White_CIE1931 = crsSpaceToSpace(crs.CS_RGB, [1, 1, 1], crs.CS_CIE1931, 0);

%ref = the brightest D65 that the monitor can achieve
ref = whitepoint('d65') ./ max(whitepoint('d65')) .* White_CIE1931(3);

found = 0;
%kk= 1;
radius = 100;
step = 0.1;
ang = startangle;
while ~found
  labcolour = pol2cart3([ang, radius, labplane]);
  [~, errcode] = Lab2CRSRGB(crs, [labcolour(3), labcolour(1:2)], ref, 0);
  
  if errcode
    %debug(kk,:) = [ang radius RGBcol]; kk = kk+1;
    radius = radius - step;
    ang = startangle;
  else
    %debug(kk,:) = [ang radius RGBcol]; kk = kk+1;
    ang = ang + step ./ 10;
    if ang >= endangle
      found = 1;
    end
  end
  %errcode = 0;
end

end
