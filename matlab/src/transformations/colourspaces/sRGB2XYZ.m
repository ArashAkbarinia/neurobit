function  XYZ = sRGB2XYZ(CIERGB,gammacorrect, scaled, maxXYZ)

% Matrix Obtained from http://en.wikipedia.org/wiki/SRGB_color_space
% CIERGB is expected to have values in the range [0 1] unless the factor
% "scaled = false" is provided. In this case it expects the input to be in 
% the range [0 255] and does the scalling; 
% The output of this function is in the range [0 1] unless the vector 
% "maxXYZ" is provided. Then the output is in the range [0 maxXYZ]

% if gammacorrect = false, it assumes the input is already linearised.

if nargin <4
    maxXYZ = [1 1 1];
    disp('Warning: XYZ output normalised to 1');
end

if nargin < 3 %|| (scaled == []);
    scaled = false;
end

if nargin < 2 %|| (gammacorrect == [])
    gammacorrect = true;
end

% CIERGB2XYZ_E=       [0.4124 0.3576 0.1805;
%                      0.2126 0.7152 0.0722;
%                      0.0193 0.1192 0.9505];
                 
CIERGB2XYZ_D65=     [0.4124564  0.3575761  0.1804375;
                     0.2126729  0.7151522  0.0721750;
                     0.0193339  0.1191920  0.9503041];

if ~scaled %scale it to be between [0 1]
    CIERGB = double(CIERGB)./255;
end
                 
[lines,cols,planes]=size(CIERGB);
%RGB = zeros(lines,cols,planes);

if planes == 1
    if (lines ~= 1 && cols ~= 3)
        disp('Wrong XYZ matrix size... correcting');
        if (lines == 3 && cols == 1)
            CIERGB = CIERGB';
        else
            error('Can''t correct');
        end
    end
elseif planes ==3
    CIERGB = double(reshape(CIERGB,lines*cols,3));
else error('wrong number of planes'); 
end


if gammacorrect
    CIERGB = CIERGB./12.92 .* (CIERGB<=0.04045) + (((CIERGB+0.055)./(1+0.055)) .^(2.4)) .* (CIERGB >0.04045);
end

XYZ = CIERGB *CIERGB2XYZ_D65' ;

if ~isequal(maxXYZ,[1 1 1]);
    if planes == 3
        XYZ = XYZ.*repmat(maxXYZ,lines*cols,1);
    else
        XYZ = XYZ.*repmat(maxXYZ,lines,1);
    end
end

%XYZ=truncate(XYZ,[0 1],0);

if planes ==3
    XYZ = reshape(XYZ,lines,cols,3);   
end 
   
    
end             