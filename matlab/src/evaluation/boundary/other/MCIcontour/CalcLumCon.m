function [lum, con] = CalcLumCon(map,Msize)
% function [lum, con] = CalcLumCon(map,Msize)
% computing the local luminance and luminance contrast features
% inputs:
%        map  ----- input image
%        Msize ---- size of local window
% outputs:
%        lum ------ local luminance
%        con ------ local contrast (RMS contrast)
%
% Contact:
% Visual Cognition and Computation Laboratory(VCCL),
% Key Laboratory for Neuroinformation of Ministry of Education,
% School of Life Science and Technology,
% University of Electronic Science and Technology of China, Chengdu, 610054, China
% Website: http://www.neuro.uestc.edu.cn/vccl/home.html
%
% Kaifu Yang <yang_kf@163.com>
% September 2014
%=========================================================================%

Mi= Msize(1); Mj = Msize(2);
Emap = padarray(map,[floor(Mi/2) floor(Mj/2)],'replicate','both');
[Ex,Ey] = size(Emap);

width = floor(Mi/2);
[x,y] = meshgrid(-width:width,-width:width);
mask = sqrt(x.*x+y.*y)<=width;
temp = 0.5*(cos(pi/width*sqrt(x.*x+y.*y))+1);
wi = mask.*temp;
wi = wi./sum(wi(:));

TLL = zeros(Ex,Ey);
Trms = zeros(Ex,Ey);

for i = floor(Mi/2)+1 : Ex-floor(Mi/2)
    for j = floor(Mj/2)+1 : Ey-floor(Mj/2)
        
        temp = Emap(i-floor(Mi/2):i+floor(Mi/2),j-floor(Mj/2):j+ floor(Mj/2));
        TLL(i,j) = sum(sum(temp.*wi));
        
        Ndif = (temp - TLL(i,j)).^2./TLL(i,j).^2;
        Trms(i,j) = sqrt(sum(sum(Ndif.*wi)));
    end
end

lum = TLL(floor(Mi/2)+1:Ex-floor(Mi/2),floor(Mj/2)+1:Ey-floor(Mj/2));
lum = lum./max(lum(:));

con = Trms(floor(Mi/2)+1:Ex-floor(Mi/2),floor(Mj/2)+1:Ey-floor(Mj/2));
con = con./max(con(:));
%=========================================================================%
