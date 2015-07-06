function [Rw,Gw,Bw]=norm_derivative(in, sigma, order)

if(nargin<3) order=1; end

R=in(:,:,1);
G=in(:,:,2);
B=in(:,:,3);

Rw = NormDerivative(R, sigma, order);
Gw = NormDerivative(G, sigma, order);
Bw = NormDerivative(B, sigma, order);

end
