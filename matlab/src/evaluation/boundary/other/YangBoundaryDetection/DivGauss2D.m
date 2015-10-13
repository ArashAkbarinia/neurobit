function dgau2D = DivGauss2D(sigma,seta)
% function dgau2D = DivGauss2D(sigma,seta)
% Design the filters - a derivative of 2D gaussian with different orientation
% inputs:
%         sigma ---- Local scale (the size of V1 cells' RF).
%         seta ---- the orientation of filter.
% outputs:
%        dgau2D --- directional fiter
%
% Kaifu Yang <yang_kf@163.com>
% March 2013
%=========================================================================%

GaussianDieOff = .000001;
r = 0.5;
pw = 1:50; % possible width
ssq = sigma^2;
width = find(exp(-(pw.*pw)/(2*ssq))>GaussianDieOff,1,'last');
if isempty(width)
    width = 1;  % the user entered a really small sigma
end

% Find the directional derivative of 2D Gaussian
[x,y]=meshgrid(-width:width,-width:width);
x1 = x .* cos( seta ) + y .* sin( seta );
y1 = -x .* sin( seta ) + y .* cos( seta );

dgau2D=-x1.*exp(-(x1.*x1+y1.*y1*r*r)/(2*ssq))/(pi*ssq);
%=======================================================================%
