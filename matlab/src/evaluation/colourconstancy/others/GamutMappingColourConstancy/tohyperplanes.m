function hp=tohyperplanes(k3,coords)
% TOHYPERPLANES: Support function for gamut_mapping.m
%
%   Computes the hyperplanes of the facets that are specified with the
%   input parameters (which are the results of compute_ch)
%

m=size(k3,1);

hp=zeros(m,4);
for i=1:m
  p1=coords(k3(i,1),:)';
  p2=coords(k3(i,2),:)';
  p3=coords(k3(i,3),:)';
  a=cross(p3-p1,p2-p1);
  b=-a'*p1;
  % p=coords(get_diff([k3(i,1),k3(i,2),k3(i,3)],1:m),:); 
  if(sum(a'*coords'+b)<0)
%  if( sum(a'*coords'+b< 0.00001 ) )
    a=-a; b=-b;  
  end
  hp(i,:)=[b,a'];  
end



