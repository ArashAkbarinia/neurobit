% demo:
% paper in IEEE Trans. Image Processing, 2014:
% Kai-Fu Yang, Chao-Yi Li, and Yong-Jie Li*.
% Multifeature-based Surround Inhibition Improves Contour Detection in
% Natural Images. IEEE TIP, 2014.
%
% Contact:
% Visual Cognition and Computation Laboratory(VCCL),
% Key Laboratory for Neuroinformation of Ministry of Education,
% School of Life Science and Technology,
% University of Electronic Science and Technology of China, Chengdu, 610054, China
% Website: http://www.neuro.uestc.edu.cn/vccl/home.html
%
% Kaifu Yang <yang_kf@163.com>
% Yongjie Li <liyj@uestc.edu.cn>;
% September 2014
%=========================================================================%

function Pb = MCIContour(map)

for i = 1:size(map, 3)
  % set parameters...
  angles = 8;
  sigmas = [2.0 4.0];
  alpha =3.0;
  p = 0.9;  % the percent of edge Pixels used in hysteresis thresholding
  
  % read original image (only for gray image)
  % map = imread('302008.jpg'); % 302008.jpg  elephant_2.pgm
  % figure;imshow(map,[]);
  
  % Contour Detector
  [Res theta] = MCIoperator(map(:, :, i),sigmas,alpha,angles);
  
  % non-maxima suppression and hysteresis thresholding
  theta = (theta-1)*pi/angles;
  [Pb(:, :, i) bm] = NonmaxHysthresh(Res,theta, p);
  % figure;imshow(1-Pb,[]); % Show soft contour map after non-maxima suppression
  % figure;imshow(1-bm,[]); % Show binary contour map after hysteresis thresholding
  
  % Evaluation with P-measure...
  % only for RuG40 dataset
  % [P eFN eFP] = PMeasure(im,bm);  % im -- groundtruth map
  
  fprintf(2,'======== THE END ========\n');
end

Pb = mean(Pb, 3);
%=========================================================================%

end
