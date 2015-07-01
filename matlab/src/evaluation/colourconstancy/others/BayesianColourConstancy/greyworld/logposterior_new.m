function [f,df] = logposterior_new(logl,sumy,invcov,mu,sig2,n,p,eta)


if ~exist('eta','var')
    eta = 1;
end

l = exp(logl);

if numel(mu) == 2
    suml = sum(l);
    lnorm  = l(1:2)./suml;
else
   suml = sum(l);
    lnorm = l./sum(l);
end


if size(sumy,1) == 1
    sumy = sumy';
end
if size(mu,1)==1
    mu =mu';
end

if invcov==0
    f = eta * (-sum(n.*logl) - sum(sumy./l/2./sig2));
else
    f = eta * ( -sum(n.*logl) - sum(sumy./l/2./sig2)) - (lnorm-mu)'*invcov*(lnorm-mu);
end

f = -f;

if nargout > 1

    df = n./l - sumy./(l.^2)/2./sig2;
    df = eta * df;
    
    if invcov==0
	df = df.*l;
	return;
    end

    if numel(mu) == 2
	
	df(1) = df(1) + (2*(invcov*(lnorm-mu))'*([suml-l(1);-l(2)]/suml^2));
	df(2) = df(2) + (2*(invcov*(lnorm-mu))'*([-l(1);suml-l(2)]/suml^2));
	df(3) = df(3) + (2*(invcov*(lnorm-mu))'*([-l(1);-l(2)]/suml^2));
	df = df.*l;
    else
	df(1) = df(1) + 2*(invcov*(lnorm-mu))'*([suml-l(1);-l(2);-l(3)]/suml^2);
	df(2) = df(2) + 2*(invcov*(lnorm-mu))'*([-l(1);suml-l(2);-l(3)]/suml^2);
	df(3) = df(3) + 2*(invcov*(lnorm-mu))'*([-l(1);-l(2);suml-l(3)]/suml^2);
  	df = df.*l;
    
    end
    
end
