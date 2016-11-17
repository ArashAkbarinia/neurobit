function OutputImage = SpratlingDemo( InputImage )
%SpratlingDemo Summary of this function goes here
%   Detailed explanation goes here

InputImage = im2single(InputImage);
X = preprocess_V1_input(InputImage);
y = v1_edge_detection(X);

reduceRange = 0.25;
nonmax = 1;
visFilters = filter_definitions_V1_edge_recon;

pb = reconstruct_edges(y, visFilters, 1:length(y) / 2, 0, reduceRange, nonmax);

[a, b, ~] = size(InputImage);
OutputImage = pb(1:a, 1:b, :);

end
