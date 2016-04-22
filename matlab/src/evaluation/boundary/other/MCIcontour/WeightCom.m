function Wcom = WeightCom(SmallE,LargeE,w1,w2,w3)
% function Wcom = WeightCom(SmallE,LargE,w1,w2,w3)
% inputs:
%       SmallE ----- contour response at small scale
%       LargE ------ contour response at large scale
%       w1,w2,w3 --- inhibitory weights based on three features
% outputs:
%       Wcom ------- combined inhibitory weight
%
% Contact:
% Visual Cognition and Computation Laboratory(VCCL),
% Key Laboratory for Neuroinformation of Ministry of Education,
% School of Life Science and Technology,
% University of Electronic Science and Technology of China, Chengdu, 610054, China
% Website: http://www.neuro.uestc.edu.cn/vccl/home.html
%
% Kaifu Yang <yang_kf@163.com>
% September 2014
%=========================================================================%

SmallE = (SmallE-min(SmallE(:)))./(max(SmallE(:))-min(SmallE(:)));
LargeE = (LargeE-min(LargeE(:)))./(max(LargeE(:))-min(LargeE(:)));

minW = min(w1,min(w2,w3));
maxW = max(w1,max(w2,w3));

H = fspecial('average',[11 11]);
SmallE = imfilter(SmallE,H,'replicate');
LargE = imfilter(LargeE,H,'replicate');

Wcom = minW;
Wcom((SmallE-LargE)>0) = maxW((SmallE-LargE)>0);
%=========================================================================%

