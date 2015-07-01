function [H]= gDer(f,sigma, iorder,jorder)

%H = HxRecGauss(f, sigma, sigma, iorder,jorder,3);
%H = HxGaussDerivative2d(f, sigma, iorder,jorder,3);

%original program
%Initialize the filter

break_off_sigma = 3.;
filtersize = floor(break_off_sigma*sigma+0.5);

f=fill_border(f,filtersize);

x=-filtersize:1:filtersize;
x2 = x.^2;

sigma2 = sigma^2;

Gauss=1/(sqrt(2 * pi) * sigma)* exp(x2/(-2 * sigma2) );

switch(iorder)
    case 0
        Gx= Gauss/sum(Gauss);
    case 1
        Gx =  -(x/sigma2).*Gauss;
        Gx =  Gx./(sum(sum(x.*Gx)));
        Gx = -Gx;
    case 2
        Gx = (x2/sigma2^2-1/sigma2).*Gauss;
        Gx = Gx-sum(Gx)/size(x,2);
        Gx = Gx/(0.5*sum(x2.*Gx));
end
%H2 = filter2(Gx,f);
H = convolve2(f,Gx,'valid');

switch(jorder)
    case 0
        Gy = Gauss/sum(Gauss);
    case 1
        Gy = -(x/sigma2).*Gauss;
        Gy = Gy./(sum(sum(x.*Gy)));
        Gy = -Gy;
    case 2
        Gy = (x2/sigma2^2-1/sigma2).*Gauss;
        Gy = Gy-sum(Gy)/size(x,2);
        Gy = Gy/(0.5*sum(x2.*Gy));

end
%H = filter2(Gy',H);
H = convolve2(H,Gy','valid');

%H=H(filtersize+1:size(H,1)-filtersize,filtersize+1:size(H,2)-filtersize);
