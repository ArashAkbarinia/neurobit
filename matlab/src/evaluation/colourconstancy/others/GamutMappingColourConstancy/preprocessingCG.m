function [out,mask]=preprocessingCG(im,sigma,gamut_order)
% PREPROCESSINGCG: Support function for gamut_mapping.m
%
%   Applies preprocessing to the input image. For now, only smoothing is
%   applied as preprocessing, but it is known that applying segmentation
%   can in fact improve the result of pixel-based gamut mapping. This step
%   is not implemented here, though.
%

if(nargin<3)
    gamut_order=0;
end
if(nargin<2)
    sigma=0;
end


if(strcmp(num2str(gamut_order), num2str(0)))
    if(sigma>0)     % the smoothing in case of first-order gamut is done with derivation
        im=double(color_gauss(im,sigma,0,0));
    end
    max2=max(im(:));
    out=im./max2*255;
    mask= (min(out,[],3)<5) + (max(out,[],3) > 245);
    mask=mask(:)>0;

    out=reshape(out,size(im,1)*size(im,2),1,3);
    out=out(~mask,:);
    out=reshape(out,size(out,1),1,3);
else
    max2=max(im(:));
    out=im./max2*255;
    mask= (max(out,[],3) > 245);
    for ii=1:floor(sigma)
        mask=dilation33(mask>0);
%         mask = imdilate(mask, strel('disk', 3));
    end
end


% max2 = max(im(:));
% out = im./max2 * 255;
% mask = (min(out, [], 3) < 5) + (max(out, [], 3) > 245);
% for ii = 1:floor(sigma)
%     mask = dilation33(mask > 0);
% end



