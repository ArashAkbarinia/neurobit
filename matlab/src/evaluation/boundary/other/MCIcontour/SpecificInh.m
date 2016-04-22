function W_inh = SpecificInh(Fmap,sigma,sig)
% function W_inh = SpecificInh(Fmap,sigma,FeaType,sig)
% this function is used to compute feature-selective inhibitory weights.
% inputs:
%        Fmap  -- feature map
%        sigma -- the size of CRF.
%        sig ----- the sensitivity of inhibition with cue difference
% outputs:
%       W_inh --- inhibitory weights
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

%check the dimension of input map_matrix
if ndims(Fmap) == 2
    [m n]=size(Fmap);
else
    disp('error: the imput matrix dimension mismatch!');
    return;
end

if  max(Fmap(:))<=1
    Fmap = floor(Fmap.*100);
    sig = sig *100;
end

% computing the specific inhibition.
sum_inh = zeros(m,n);
MIN_num = min(Fmap(:));
MAX_num = max(Fmap(:));

for i = MIN_num:MAX_num
    temp = zeros(m,n);
    temp(Fmap == i) = 1;
    temp_fea = i * ones(m,n);
    diff_fea = abs(Fmap-temp_fea);
    W_fea = exp(-(1/(2*sig^2))*diff_fea.^2);
    sum_inh = sum_inh + W_fea.*DogInhibEnergy(temp,sigma);
end
W_inh = sum_inh;
%=========================================================================%
