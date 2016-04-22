function coeff = dog(sigma1,sigma2)  
% function coeff = dog(sigma1,sigma2)  
% inputs:
%        sigma1 --- the size of surround (non-CRF).
%        sigma2 ---  the size of center (CRF).
% outputs:
%        coeff ---- DOG+ weights
%
% Kaifu Yang <yang_kf@163.com>
% September 2014
%=========================================================================%

% get the width of filter.
GaussianDieOff = .005;
pw = 1:100;
width = find(1/sqrt(2*pi*sigma1^2)*exp(-(pw.*pw)/(2*sigma1^2))-1/sqrt(2*pi*sigma2^2)*exp(-(pw.*pw)/(2*sigma2^2)) > GaussianDieOff,1,'last');
if isempty(width)
    width = 1;
end

% construct the filter.
coeff = zeros(width*2,width*2);
for t1 = - width :width
    for t2 = - width :width
        coeff(width+1+t1,width+1+t2) = (1/(2*pi*sigma1^2))*exp(-(t1.*t1 + t2.*t2)/(2*sigma1^2))-(1/(2*pi*sigma2^2))*exp(-(t1.*t1 + t2.*t2)/(2*sigma2^2));
    end
end

coeff = max(coeff,0);
coeff = coeff/sum(coeff(:));
%=========================================================================%
