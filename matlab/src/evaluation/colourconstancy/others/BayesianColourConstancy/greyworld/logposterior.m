function [f,df] = logposterior(logl,sumy,invcov,mu,n,p,eta,w)


if ~exist('eta','var')
    eta = 1;
end

if ~exist('w','var')
    w = 1;
elseif ~(all(w) == 1)
    error('implement algorithm with w!!');
end

l =  exp(logl);

if numel(mu) == 2
    suml = sum(l);
    lnorm  = l(1:2)./suml;
else
   suml = sum(l);
    lnorm = l./sum(l);
end

logdetL = log(prod(l));

if size(sumy,1) == 1
    sumy = sumy';
end
if size(mu,1)==1
    mu =mu';
end

if p==1
    if invcov==0
	f = eta * (-sum(n.*logl) - sum(sumy./l));
    else
	if numel(mu) == 2
	    f = eta * ( -sum(n.*logl) - sum(sumy./l)) - (lnorm-mu)'*invcov*(lnorm-mu);% -3*log(suml);
	else 
	    f = eta * ( -sum(n.*logl) - sum(sumy./l)) - (lnorm-mu)'* invcov*(lnorm-mu);
	end
    end
elseif p>0
    if invcov==0
	f = eta * (-n*logdetL - sum((sumy./(l.^p))./p));
    else
	if numel(mu) == 2
	    f = eta * ( -sum(n.*logl) - sum(sumy./(l.^p))./p) - (lnorm-mu)'*invcov*(lnorm-mu);% - 3*log(suml);
	else
	    f = eta * ( -sum(n.*logl) - sum(sumy./(l.^p))./p) - (lnorm-mu)'*invcov*(lnorm-mu);
	end
    end
else
    error('not implemented');
end

f = -(f);

if nargout > 1

    df = n./l;

    if p>0
      df = df - sumy./(l.^(p+1));
    end
    df = eta * df;
    
    if invcov==0
	df = df.*l;
	return;
    end

    if numel(mu) == 2
	%df = df + 3/suml;
	
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

