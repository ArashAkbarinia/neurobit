% IMPORTANT!!! THIS IS MERELY AN EXAMPLE SCRIPT TO DEMONSTRATE THE
% PROCEDURE TO LEARN A CANONICAL GAMUT. FOR USAGE ON REAL-WORLD IMAGES, THE
% CANONICAL GAMUT MUST BE LEARNED USING IMAGES THAT CONTAIN A
% REPRESENTATEIVE SET OF SURFACES. MOREOVER, THE IMAGES THAT ARE USED TO
% COMPUTE THE CANONICAL GAMUT SHOULD ALL BE CAPTURED UNDER (OR COLOR
% CORRECTED TO) THE SAME LIGHT SOURCE!!!
%
% This script will learn the canonical gamut, that is necessary for gamut
% mapping to estimate the color of the light source. It will compute
% canonical gamuts for the n-jet gamut mapping proposed in [1]. NOTE THAT
% THE THREE IMAGES THAT ARE USED IN THIS DEMO-SCRIPT ARE MERELY FOR
% ILLUSTRATIVE PURPOSE. For accurate performance, the canonical gamut must
% be learned using images that are a representative set of real-world
% surfaces. Also, all images that are used to learn the canonical gamut
% must be images that are illuminated by the *same* light source. Ideally,
% the canonical gamut should be learned independently of the test data (for
% instance using the 1995 hyperspectral surfaces gathered by Barnard et al.
% [2]). However, since images are often in a device-dependent RGB color
% space, what is often done is to learn the canonical gamut on a subset of
% the test data, in a fashion similar to cross-validation (i.e. divide the
% data set in N parts, learn the canonical gamut using (N-1) parts and test
% the methods on the remaining part. This process is then repeated N times
% to obtain an estimate for every image in the data set). Note that if the
% often used Grey-Ball data set [3] is used for evaluation, then care
% should be taken that all correlated images are in the same subset. This
% can be ensured by dividing the data set in 15 parts, where all images of
% one video clip are grouped into one part.
% 
% 
% References:
% [1] Gijsenij, A., Gevers, Th., & van de Weijer, J. (2010). Generalized
% Gamut Mapping using Image Derivative Structures for Color Constancy. 
% International Journal of Computer Vision, 86(2-3): 127-139.
% [2] Barnard, K., Martin, L., Funt, B., & Coath, A. (2002). A Data Set for
% Color Research. Color Research and Application, 27(3): 147-151.
% [3] Ciurea, F., & Funt, B. (2003). A Large Image Database for Color
% Constancy Research. In Proceedings of the eleventh Color Imaging
% Conference (pp. 160-164).
% 


disp(' ');
disp(' ');
disp('This example script demonstrates how the canonical gamut can be');
disp('learned. Note that that the canonical gamuts that are computed using');
disp('this script are *NOT* usable for real-world color constancy');
disp('experiments. A more extensive set of training images should be used');
disp('of which the color of the light source is known.');
disp(' ');
disp('Strike a key to continue...');
disp(' ');
disp(' ');
disp(' ');
pause;


% Specify the name of the file with references to training images. This
% file also contains the chromaticity value of the light source. Only
% images with known illuminant can be used for training the canonical
% gamut! Line i of this input file contains the image name, line i+1
% contains the color of the light source. 
textfile_with_image_names = 'training_images.lst';

% Open the file with image names
fid = fopen(textfile_with_image_names, 'r');
if(fid<0) 
    display('cannot find file');
    return;
end

% This value determines the size of the smoothing filter that is used to
% preprocess the image with. This value should be identical to the value
% that is used when applying the gamut mapping algorithm!
current_sigma = 3;

% Initialize the canonical gamuts to empty sets
all_ch_0     = [];
all_ch_1x    = [];
all_ch_1y    = [];
all_ch_1grad = [];
all_ch_2xx   = [];
all_ch_2xy   = [];
all_ch_2yy   = [];
all_ch_2grad = [];    

disp('Looping over the training images and adding them to the canonical gamut...')
while (~feof(fid))
    % First read the image name
    current_image_name = fgetl(fid);
    % Then read the color of the light source
    current_illuminant = sscanf(fgetl(fid), '%f');
    current_illuminant = current_illuminant ./ norm(current_illuminant);
    
    % Now read the image from disk
    current_image = double(imread(current_image_name));  
    
    % If the images in the training set are not captured under the same
    % illuminant, then the images should be color corrected so that they
    % appear to be taken under a white light source. 
    current_image_corrected = color_correct_image(current_image, current_illuminant); 
    
    % Apply the same preprocessing as is applied to the input images of the
    % gamut mapping algorithm. This implies that the value for sigma that
    % is used to train the canonical gamut should be identical to the value
    % for sigma that is used when applying the gamut mapping to estimate
    % the illuminant. 
    [im_0,     mask_0]     = preprocessingCG(current_image_corrected, current_sigma, '0');
    [im_1x,    mask_1x]    = preprocessingCG(current_image_corrected, current_sigma, '1x');
    [im_1y,    mask_1y]    = preprocessingCG(current_image_corrected, current_sigma, '1y');
    [im_1grad, mask_1grad] = preprocessingCG(current_image_corrected, current_sigma, '1grad');
    [im_2xx,   mask_2xx]   = preprocessingCG(current_image_corrected, current_sigma, '2xx');
    [im_2xy,   mask_2xy]   = preprocessingCG(current_image_corrected, current_sigma, '2xy');
    [im_2yy,   mask_2yy]   = preprocessingCG(current_image_corrected, current_sigma, '2yy');
    [im_2grad, mask_2grad] = preprocessingCG(current_image_corrected, current_sigma, '2grad');
    
    % Now compute the convex hull of the current image
    [current_ch_0,     K_0]     = compute_ch(im_0,     '0',     current_sigma);
    [current_ch_1x,    K_1x]    = compute_ch(im_1x,    '1x',    current_sigma);
    [current_ch_1y,    K_1y]    = compute_ch(im_1y,    '1y',    current_sigma);
    [current_ch_1grad, K_1grad] = compute_ch(im_1grad, '1grad', current_sigma);
    [current_ch_2xx,   K_2xx]   = compute_ch(im_2xx,   '2xx',   current_sigma);
    [current_ch_2xy,   K_2xy]   = compute_ch(im_2xy,   '2xy',   current_sigma);
    [current_ch_2yy,   K_2yy]   = compute_ch(im_2yy,   '2yy',   current_sigma);
    [current_ch_2grad, K_2grad] = compute_ch(im_2grad, '2grad', current_sigma);
    
    % Finally add the computed convex hull to the canonical gamuts
    all_ch_0     = [all_ch_0;     current_ch_0];
    all_ch_1x    = [all_ch_1x;    current_ch_1x];
    all_ch_1y    = [all_ch_1y;    current_ch_1y];
    all_ch_1grad = [all_ch_1grad; current_ch_1grad];
    all_ch_2xx   = [all_ch_2xx;   current_ch_2xx];
    all_ch_2xy   = [all_ch_2xy;   current_ch_2xy];
    all_ch_2yy   = [all_ch_2yy;   current_ch_2yy];
    all_ch_2grad = [all_ch_2grad; current_ch_2grad];   
end
fclose(fid);

disp('Done! Now computing the resulting canonical gamuts...');
% Finally, recompute the convex hull of all concatenated gamuts
[all_ch_0,     K_0]     = compute_ch(all_ch_0); all_ch_0 = squeeze(all_ch_0);
[all_ch_1x,    K_1x]    = compute_ch(all_ch_1x); all_ch_1x = squeeze(all_ch_1x);
[all_ch_1y,    K_1y]    = compute_ch(all_ch_1y); all_ch_1y = squeeze(all_ch_1y);
[all_ch_1grad, K_1grad] = compute_ch(all_ch_1grad); all_ch_1grad = squeeze(all_ch_1grad);
[all_ch_2xx,   K_2xx]   = compute_ch(all_ch_2xx); all_ch_2xx = squeeze(all_ch_2xx);
[all_ch_2xy,   K_2xy]   = compute_ch(all_ch_2xy); all_ch_2xy = squeeze(all_ch_2xy);
[all_ch_2yy,   K_2yy]   = compute_ch(all_ch_2yy); all_ch_2yy = squeeze(all_ch_2yy);
[all_ch_2grad, K_2grad] = compute_ch(all_ch_2grad); all_ch_2grad = squeeze(all_ch_2grad);

disp('Done! Now storing them to disk for possible later use...');
save('canonical_gamuts_for_three_uncalibrated_images.mat', 'all_ch_0', 'all_ch_1x', 'all_ch_1y', 'all_ch_1grad', 'all_ch_2xx', 'all_ch_2xy', 'all_ch_2yy', 'all_ch_2grad');

disp('Done! The gamuts are stored in the file "canonical_gamuts_for_three_uncalibrated_images.mat"');
disp(' ');
disp(' ');
disp(' ');











% end 















