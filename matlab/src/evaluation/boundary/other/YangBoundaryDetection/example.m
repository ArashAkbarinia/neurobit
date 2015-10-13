% demo:
% color boundary detection with  Double-opponent cells and Spatial Sparseness Constraint.
% paper in CVPR 2013 and TIP 2015:
% (1) Kaifu Yang, Shaobing Gao, Chaoyi Li, and Yongjie Li*.
% Efficient Color Boundary Detection with Color-opponent Mechanisms. CVPR,2013.
% (2) Kai-Fu Yang, Shao-Bing Gao,Ce-Feng Guo, Chao-Yi Li, and Yong-Jie Li*.
% Boundary Detection Using Double-Opponency and Spatial Sparseness Constraint.TIP,2015.
% Website: http://www.neuro.uestc.edu.cn/vccl/home.html

% Kaifu Yang <yang_kf@163.com>
% May 2015
%=========================================================================%

clc;  clear;

% parameters setting
angles = 8;
sigma = 1.1;
weights = -0.7;
ws = 5;
 
% read original image
map = double(imread('69020.jpg'))./255;
figure;imshow(map,[]);

tic
SCO = SCOBoundary(map,sigma,angles,weights,ws);
toc

figure;imshow(SCO,[]);

fprintf(2,'======== THE END ========\n');
%=========================================================================%
