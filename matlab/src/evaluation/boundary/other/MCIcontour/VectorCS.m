function W_inh = VectorCS(CueVec,sigma,sig)
% function W_inh = VectorCS(CueVec,sigma,sig)
% inputs: 
%       CueVec --- input cue vector (orientation vector) 
%                 m*n*d, m*n is the size of image; d is the dimension of cues
%       sigma --- the size of CRF 
%       sig ----- the sensitivity of inhibition with cue difference 
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

% DOG+:  the non-CRF
DogCoeff = dog(4*sigma,sigma);

% the size of local template.
Mi = size(DogCoeff,1); Mj = size(DogCoeff,2); 
CueVec = padarray(CueVec,[floor(Mi/2) floor(Mj/2) 0],'replicate','both');
[Ex Ey Dim] = size(CueVec);

CM = (DogCoeff==0);
Gau = fspecial('gaussian',[Mi,Mj],sigma);
CM = CM .* Gau;
CM = CM./sum(CM(:));
for ii = 1:Dim
   CenM(:,:,ii) = CM;
   SurM(:,:,ii) = DogCoeff;
end

% computing the specific inhibition.
TWinh = zeros(Ex,Ey);
for i = floor(Mi/2)+1 : Ex-floor(Mi/2)
    for j = floor(Mj/2)+1 : Ey-floor(Mj/2)
        temp = CueVec(i-floor(Mi/2):i+floor(Mi/2),j-floor(Mj/2):j+floor(Mj/2),:);

        CenF = CenM.*temp;
        SurF = SurM.*temp;
        Dif = sum(sum(CenF,1),2)./sum(CM(:)) - sum(sum(SurF,1),2)./sum(DogCoeff(:));

        diffCS = sqrt(sum(Dif.^2));
        TWinh(i,j) = exp(-(1/(2*sig^2))*diffCS.^2);
    end
end
W_inh= TWinh(floor(Mi/2)+1:Ex-floor(Mi/2),floor(Mj/2)+1:Ey-floor(Mj/2));
%=========================================================================%

