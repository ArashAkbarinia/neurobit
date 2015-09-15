% Shaobing Gao, Kaifu Yang, Chaoyi Li, and Yongjie Li: A Color Constancy Model with Double-Opponent Mechanisms. 
% Proceeding of IEEE International Conference on Computer Vision (ICCV), pp.929-936, 2013. 
% 
% Any questions, please contact: 
% Email: gao_shaobing@163.com (Shaobing Gao)
%
% Visual Cognition and Computation Lab (VCCL),
% Key Laboratory for Neuroinformation of Ministry of Education,
% School of Life Science and Technology,
% University of Electronic Science and Technology of China,
% North Jianshe Road,
% Chengdu, 610054, China

function luminance = GaoDOCC_demo(temporypicture)


%demo
% clc
% clear all
% close all
% 
% load('sfulab_name');  % load groundtruth illuminant


% matrix for transforming RGB sapce to LMS space
D65=[0.4306190  0.3415419  0.1783091; 0.2220379  0.7066384  0.0713236; 0.0201853  0.1295504  0.9390944];
LMS=[0.3897 0.6890 -0.0787; -0.2298 1.1834 0.0464; 0.0000 0.0000 1.0000];
transformatix=LMS*D65;
inversematrix=inv(transformatix);

%% 
% The two parameters contained in our model.
% Ideally, those parameters are image dependent, and you can set it an optimal value for each image.
% In the work of ICCV13 and the extended work submitted to journal, we set optimal parameters for each datasets.
k=0.6;
sigma=3.0;

% i=60;
% temporypicture=imread('clothes3_solux-4100.tif');
picture=double(temporypicture);      

%% RGB space to LMS space
LMSpicture(:,:,1)=transformatix(1,1)*picture(:,:,1)+transformatix(1,2)*picture(:,:,2)+transformatix(1,3)*picture(:,:,3);
LMSpicture(:,:,2)=transformatix(2,1)*picture(:,:,1)+transformatix(2,2)*picture(:,:,2)+transformatix(2,3)*picture(:,:,3);
LMSpicture(:,:,3)=transformatix(3,1)*picture(:,:,1)+transformatix(3,2)*picture(:,:,2)+transformatix(3,3)*picture(:,:,3);
picture1=LMSpicture; 
%%
%double-opponency computation     
R1=picture1(:,:,1);
G1=picture1(:,:,2);
B1=picture1(:,:,3);
opponent_RG1=((1/2)^(1/2))*R1-((1/2)^(1/2))*G1;
opponent_BY1=((1/6)^(1/2))*R1+((1/6)^(1/2))*G1-((2/3)^(1/2))*B1;
opponent_L1=((1/3)^(1/2))*R1+((1/3)^(1/2))*G1+((1/3)^(1/2))*B1;   

%% separable filter
Sgaus = Gauss1D(sigma);
Lgaus = Gauss1D(3*sigma);

MaxVal(1) = max(opponent_RG1(:));
MaxVal(2) = max(opponent_BY1(:));
MaxVal(3) = max(opponent_L1(:));
opponent_RG1 = opponent_RG1 ./ max(MaxVal(:));
opponent_BY1 = opponent_BY1 ./ max(MaxVal(:));
opponent_L1 = opponent_L1 ./ max(MaxVal(:));

double_RG1 = Doubleopponent(opponent_RG1,Sgaus,Lgaus,k);
double_BY1 = Doubleopponent(opponent_BY1,Sgaus,Lgaus,k);
double_L1 = Doubleopponent(opponent_L1,Sgaus,Lgaus,k);

% double_RG1 = Doubleopponent_arash(opponent_RG1,Sgaus,Lgaus,k);
% double_BY1 = Doubleopponent_arash(opponent_BY1,Sgaus,Lgaus,k);
% double_L1 = Doubleopponent_arash(opponent_L1,Sgaus,Lgaus,k);

%%
DoBoPicture1(:,:,1)=double_RG1;
DoBoPicture1(:,:,2)=double_BY1;
DoBoPicture1(:,:,3)=double_L1;
%% double-opponency space to LMS space
RGB_DoBoPicture1=Opponent_Tri_RGB(DoBoPicture1);
C1=RGB_DoBoPicture1(:,:,1);
C2=RGB_DoBoPicture1(:,:,2);
C3=RGB_DoBoPicture1(:,:,3);
%% nonlinear rectified
  
X5=abs(C1(:));
Y5=abs(C2(:));
Z5=abs(C3(:));

%   X5=C1(:)-min(C1(:));
%   Y5=C2(:)-min(C2(:));
%   Z5=C3(:)-min(C3(:));
  
%   X5=max(C1(:),0);
%   Y5=max(C2(:),0);
%   Z5=max(C3(:),0);

%% illuminant estimation with max pooling    
Estimate1(1,:)=max(X5);
Estimate1(2,:)=max(Y5);
Estimate1(3,:)=max(Z5);
%% LMS space to RGB space
RGBEstimate1(1,:)=inversematrix(1,1)*Estimate1(1,:)+inversematrix(1,2)*Estimate1(2,:)+inversematrix(1,3)*Estimate1(3,:);
RGBEstimate1(2,:)=inversematrix(2,1)*Estimate1(1,:)+inversematrix(2,2)*Estimate1(2,:)+inversematrix(2,3)*Estimate1(3,:);
RGBEstimate1(3,:)=inversematrix(3,1)*Estimate1(1,:)+inversematrix(3,2)*Estimate1(2,:)+inversematrix(3,3)*Estimate1(3,:);



% normalizing the illuminant 
norm=RGBEstimate1(1,:)+RGBEstimate1(2,:)+RGBEstimate1(3,:);

RGBEstimate1(1,:)=RGBEstimate1(1,:)./norm;
RGBEstimate1(2,:)=RGBEstimate1(2,:)./norm;
RGBEstimate1(3,:)=RGBEstimate1(3,:)./norm;
luminance = RGBEstimate1';

% corrected image with illuminant computed from max pooling
% corrected_imagewithmax(:,:,1)=(1/3).*(picture(:,:,1)./RGBEstimate1(1,:));
% corrected_imagewithmax(:,:,2)=(1/3).*(picture(:,:,2)./RGBEstimate1(2,:));
% corrected_imagewithmax(:,:,3)=(1/3).*(picture(:,:,3)./RGBEstimate1(3,:));


%% illuminant estimation with sum pooling    
% Estimate2(1,:)=sum(X5);
% Estimate2(2,:)=sum(Y5);
% Estimate2(3,:)=sum(Z5);

%% LMS space to RGB space

% RGBEstimate2(1,:)=inversematrix(1,1)*Estimate2(1,:)+inversematrix(1,2)*Estimate2(2,:)+inversematrix(1,3)*Estimate2(3,:);
% RGBEstimate2(2,:)=inversematrix(2,1)*Estimate2(1,:)+inversematrix(2,2)*Estimate2(2,:)+inversematrix(2,3)*Estimate2(3,:);
% RGBEstimate2(3,:)=inversematrix(3,1)*Estimate2(1,:)+inversematrix(3,2)*Estimate2(2,:)+inversematrix(3,3)*Estimate2(3,:);



% normalizing the illuminant 
% norm=RGBEstimate2(1,:)+RGBEstimate2(2,:)+RGBEstimate2(3,:);
% 
% RGBEstimate2(1,:)=RGBEstimate2(1,:)./norm;
% RGBEstimate2(2,:)=RGBEstimate2(2,:)./norm;
% RGBEstimate2(3,:)=RGBEstimate2(3,:)./norm;
% 
% % corrected image with illuminant computed from sum pooling
% corrected_imagewithmean(:,:,1)=(1/3).*(picture(:,:,1)./RGBEstimate2(1,:));
% corrected_imagewithmean(:,:,2)=(1/3).*(picture(:,:,2)./RGBEstimate2(2,:));
% corrected_imagewithmean(:,:,3)=(1/3).*(picture(:,:,3)./RGBEstimate2(3,:));
%%
% angular_error_max= angerr(RGBEstimate1,groundtruth_illuminants(i,:)); % indicated the error in RGB space
% illuminant_max=RGBEstimate1;
%%
% angular_error_mean= angerr(RGBEstimate2,groundtruth_illuminants(i,:)); % indicated the error in RGB space
% illuminant_mean=RGBEstimate2;   
% 
%  % image display
% 
%  subplot(1,3,1)
%  imshow(temporypicture)
%  title('original image','FontSize',12,'FontName','Times New Roman')
%  subplot(1,3,2)
%  imshow(uint16(corrected_imagewithmax))
%  title(['corrected with',sprintf('\n'),'max pooling', ' (angular error=', num2str(roundn(angular_error_max,-1)) '^o)'],'FontSize',12,'FontName','Times New Roman')
%  subplot(1,3,3)
%  imshow(uint16(corrected_imagewithmean))
%  title(['corrected with', sprintf('\n'),'sum pooling',' (angular error=', num2str(roundn(angular_error_mean,-1)) '^o)'],'FontSize',12,'FontName','Times New Roman')

end
 