function logp = logp_X(X,logemp,lambda)

% computes the probability for the reflectances in X using the prior logemp
%

if nargin < 3
    lambda = Inf;
end

nBins = round(numel(logemp)^(1/3));

n_k = mex_histc(X,nBins);
if numel(n_k) ~= nBins^3
    error('dimension mismatch');
end

% compute the modified counts (Eq.(12) in the paper)
n = size(X,1);
pos = n_k>0;
%n_k(pos) = n./sum(pos);

% any zero probability bin with entries? p=0 then.
if any(logemp(pos)==-Inf)
    logp = -Inf;
else
    if isinf(lambda)
	% use normal thresholding
	logp = n * sum(logemp(pos)) / sum(pos);
    else
	% use a soft clipping
	n_k = double(n_k');
	tanhn_k = tanh(lambda*n_k);
	logp = n * sum(tanhn_k .* logemp)/sum(tanhn_k);
    end
end

