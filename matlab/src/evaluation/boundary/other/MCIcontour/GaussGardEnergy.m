function CenEnergyData = GaussGardEnergy(image,sigma,angles)
% function CenEnergyData = GaussGardEnergy(image,sigma,angles)
% filtering the input image with Gauss-Gardient filters.
% inputs:
%        image ----- the input image.
%        sigma ----- the filter size.
%        angles ---- the number of filter orientation.
% outputs:
%        CenEnergyData --- Gauss-Gardient energy over all orientations

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

image = double(image);
[m n] = size(image);
CenEnergyData = zeros(m,n,angles);

for i=1:angles
        dgau2D = DivGauss2D(sigma,(i-1)*pi/angles);
        temp = abs(conByfft(image,dgau2D));
        CenEnergyData(:,:,i) = temp;
end
%=========================================================================%
