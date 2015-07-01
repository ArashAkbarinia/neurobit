function EstimatedLuminance = BayesianColourConstancy(CurrentIamge)
%BAYESIANCOLOURCONSTANCY Summary of this function goes here
%   Detailed explanation goes here

fname = 'logemp_cv1_gt_out.mat';
load(fname,'logemp');

mask = zeros(size(CurrentIamge, 1), size(CurrentIamge, 2));

EstimatedLuminance = rosenberg(CurrentIamge, mask, logemp);

end

