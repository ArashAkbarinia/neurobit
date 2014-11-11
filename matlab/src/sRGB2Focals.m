function [G, B, Pp, Pk, R, O, Y, Br, Gr, Ach] = sRGB2Focals(mypic_sRGB)

% D65X=	D65Y=	D65Z=
% D65= [95.017 100 108.813];
% D65l	D65s	D65Y
% [0.654741544	0.064526493	100]


lsY = XYZ2lsY(sRGB2XYZ(mypic_sRGB, true, false, [10^2 10^2 10^2]),'evenly_ditributed_stds'); %gammacorrect = true, max pix value > 1, max luminance = daylight

[G, B, Pp, Pk, R, O, Y, Br, Gr, Ach] = lsY2Focals(lsY);

end
