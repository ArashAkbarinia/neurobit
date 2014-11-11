
%Table 3 of D. Cao et al. / Vision Research 45 (2005) 1929�1934
%The cone chromaticities of the focal colors
% Focal color       L/(L + M)       S/(L + M)
% Red               0.777           0.54
% Green             0.630           0.44
% Blue              0.595           2.72
% Yellow            0.687           0.13
% Purple            0.659           2.15
% Orange            0.730           0.33
% Pink              0.687           1.15
% White             0.660           0.87
%
% This function was updated by Alej in/Sept/2014
%

function [G, B, Pp, Pk, R, O, Y, Br, Gr, Ach] = lsY2Focals(lsY)


if exist('2014_ellipsoid_params.mat','file')
  load 2014_ellipsoid_params.mat;
else
  disp('Ellipsoid parameters not found');
  exit;
end

[n,m,p] = size(lsY);
belongings = zeros(n,m,10); % [G B Pp Pk R O Y Br Gr]
belongings(:,:,10) = lsY(:,:,3)./max(max(lsY(:,:,3))); %generate achromatic representation
if p==3
  %first, convert the picture into a giant vector where every row correspond to
  %a pixel in lsY space
  n2=n*m;
  lsY = reshape(lsY,n2,p);
end

for Colour = 1:9
  %lsY, cl, cs, cY, a, b, c, grl, grs, grY, alpha_rad)
  bng = evaluate_belonging(...
    lsY, ellipsoids(Colour,1), ellipsoids(Colour,2), ellipsoids(Colour,3),...
    ellipsoids(Colour,4), ellipsoids(Colour,5), ellipsoids(Colour,6),...
    ellipsoids(Colour,7), ellipsoids(Colour,8));
  
  belongings(:,:,Colour) = reshape(bng, n, m, 1);
end

G   = belongings(:,:,1);
B   = belongings(:,:,2);
Pp   = belongings(:,:,3);
Pk   = belongings(:,:,4);
R   = belongings(:,:,5);
O  = belongings(:,:,6);
Y   = belongings(:,:,7);
Br  = belongings(:,:,8);
Gr  = belongings(:,:,9);
Ach = belongings(:,:,10);


% Temp = lsY - repmat([Focal_Red,maxlum],[n2,1]);
% Temp(:,2) = Temp(:,2).*scaleF;
% R = sqrt((Temp(:,1)).^2 + (Temp(:,2)).^2);
% R = 1./(1 + exp(expony_m.*(R - shifty_m)));
% R = reshape(R, n, m, 1);
%
% Temp = lsY - repmat([Focal_Green,maxlum],[n2,1]);
% Temp(:,2) = Temp(:,2).*scaleF;
% G = sqrt((Temp(:,1)).^2 + (Temp(:,2)).^2);
% G = 1./(1 + exp(expony_m.*(G - shifty_m)));
% G = reshape(G, n, m, 1);
%
% Temp = lsY - repmat([Focal_Blue,maxlum],[n2,1]);
% Temp(:,2) = Temp(:,2).*scaleF;
% B = sqrt((Temp(:,1)).^2 + (Temp(:,2)).^2);
% B = 1./(1 + exp(expony_xl.*(B - shifty_xl)));
% B = reshape(B, n, m, 1);
%
% Temp = lsY - repmat([Focal_Yellow,maxlum],[n2,1]);
% Temp(:,2) = Temp(:,2).*scaleF;
% Y = sqrt((Temp(:,1)).^2 + (Temp(:,2)).^2);
% Y = 1./(1 + exp(expony_s.*(Y - shifty_s)));
% Y = reshape(Y, n, m, 1);
%
% Temp = lsY - repmat([Focal_Purple,maxlum],[n2,1]);
% Temp(:,2) = Temp(:,2).*scaleF;
% Pp = sqrt((Temp(:,1)).^2 + (Temp(:,2)).^2);
% Pp = 1./(1 + exp(expony_m.*(Pp - shifty_m)));
% Pp = reshape(Pp, n, m, 1);
%
% Temp = lsY - repmat([Focal_Orange,maxlum],[n2,1]);
% Temp(:,2) = Temp(:,2).*scaleF;
% O = sqrt((Temp(:,1)).^2 + (Temp(:,2)).^2);
% O = 1./(1 + exp(expony_l.*(O - shifty_l)));
% O = reshape(O, n, m, 1);
%
% Temp = lsY - repmat([Focal_Pink,maxlum],[n2,1]);
% Temp(:,2) = Temp(:,2).*scaleF;
% Pk = sqrt((Temp(:,1)).^2 + (Temp(:,2)).^2);
% Pk = 1./(1 + exp(expony_m.*(Pk - shifty_m)));
% Pk = reshape(Pk, n, m, 1);
%
% Temp = lsY - repmat([Focal_Brown,maxlum],[n2,1]);
% Temp(:,2) = Temp(:,2).*scaleF;
% Br = sqrt((Temp(:,1)).^2 + (Temp(:,2)).^2);
% Br = 1./(1 + exp(expony_s.*(Br - shifty_s)));
% Br = reshape(Br, n, m, 1);

end
