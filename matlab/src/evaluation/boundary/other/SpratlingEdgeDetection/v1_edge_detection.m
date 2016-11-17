function [y,s,r]=v1_edge_detection(X,y)
if nargin<2, y=[]; end
global_parameters


%DEFINE V1 PREDICTION NEURON RECEPTIVE FIELDS
%phases=[0,180]; %even only
phases=[90,270]; %odd only
%phases=[0,180,90,270] %even and odd
texture=1;
lateral=1;
[w,v]=filter_definitions_V1_simple_diffGauss([],[],1, 0,phases);
if texture
  [w,v]=filter_definitions_V1_simple_diffGauss(w,v,1, 0,phases);
  phases=[phases;phases];
end
if lateral
  [w,v]=filter_definitions_V1_recurrent(w,v,0.5, 1,phases);
end


%SIMULATE V1
y=dim_activation_conv_recurrent(w,X,y,[],v);
ymax=max(cat(3,y{:}),[],3);
maxsubplot(2,2,1); plot_cropped_image(ymax); title('DIM max y')


%PLOT EDGES
if nargout>2
  [wVisualisation]=filter_definitions_V1_edge_recon([],[],phases);
  r=reconstruct_edges(y,wVisualisation);
  maxsubplot(2,2,4); plot_cropped_image(r); title('edge+texture reconstruction')
  
  r=reconstruct_edges(y,wVisualisation,[1:length(y)/2]); 
  maxsubplot(2,2,3); plot_cropped_image(r); title('edge reconstruction')
end


%CALCULATE RESPONSE SPARSITY 
if nargout>1
  yall=cat(3,y{:});
  yall=yall(:);
  sqrtn=sqrt(length(yall));
  s=(sqrtn-(norm(yall,1)/norm(yall,2)))/(sqrtn-1) %Hoyer's sparsity measure
end