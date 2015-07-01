% 
% batch script to compute gw algorithms over a set of
% parameters. Called from batch_greyworld
%
function [L,Llin] = compute_greyworld(I,Ns,Ps,etas,sig,mask,Cov,mu)

for e=1:numel(etas)
    eta = etas(e);
    for pp=1:numel(Ps)
	for nn=1:numel(Ns)
	    L(e,pp,nn,:) = general_cc(I,Ns(nn),Ps(pp),sig,'mask',mask,'where','srgb','eta',eta,'C',Cov,'mu',mu);
	    Llin(e,pp,nn,:) = general_cc(I,Ns(nn),Ps(pp),sig,'mask',mask,'where','rgb','eta',eta,'C',Cov,'mu',mu);
	end
    end
end
