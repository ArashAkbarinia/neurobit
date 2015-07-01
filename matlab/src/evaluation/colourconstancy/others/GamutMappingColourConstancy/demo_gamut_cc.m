
% Read the canonical gamuts. These canonical gamut are merely provided for
% demonstration purposes and should not be used for real-world color
% constancy. For every purpose, it is best to obtain the canonical gamut
% that best suits the application at hand.
load('example_canonical_gamuts.mat');


% Read the input image
disp('Applying Gamut Mapping Color Constancy on first image: Building.');
current_image = double(imread('./example_images/building.jpg'));
figure(1); subplot(2,2,1); imshow(uint8(current_image));
title('Input image: Building');

% This call will apply gamut mapping using x-derivatives to the input image.
disp('Using edges in the x-direction...'); clear curr_canonical;
curr_canonical = example_canonical_gamut_1x;
njet_type = '1x';
[current_white current_out] = gamut_mapping(current_image, curr_canonical, njet_type, 3);
figure(1); subplot(2,2,2);imshow(uint8(current_out)); title('Gamut (f_x)');
disp(['- Estimated color of the light source: [' num2str(round(100*current_white(1))./100) ', ' num2str(round(100*current_white(2))./100) ', ' num2str(round(100*current_white(3))./100) ']']);

% This call will apply gamut mapping using y-derivatives to the input image.
disp('Using edges in the y-direction...'); clear curr_canonical;
curr_canonical = example_canonical_gamut_1y;
njet_type = '1y';
[current_white current_out] = gamut_mapping(current_image, curr_canonical, njet_type, 3);
figure(1); subplot(2,2,3);imshow(uint8(current_out)); title('Gamut (f_y)');
disp(['- Estimated color of the light source: [' num2str(round(100*current_white(1))./100) ', ' num2str(round(100*current_white(2))./100) ', ' num2str(round(100*current_white(3))./100) ']']);

% This call will apply gamut mapping using 1nd-order gradient to the input image.
disp('Using first-order gradient...'); clear curr_canonical;
curr_canonical = example_canonical_gamut_1grad;
njet_type = '1grad';
[current_white current_out] = gamut_mapping(current_image, curr_canonical, njet_type, 3);
figure(1); subplot(2,2,4);imshow(uint8(current_out)); title('Gamut (\nabla f)');
disp(['- Estimated color of the light source: [' num2str(round(100*current_white(1))./100) ', ' num2str(round(100*current_white(2))./100) ', ' num2str(round(100*current_white(3))./100) ']']);
disp(' ');
disp(' ');
disp('Press a key to continue with the next image...');
disp(' ');
pause;

% Read the next input image
disp(' ');
disp('Applying Gamut Mapping Color Constancy on second image: Cow.');
current_image = double(imread('./example_images/cow.jpg'));
figure(2); subplot(2,2,1); imshow(uint8(current_image));
title('Input image: Cow');

% This call will apply gamut mapping using 2nd-order derivatives in the x-direction to the input image.
disp('Using 2nd-order derivatives in the xx-direction...'); clear curr_canonical;
curr_canonical = example_canonical_gamut_2xx;
njet_type = '2xx';
[current_white current_out] = gamut_mapping(current_image, curr_canonical, njet_type, 3);
figure(2); subplot(2,2,2); imshow(uint8(current_out)); title('Gamut (f_{yy})');
disp(['- Estimated color of the light source: [' num2str(round(100*current_white(1))./100) ', ' num2str(round(100*current_white(2))./100) ', ' num2str(round(100*current_white(3))./100) ']']);

% This call will apply gamut mapping using 2nd-order derivatives in the x/y-direction to the input image.
disp('Using 2nd-order derivatives in the xy-direction...'); clear curr_canonical;
curr_canonical = example_canonical_gamut_2xy;
njet_type = '2xy';
[current_white current_out] = gamut_mapping(current_image, curr_canonical, njet_type, 3);
figure(2); subplot(2,2,3); imshow(uint8(current_out)); title('Gamut (f_{yy})');
disp(['- Estimated color of the light source: [' num2str(round(100*current_white(1))./100) ', ' num2str(round(100*current_white(2))./100) ', ' num2str(round(100*current_white(3))./100) ']']);

% This call will apply gamut mapping using 2nd-order derivatives in the y-direction to the input image.
disp('Using 2nd-order derivatives in the yy-direction...'); clear curr_canonical;
curr_canonical = example_canonical_gamut_2yy;
njet_type = '2yy';
[current_white current_out] = gamut_mapping(current_image, curr_canonical, njet_type, 3);
figure(2); subplot(2,2,4); imshow(uint8(current_out)); title('Gamut (f_{yy})');
disp(['- Estimated color of the light source: [' num2str(round(100*current_white(1))./100) ', ' num2str(round(100*current_white(2))./100) ', ' num2str(round(100*current_white(3))./100) ']']);
disp(' ');
disp(' ');
disp('Press a key to continue with the next image...');
disp(' ');
pause;


% Read the next input image
disp(' ');
disp('Applying Gamut Mapping Color Constancy on third image: Dog.');
current_image = double(imread('./example_images/dog.jpg'));
figure(3); subplot(2,2,1); imshow(uint8(current_image));
title('Input image: Dog');

% This call will apply gamut mapping using pixel-values the input image.
disp('Using pixel values...'); clear curr_canonical;
curr_canonical = example_canonical_gamut_0;
njet_type = '0';
[current_white current_out] = gamut_mapping(current_image, curr_canonical, njet_type, 3);
figure(3); subplot(2,2,2); imshow(uint8(current_out)); title('Gamut (f)');
disp(['- Estimated color of the light source: [' num2str(round(100*current_white(1))./100) ', ' num2str(round(100*current_white(2))./100) ', ' num2str(round(100*current_white(3))./100) ']']);

% This call will apply gamut mapping using 1st-order gradient of the input image.
disp('Using 1st-order gradient...'); clear curr_canonical;
curr_canonical = example_canonical_gamut_1grad;
njet_type = '1grad';
[current_white current_out] = gamut_mapping(current_image, curr_canonical, njet_type, 3);
figure(3); subplot(2,2,3); imshow(uint8(current_out)); title('Gamut (\nabla f)');
disp(['- Estimated color of the light source: [' num2str(round(100*current_white(1))./100) ', ' num2str(round(100*current_white(2))./100) ', ' num2str(round(100*current_white(3))./100) ']']);

% This call will apply gamut mapping using 2nd-order gradient of the input image.
disp('Using 2nd-order gradient...'); clear curr_canonical;
curr_canonical = example_canonical_gamut_2grad;
njet_type = '2grad';
[current_white current_out] = gamut_mapping(current_image, curr_canonical, njet_type, 3);
figure(3); subplot(2,2,4); imshow(uint8(current_out)); title('Gamut (\nabla\nabla f)');
disp(['- Estimated color of the light source: [' num2str(round(100*current_white(1))./100) ', ' num2str(round(100*current_white(2))./100) ', ' num2str(round(100*current_white(3))./100) ']']);
disp(' ');
disp(' ');
disp('Press a key to continue with the next image...');
disp(' ');
pause;




% Read the next input image
disp(' ');
disp('Applying Gamut Mapping Color Constancy on fourth image: Car.');
current_image = double(imread('./example_images/car.jpg'));
figure(4); subplot(2,2,1); imshow(uint8(current_image));
title('Input image: Car');

% This call will apply the gamut mapping using intersection of the feasible
% sets of the full 1-jet.
disp('Using 1-jet (Intersection)...'); clear curr_canonical;
curr_canonical{1} = example_canonical_gamut_0;
curr_canonical{2} = example_canonical_gamut_1x;
curr_canonical{3} = example_canonical_gamut_1y;
curr_canonical{4} = example_canonical_gamut_1grad;
njet_type = '1jet';
[current_white current_out] = gamut_mapping(current_image, curr_canonical, njet_type, 3);
figure(4); subplot(2,2,2); imshow(uint8(current_out)); title('Gamut (Intersection of 1-jet)');
disp(['- Estimated color of the light source: [' num2str(round(100*current_white(1))./100) ', ' num2str(round(100*current_white(2))./100) ', ' num2str(round(100*current_white(3))./100) ']']);

% This call will apply the gamut mapping using the union of the feasible
% sets of the full 1-jet. Since the gamut mapping implementation selects
% the mapping from the feasible set with the largest trace (i.e. the
% mapping that results in the most colorful image), the union of all
% feasible sets can be found by selecting the largest trace of the separate
% results.
disp('Using 1-jet (Union)...'); clear curr_canonical;
njet_type = '0'; curr_canonical = example_canonical_gamut_0;
[current_white_0 current_out_0 diagonal_0] = gamut_mapping(current_image, curr_canonical, njet_type, 3);
njet_type = '1x'; curr_canonical = example_canonical_gamut_1x;
[current_white_1x current_out_1x diagonal_1x] = gamut_mapping(current_image, curr_canonical, njet_type, 3);
njet_type = '1y'; curr_canonical = example_canonical_gamut_1y;
[current_white_1y current_out_1y diagonal_1y] = gamut_mapping(current_image, curr_canonical, njet_type, 3);
njet_type = '1grad'; curr_canonical = example_canonical_gamut_1grad;
[current_white_1grad current_out_1grad diagonal_1grad] = gamut_mapping(current_image, curr_canonical, njet_type, 3);
if (sum(diagonal_0) > max(sum(diagonal_1x), max(sum(diagonal_1y), sum(diagonal_1grad))))
    current_white = current_white_0;
    current_out = current_out_0;
elseif (sum(diagonal_1x) > max(sum(diagonal_0), max(sum(diagonal_1y), sum(diagonal_1grad))))
    current_white = current_white_1x;
    current_out = current_out_1x;
elseif (sum(diagonal_1y) > max(sum(diagonal_1x), max(sum(diagonal_0), sum(diagonal_1grad))))
    current_white = current_white_1y;
    current_out = current_out_1y;
elseif (sum(diagonal_1grad) > max(sum(diagonal_1x), max(sum(diagonal_1y), sum(diagonal_0))))
    current_white = current_white_1grad;
    current_out = current_out_1grad;
end
figure(4); subplot(2,2,3); imshow(uint8(current_out)); title('Gamut (Union of 1-jet)');
disp(['- Estimated color of the light source: [' num2str(round(100*current_white(1))./100) ', ' num2str(round(100*current_white(2))./100) ', ' num2str(round(100*current_white(3))./100) ']']);

% This call will apply the gamut mapping using intersection of the feasible
% sets of the full 2-jet.
disp('Using 2-jet (Intersection)...'); clear curr_canonical;
curr_canonical{1} = example_canonical_gamut_0;
curr_canonical{2} = example_canonical_gamut_1x;
curr_canonical{3} = example_canonical_gamut_1y;
curr_canonical{4} = example_canonical_gamut_1grad;
curr_canonical{5} = example_canonical_gamut_2xx;
curr_canonical{6} = example_canonical_gamut_2xy;
curr_canonical{7} = example_canonical_gamut_2yy;
curr_canonical{8} = example_canonical_gamut_2grad;
njet_type = '2jet';
[current_white current_out] = gamut_mapping(current_image, curr_canonical, njet_type, 3);
figure(4); subplot(2,2,4); imshow(uint8(current_out)); title('Gamut (Intersection of 2-jet)');
disp(['- Estimated color of the light source: [' num2str(round(100*current_white(1))./100) ', ' num2str(round(100*current_white(2))./100) ', ' num2str(round(100*current_white(3))./100) ']']);
disp(' ');
disp(' ');
disp('Done!');
disp(' ');




























% % This call will apply the gamut mapping using 2nd-order gradient of the image
% curr_canonical = example_canonical_gamut_0;
% njet_type = '0';
% [current_white current_out tmp] = gamut_mapping(current_image, curr_canonical, njet_type, 3);
% disp(['0: ' num2str(tmp(1)) '+' num2str(tmp(2)) '+' num2str(tmp(3)) '=' num2str(sum(tmp))]);
% 
% 
% % This call will apply the gamut mapping using 2nd-order gradient of the image
% curr_canonical = example_canonical_gamut_1x;
% njet_type = '1x';
% [current_white current_out tmp] = gamut_mapping(current_image, curr_canonical, njet_type, 3);
% disp(['1x: ' num2str(tmp(1)) '+' num2str(tmp(2)) '+' num2str(tmp(3)) '=' num2str(sum(tmp))]);
% 
% % This call will apply the gamut mapping using 2nd-order gradient of the image
% curr_canonical = example_canonical_gamut_1y;
% njet_type = '1y';
% [current_white current_out tmp] = gamut_mapping(current_image, curr_canonical, njet_type, 3);
% disp(['1y: ' num2str(tmp(1)) '+' num2str(tmp(2)) '+' num2str(tmp(3)) '=' num2str(sum(tmp))]);
% 
% % This call will apply the gamut mapping using 2nd-order gradient of the image
% curr_canonical = example_canonical_gamut_1grad;
% njet_type = '1grad';
% [current_white current_out tmp] = gamut_mapping(current_image, curr_canonical, njet_type, 3);
% disp(['1grad: ' num2str(tmp(1)) '+' num2str(tmp(2)) '+' num2str(tmp(3)) '=' num2str(sum(tmp))]);
% 
% % This call will apply the gamut mapping using 2nd-order gradient of the image
% curr_canonical = example_canonical_gamut_2xx;
% njet_type = '2xx';
% [current_white current_out tmp] = gamut_mapping(current_image, curr_canonical, njet_type, 3);
% disp(['2xx: ' num2str(tmp(1)) '+' num2str(tmp(2)) '+' num2str(tmp(3)) '=' num2str(sum(tmp))]);
% 
% % This call will apply the gamut mapping using 2nd-order gradient of the image
% curr_canonical = example_canonical_gamut_2xy;
% njet_type = '2xy';
% [current_white current_out tmp] = gamut_mapping(current_image, curr_canonical, njet_type, 3);
% disp(['2xy: ' num2str(tmp(1)) '+' num2str(tmp(2)) '+' num2str(tmp(3)) '=' num2str(sum(tmp))]);
% 
% % This call will apply the gamut mapping using 2nd-order gradient of the image
% curr_canonical = example_canonical_gamut_2yy;
% njet_type = '2yy';
% [current_white current_out tmp] = gamut_mapping(current_image, curr_canonical, njet_type, 3);
% disp(['2yy: ' num2str(tmp(1)) '+' num2str(tmp(2)) '+' num2str(tmp(3)) '=' num2str(sum(tmp))]);
% 
% 
% % This call will apply the gamut mapping using 2nd-order gradient of the image
% curr_canonical = example_canonical_gamut_2grad;
% njet_type = '2grad';
% [current_white current_out tmp] = gamut_mapping(current_image, curr_canonical, njet_type, 3);
% disp(['2grad: ' num2str(tmp(1)) '+' num2str(tmp(2)) '+' num2str(tmp(3)) '=' num2str(sum(tmp))]);
% 



