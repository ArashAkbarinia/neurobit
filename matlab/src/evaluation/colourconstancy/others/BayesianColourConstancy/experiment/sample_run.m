%
% shows how to use the algorithms
%
clear all

% we load a sample image 
I = imread('IMG_0376.tif');
figure(1); imshow(I); title('Original image');


addpath ../misc
addpath ../greyworld
addpath ../bayesiancc


% now first apply the greyworld algorithm
p=1;
n=0;
sig=1;


Lgw = general_cc(I,n,p,sig);
Igw = rgbscaling(I,Lgw,ones(3,1)/3);
figure(2); imshow(Igw); title('Greyworld Estimate');


% now the Bayesian algorithm
% ... load a empirical distribution
fname = sprintf('empdistr/logemp_cv1_gt_out.mat');
load(fname,'logemp');

mask = zeros(size(I,1),size(I,2)); % for demo purposes, in
                                   % experiment we masked out the
                                   % color checker chart
% ...now apply the algorithm ...
Lrb = rosenberg(I,mask,logemp);

% ... RGB scale the image ...
Irb = rgbscaling(I,Lrb,ones(3,1)/3);

% ... and present the restult
figure(3); imshow(Irb); title('Bayesian Estimate');

