function gauss=gauss2D(sigma,orient,aspect,norm,pxsize,x0,y0,order)
%function gauss=gauss2D(sigma,orient,aspect,norm,pxsize,x0,y0,order)
%
% This function produces a numerical approximation to Gaussian function with
% variable aspect ratio.
% Parameters:
% sigma  = standard deviation of Gaussian envelope, this in-turn controls the
%          size of the result (pixels)
% orient = orientation of the Gaussian clockwise from the vertical (degrees)
%          Optional, if not specified orient=0.
% aspect = aspect ratio of Gaussian envelope (0 = no "length" to envelope, 
%          1 = circular symmetric envelope)
%          Optional, if not specified aspect=1.
% norm   = 1 to normalise the gaussian so that it sums to 1
%        = 0 for no normalisation (gaussian has max value of 1)
%          Optional, default value is 1.
% pxsize = the size of the filter.
%          Optional, if not specified size is 5*sigma.
% x0,y0  = location of the centre of the gaussian.
%          Optional, if not specified gaussian is centred in the middle of image.
% order  = order of differential. Differential is calculated in the y direction.
%          Valid values are whole numbers from 0 (output is not differentiated) 
%          to 2 (output is 2nd differential of a gaussian).
%          Optional, if not specified default is 0.

if nargin<2 || isempty(orient), orient=0; end
if nargin<3 || isempty(aspect), aspect=1; end
if nargin<4 || isempty(norm), norm=1; end
if nargin<5 || isempty(pxsize), pxsize=odd(5*sigma); end
if nargin<6 || isempty(x0), x0=0; end
if nargin<7 || isempty(y0), y0=0; end
if nargin<8 || isempty(order), order=0; end 

%define grid of x,y coodinates at which to define function
pxrange=(pxsize-1)/2;
[x y]=meshgrid(-pxrange:pxrange,-pxrange:pxrange);
 
%rotate 
orient=-orient*pi/180;
x_theta=(x-x0)*cos(orient)+(y-y0)*sin(orient);
y_theta=-(x-x0)*sin(orient)+(y-y0)*cos(orient);

%avoid division by zero errors
sigma=max(1e-15,sigma);

%define gaussian
gauss=exp(-.5*( ((x_theta.^2)./((sigma*aspect).^2)) ...
                + ((y_theta.^2)./(sigma.^2)) ));
gauss=gauss./(sigma*sqrt(2*pi));

%differentiate gaussian, if requested
if order==0
  %do nothing
elseif order==1
  gauss=gauss.*(-y_theta./(sigma^2));
elseif order==2
  gauss=gauss.*((y_theta.^2-sigma^2)./(sigma^4));
else
  disp('ERROR: order of differential applied to gaussian, not defined');
end

%normalise
if norm, 
  gauss=gauss./sum(sum(abs(gauss))); 
else
  gauss=gauss./max(max(abs(gauss)));
end
