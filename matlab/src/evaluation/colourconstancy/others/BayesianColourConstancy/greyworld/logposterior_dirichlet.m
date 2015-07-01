function [f,df] = logposterior_dirichlet(logl,sumy,alpha,n,p,eta)

if ~exist('eta','var')
    eta = 1;
end

l = exp(logl);

alpha1 = alpha-1;

suml = sum(l);
lnorm  = l(1:2)./suml;

if size(sumy,1) == 1
    sumy = sumy';
end

if p > 0
  f = -n*sum(logl) - sum(sumy./(l.^p))/p - 2*log(suml);
  f = eta * f - (alpha1(1))*log(lnorm(1)) - (alpha1(2))*log(lnorm(2)) - (alpha1(3))*log(1-sum(lnorm));
else
    error('prior for scale by max not yet implemented');
end


f = -f;

if nargout > 1

    df = n./l;

    switch p
     case -1
     case -2
     otherwise
      df = df - sumy./(l.^(p+1));
    end
    
    df = df + 2/suml;
    
    suml2 = suml^2;
    
    L(1,1) = 1/suml - l(1)/suml2;
    L(1,2) = -l(2)/suml2;
    L(1,3) = -L(1,1)-L(1,2);
    L(2,1) = -l(1)/suml2;
    L(2,2) = 1/suml - l(2)/suml2;
    L(2,3) = -L(2,1) - L(2,2);
    L(3,1) = -l(1)/suml2;
    L(3,2) = -l(2)/suml2;
    L(3,3) = -L(3,1) - L(3,2);
    
    df = eta * df + L*[alpha1(1)/lnorm(1),alpha1(2)/lnorm(2),alpha1(3)/(1-sum(lnorm))]';
    
    df = df.*l;
end
