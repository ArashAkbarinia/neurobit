function fb = SCOBoundary(map,sigma,angles,weights,ws)
% function fb = SCOBoundary(map,sigma,angles,weights,ws)
% inputs:
%         map ------ RGB color map.
%         sigma ---- Local scale (the size of cones' RF).
%         angles --- the number of orientation.
%         weights -- one of the cone weights(the other one is 1).
%         ws ------- the size of window for sparseness measure.
% outputs:
%         fb  ------ final soft boundary
%
% Main function for performing boundary detection system based 
% in paper:
% (1) Kaifu Yang, Shaobing Gao, Chaoyi Li, and Yongjie Li*.
% Efficient Color Boundary Detection with Color-opponent Mechanisms. CVPR,2013.
% (2) Kai-Fu Yang, Shao-Bing Gao,Ce-Feng Guo, Chao-Yi Li, and Yong-Jie Li*.
% Boundary Detection Using Double-Opponency and Spatial Sparseness Constraint.TIP,2015.
% 
% Contact:
% Visual Cognition and Computation Lab(VCCL),
% Key Laboratory for NeuroInformation of Ministry of Education,
% School of Life Science and Technology(SLST), 
% University of Electrical Science and Technology of China(UESTC).
% Address: No.4, Section 2, North Jianshe Road,Chengdu,Sichuan,P.R.China, 610054
% Website: http://www.neuro.uestc.edu.cn/vccl/home.html

% 电子科技大学，生命科学与技术学院，
% 神经信息教育部重点实验室，视觉认知与计算组
% 中国，四川，成都，建设北路二段4号，610054

% 杨开富/Kaifu Yang <yang_kf@163.com>;
% 李永杰/Yongjie Li <liyj@uestc.edu.cn>;
% May 2015
%
%========================================================================%
if nargin < 5, ws= 5; end
if nargin < 4, weights= -0.7; end
if nargin < 3,  angles = 8;  end

% obtain the final response
[Res theta] = resSCO(map,sigma,angles,weights,ws);
Re = Res./max(Res(:));

% non-max suppression...
theta = (theta-1)*pi/angles;
theta = mod(theta+pi/2,pi);
fb = nonmax(Re,theta);
fb = max(0,min(1,fb));

% mask out 1-pixel border where nonmax suppression fails
fb(1,:) = 0;
fb(end,:) = 0;
fb(:,1) = 0;
fb(:,end) = 0;
%========================================================================%
