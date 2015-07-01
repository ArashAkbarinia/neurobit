function [out,K]=compute_ch(im, njet, sigma, mask)  
% COMPUTE_CH: Support function for gamut_mapping.m
%
%   Computes the convex hull of input data. Note that the preprocessing of
%   pixel-based gamuts is done in a different file, and that this function
%   can also be used to compute the convex hull of preprocessed data.
%


if(size(im,3)~=3)
    im = reshape(im, size(im,1),1,3);
end

if(nargin<4)
    mask = ones(size(im,1),size(im,2)) == 1;
end
if(nargin<3)
    sigma=1;
end
if(nargin<2) 
    njet = '0';
end 

if (strcmp(num2str(njet), '0'))    
    % Compute convex hull of zeroth-order image, i.e. regular pixel values
    mask=mask(mask);
    RR = im(:,:,1); RR = RR(mask(:));
    GG = im(:,:,2); GG = GG(mask(:));
    BB = im(:,:,3); BB = BB(mask(:));

    if (~isempty(RR))
        K=convhulln([RR,GG,BB], {'QJ'});
        K2=unique(K);
        RR2=RR(K2);GG2=GG(K2);BB2=BB(K2);
        out=zeros(size(RR2,1), size(RR2,2), 3);
        out(:,:,1) = RR2;
        out(:,:,2) = GG2;
        out(:,:,3) = BB2;
        K=convhulln([RR2,GG2,BB2], {'QJ'});
    else
        out = []; 
        K = [];
    end
elseif (strcmp(num2str(njet), '1x'))
    % Compute convex hull the derivatives in the x-direction
    XX = gDer(im(:,:,1), sigma, 1, 0);
    YY = gDer(im(:,:,2), sigma, 1, 0);
    ZZ = gDer(im(:,:,3), sigma, 1, 0);
   
    mask = mask(:); 
    XX = XX(mask);
    YY = YY(mask);
    ZZ = ZZ(mask);

    mask=( abs(XX(:))+abs(YY(:))+abs(ZZ(:)) )>(3/sigma);
    
    XX=[XX(mask);-XX(mask)+rand(size(XX(mask)))*.01];
    YY=[YY(mask);-YY(mask)+rand(size(YY(mask)))*.01];
    ZZ=[ZZ(mask);-ZZ(mask)+rand(size(ZZ(mask)))*.01];

    if (~isempty(XX))
        K=convhulln([ XX(:) YY(:) ZZ(:)], {'QJ'});
        K2=unique(K);
        XX2=XX(K2);YY2=YY(K2);ZZ2=ZZ(K2);
        out=zeros(size(XX2,1),size(XX2,2),3);
        out(:,:,1)=XX2;
        out(:,:,2)=YY2;
        out(:,:,3)=ZZ2;
        K=convhulln([XX2,YY2,ZZ2], {'QJ'});
    else
        out = []; 
        K = [];
    end        
elseif (strcmp(num2str(njet), '1y'))
    % Compute convex hull the derivatives in the y-direction
    XX = gDer(im(:,:,1), sigma, 0, 1);
    YY = gDer(im(:,:,2), sigma, 0, 1);
    ZZ = gDer(im(:,:,3), sigma, 0, 1);
   
    mask = mask(:); 
    XX = XX(mask);
    YY = YY(mask);
    ZZ = ZZ(mask);

    mask=( abs(XX(:))+abs(YY(:))+abs(ZZ(:)) )>(3/sigma);
    
    XX=[XX(mask);-XX(mask)+rand(size(XX(mask)))*.01];
    YY=[YY(mask);-YY(mask)+rand(size(YY(mask)))*.01];
    ZZ=[ZZ(mask);-ZZ(mask)+rand(size(ZZ(mask)))*.01];

    if (~isempty(XX))
        K=convhulln([ XX(:) YY(:) ZZ(:)], {'QJ'});
        K2=unique(K);
        XX2=XX(K2);YY2=YY(K2);ZZ2=ZZ(K2);
        out=zeros(size(XX2,1),size(XX2,2),3);
        out(:,:,1)=XX2;
        out(:,:,2)=YY2;
        out(:,:,3)=ZZ2;
        K=convhulln([XX2,YY2,ZZ2], {'QJ'});
    else
        out = []; 
        K = [];
    end
elseif (strcmp(num2str(njet), '1grad'))
    [XX YY ZZ] = norm_derivative(im, sigma, 1);
    
    XX = reshape(XX, size(im,1)*size(im,2), 1);
    YY = reshape(YY, size(im,1)*size(im,2), 1);
    ZZ = reshape(ZZ, size(im,1)*size(im,2), 1);
    
    XX = XX(mask(:));
    YY = YY(mask(:));
    ZZ = ZZ(mask(:));
    
    mask = (abs(XX(:)) + abs(YY(:)) + abs(ZZ(:))) > (3/sigma);
    
    XX = [XX(mask); -XX(mask)+rand(size(XX(mask)))*.01];
    YY = [YY(mask); -YY(mask)+rand(size(YY(mask)))*.01];
    ZZ = [ZZ(mask); -ZZ(mask)+rand(size(ZZ(mask)))*.01];

    if (~isempty(XX))
        K = convhulln([XX(:) YY(:) ZZ(:)], {'QJ'});
        K2 = unique(K);
        XX2=XX(K2);YY2=YY(K2);ZZ2=ZZ(K2);
        out=zeros(size(XX2,1),size(XX2,2),3);
        out(:,:,1)=XX2;
        out(:,:,2)=YY2;
        out(:,:,3)=ZZ2;
        K=convhulln([XX2,YY2,ZZ2], {'QJ'});
    else
        out = []; 
        K = [];
    end
elseif (strcmp(num2str(njet), '2xx'))
    % Compute convex hull of fxx
    XX = gDer(im(:,:,1), sigma, 2, 0); XX = XX(:);
    YY = gDer(im(:,:,2), sigma, 2, 0); YY = YY(:);
    ZZ = gDer(im(:,:,3), sigma, 2, 0); ZZ = ZZ(:);
        
    mask = mask(:);
    XX = XX(mask);
    YY = YY(mask);
    ZZ = ZZ(mask);
    
    mask = (abs(XX(:)) + abs(YY(:)) + abs(ZZ(:)) ) > (3/sigma);
    
    XX = [XX(mask); -XX(mask)+rand(size(XX(mask)))*.01];
    YY = [YY(mask); -YY(mask)+rand(size(YY(mask)))*.01];
    ZZ = [ZZ(mask); -ZZ(mask)+rand(size(ZZ(mask)))*.01];

    if (~isempty(XX))
        K = convhulln([XX(:) YY(:) ZZ(:)], {'QJ'});
        K2 = unique(K);
        XX2 = XX(K2); YY2 = YY(K2); ZZ2 = ZZ(K2);
        out = zeros(size(XX2, 1), size(XX2, 2), 3);
        out(:,:,1) = XX2;
        out(:,:,2) = YY2;
        out(:,:,3) = ZZ2;
        K = convhulln([XX2, YY2, ZZ2], {'QJ'});
    else
        out = []; 
        K = [];
    end    
elseif (strcmp(num2str(njet), '2yy'))
    % Compute convex hull of fyy
    XX = gDer(im(:,:,1), sigma, 0, 2); XX = XX(:);
    YY = gDer(im(:,:,2), sigma, 0, 2); YY = YY(:);
    ZZ = gDer(im(:,:,3), sigma, 0, 2); ZZ = ZZ(:);
        
    mask = mask(:);
    XX = XX(mask);
    YY = YY(mask);
    ZZ = ZZ(mask);
    
    mask = (abs(XX(:)) + abs(YY(:)) + abs(ZZ(:)) ) > (3/sigma);
    
    XX = [XX(mask); -XX(mask)+rand(size(XX(mask)))*.01];
    YY = [YY(mask); -YY(mask)+rand(size(YY(mask)))*.01];
    ZZ = [ZZ(mask); -ZZ(mask)+rand(size(ZZ(mask)))*.01];
    
    if (~isempty(XX))
        K = convhulln([XX(:) YY(:) ZZ(:)], {'QJ'});
        K2 = unique(K);
        XX2 = XX(K2); YY2 = YY(K2); ZZ2 = ZZ(K2);
        out = zeros(size(XX2, 1), size(XX2, 2), 3);
        out(:,:,1) = XX2;
        out(:,:,2) = YY2;
        out(:,:,3) = ZZ2;
        K = convhulln([XX2, YY2, ZZ2], {'QJ'});
    else
        out = []; 
        K = [];
    end    
elseif (strcmp(num2str(njet), '2xy'))
    % Compute convex hull of fxy
    XX = gDer(im(:,:,1), sigma, 1, 1); XX = XX(:);
    YY = gDer(im(:,:,2), sigma, 1, 1); YY = YY(:);
    ZZ = gDer(im(:,:,3), sigma, 1, 1); ZZ = ZZ(:);
        
    mask = mask(:);
    XX = XX(mask);
    YY = YY(mask);
    ZZ = ZZ(mask);
    
    mask = (abs(XX(:)) + abs(YY(:)) + abs(ZZ(:)) ) > (3/sigma);
    
    XX = [XX(mask); -XX(mask)+rand(size(XX(mask)))*.01];
    YY = [YY(mask); -YY(mask)+rand(size(YY(mask)))*.01];
    ZZ = [ZZ(mask); -ZZ(mask)+rand(size(ZZ(mask)))*.01];

    if (~isempty(XX))
        K = convhulln([XX(:) YY(:) ZZ(:)], {'QJ'});
        K2 = unique(K);
        XX2 = XX(K2); YY2 = YY(K2); ZZ2 = ZZ(K2);
        out = zeros(size(XX2, 1), size(XX2, 2), 3);
        out(:,:,1) = XX2;
        out(:,:,2) = YY2;
        out(:,:,3) = ZZ2;
        K = convhulln([XX2, YY2, ZZ2], {'QJ'});
    else
        out = []; 
        K = [];
    end
elseif (strcmp(num2str(njet), '2grad'))
    % Compute convex hull of the 2nd-order gradient
    [XX YY ZZ] = norm_derivative(im, sigma, 2);
    
    XX = XX(:);
    YY = YY(:);
    ZZ = ZZ(:);
    
    XX = XX(mask(:));
    YY = YY(mask(:));
    ZZ = ZZ(mask(:));
    
    mask = (abs(XX(:)) + abs(YY(:)) + abs(ZZ(:))) > (3/sigma);
    
    XX = [XX(mask); -XX(mask)+rand(size(XX(mask)))*.01];
    YY = [YY(mask); -YY(mask)+rand(size(YY(mask)))*.01];
    ZZ = [ZZ(mask); -ZZ(mask)+rand(size(ZZ(mask)))*.01];

    if (~isempty(XX))
        K = convhulln([XX(:) YY(:) ZZ(:)], {'QJ'});
        K2 = unique(K);
        XX2=XX(K2);YY2=YY(K2);ZZ2=ZZ(K2);
        out=zeros(size(XX2,1),size(XX2,2),3);
        out(:,:,1)=XX2;
        out(:,:,2)=YY2;
        out(:,:,3)=ZZ2;
        K=convhulln([XX2,YY2,ZZ2], {'QJ'});
    else
        out = []; 
        K = [];
    end
end




% end