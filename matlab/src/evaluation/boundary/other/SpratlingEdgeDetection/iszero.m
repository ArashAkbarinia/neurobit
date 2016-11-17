function tf=iszero(x)
%Input (x) is a scalar, vector or matrix.
%Output (tf) is 1 or 0. 
%Output is 1 if all elements of x are zero, 0 otherwise.
tf=min(x(:)==0);
