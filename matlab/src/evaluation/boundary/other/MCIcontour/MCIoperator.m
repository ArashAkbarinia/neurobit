function [Res theta] = MCIoperator(map,sigmas,alpha,angles)
% function [Res theta] = MCIoperator(map,sigmas,alpha,angles)
% inputs:
%         map ------ input image (gray).
%         sigma ---- local scale (the size of  CRF).
%         alpha ---- connection strength between the cells within CRF and non-CRF.
%         angles --- the number of orientation.
% outputs:
%         Res  ------ final contour response without post-processing.
%         theta ----- the optimal orientation at each pixel.
%
% Main function for performing contour detection system based 
% on Multifeature-based surround inhibition in paper:
% Kai-Fu Yang,Chao-Yi Li, and Yong-Jie Li*.
% Multifeature-based Surround Inhibition Improves Contour Detection in 
% Natural Images. IEEE TIP, 2014.

% Contact:
% Visual Cognition and Computation Laboratory(VCCL),
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
% September 2014
%=========================================================================%
map = double(map);
[w h] = size(map);
theta = zeros(w,h);

% small scale energy
CenEnergyData = GaussGardEnergy(map,sigmas(1),angles); 
[SmallE(:,:),theta(:,:)]= max(CenEnergyData,[],3);

% local cues
Mi = 11; Mj = 11; 
[lum, con] = CalcLumCon(map,[Mi Mj]); 
TextOri = CenEnergyData./max(CenEnergyData(:));

% inhibitory weight based on individual cues 
W_ori = VectorCS(TextOri,sigmas(1),0.2);
W_lum = SpecificInh(lum,sigmas(1),0.05);
W_con = SpecificInh(con,sigmas(1),0.05);

% large scale energy
CenEnergyData = GaussGardEnergy(map,sigmas(2),angles);  
[LargeE(:,:),unused(:,:)]= max(CenEnergyData,[],3);

% cue combination
Wcom = WeightCom(SmallE,LargeE,W_ori,W_lum,W_con);

% final response
DogInh = DogInhibEnergy(SmallE,sigmas(1));
Temp = SmallE - alpha * Wcom.*DogInh;
Res = max(Temp,0);
%=========================================================================%

