function t = DogInhibEnergy(EnergeData,sigma)
% function t = DogInhibEnergy(EnergeData,sigma)
% computing the non-specific (i.e. isotropic) surround inhibiton
% inputs: 
%       EnergeData -- CRF response
%       sigma ------- the size of CRF
% outputs:
%        t ----------  isotropic surround inhibiton term
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
if ndims(EnergeData) == 2  
    [m n] = size(EnergeData);
    nummap = 1;
elseif ndims(EnergeData) == 3
    [nummap m n] = size(EnergeData);
else
    disp('error: the imput matrix dimension mismatch!');
end

 % get DOG+ model
dogcoeff = dog(4*sigma,sigma);
tt = zeros(m,n);
for i=1:nummap
    if ndims(EnergeData) == 2
      tt = EnergeData;
      t = conByfft(tt,dogcoeff); % same as imfilter with 'symmetric'
    else
      tt(:,:) = EnergeData(i,:,:);  
      t(i,:,:) = conByfft(tt,dogcoeff); % same as imfilter with 'symmetric'
    end
end
%=========================================================================%
