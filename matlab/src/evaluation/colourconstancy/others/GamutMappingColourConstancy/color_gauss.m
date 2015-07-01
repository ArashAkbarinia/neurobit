function [out] = color_gauss(in, sigma, order_x,order_y)
% DILATION33: Support function for gamut_mapping.m
%
%   Computes gaussian convolution on multi channel images
%

if nargin==2 
    order_x=0;
    order_y=0;
end
in2=double(in);
out=in2;

for i=1:size(in,3)
    out(:,:,i)=gDer(in2(:,:,i),sigma,order_x,order_y);
end


if(order_x==0 & order_y==0 & (size(in,3)==3)) out=uint8(out); end