function s = sumlogs(A, dim)
% function s = sumlogs(A, dim)
% Returns log(sum(exp(A),dim))
% (idea: like sum, but where both input and output has taken logs of the
% numbers to avoid underflow / overflow).
%   specifically A contains log entries, and want l
% Based on code by Tom Minka
% subtract the largest in each column
%
% If b << a, then approximately b/a ~= 0, and we have
% log(a+b) = log( a(1+b/a)) = log a + log(1+b/a) 
% = log a + log(1+exp(log b - log a))
% Here log b - log a should be highly negative, so log(1+exp large
% neg)~= log 1 ~= 0
% Interestingly: sumlogs does not seem to obtain higher accuracy than
% sumlogs_brute (surprising), but it does avoid infinities).
% Use is necessary when exp(A) would be infinite; usu A has entries of
% magnitude 700 or more

if ~exist('dim','var')
    dim = 1;
end

if dim==2
  A = A';
end
 
[nrows, ncols] = size(A);
amax = max(A,[],1);
A = A - repmat(amax, nrows, 1);
s = amax + mexlog(sum(mexexp(A), 1));

% Code below: not always necessary - Tom had it though
% useful if some ?all entries are too small to represent (log 0)=-Inf
i = find(~isfinite(amax));
if ~isempty(i)
  s(i) = amax(i);
end

if dim==2
  s = s';
end
