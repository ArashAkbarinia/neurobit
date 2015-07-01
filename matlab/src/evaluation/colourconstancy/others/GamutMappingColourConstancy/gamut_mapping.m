% GAMUT_MAPPING: Apply gamut mapping to an input image.
% 
%   Depending on the parameter settings, different types of information can
%   be used to estimate the illuminant (e.g. pixels, x-edges, y-edges or
%   higher-order statistics).
%
% SYNOPSIS:
%    [white_point, output_image] = gamut_mapping(input_image, canonical_gamut, njet_type, njet_sigma, mask_im)
%    
% INPUT:
%   INPUT_DATA is a color input image of size NxMx3. The values should be
%       of type double, ranging from 0 to 255.
%
%   CANONICAL_GAMUT is the canonical gamut, learned on a representative set
%       of images taken under the same light source, that is used to
%       estimate the color of the light source. The dimensions should be
%       Px3, where P is the number of data points and 3 is the number of
%       color channels. Note that when NJET_TYPE is '1jet' or '2jet', then
%       a cell-array with canonical gamuts should be supplied.
%
%   NJET_TYPE is an array of characters that indicate what type of
%       information should be used to estimate the illuminant. Note that
%       the values of this parameter should correspond to the data that is
%       provided in CANONICAL_GAMUT. Possible values for NJET_TYPE are:
%       '0'     - Pixel-values.
%       '1x'    - Edges in the x-direction
%       '1y'    - Edges in the y-direction
%       '1grad' - Gradient-edges
%       '2xx'   - Second-order derivative edges in the xx-direction
%       '2xy'   - Second-order derivative edges in the xy-direction
%       '2yy'   - Second-order derivative edges in the yy-direction
%       '2grad' - Second-order gradient edges
%       '1jet'  - Full 1-jet (intersection of feasible sets)
%       '2jet'  - Full 2-jet (intersection of feasible sets)
%
%   NJET_SIGMA is the value that is used for preprocessing the data. 
%
%   MASK_IM is a mask of the image where zeros indicate locations in the
%       image that should not be used during the estimation. By default,
%       all pixels in the image are used.
%
% OUTPUT:
%   WHITE_POINT is the estimated (R,G,B)-values for the color of the
%       light source. Note that only chromaticity of the light source is
%       estimated.
%   OUTPUT_IMAGE is the color corrected image.
%
% NOTE:
%   This function requires the toolbox CVX, which can be found here:
%       http://www.stanford.edu/~boyd/cvx/
%
%
% LITERATURE :
%
%   A. Gijsenij, Th. Gevers, J. van de Weijer
%   "Generalized Gamut Mapping using Image Derivative Structures for Color Constancy"
%   International Journal of Computer Vision, Volume 86 (2-3), page 127-139, 2010.
%
%
%
function [white_point output_image diagonal_coefs] = gamut_mapping(input_image, canonical_gamut, njet_type, njet_sigma, mask)


% First do some parameter checking.
if (ndims(input_image) ~= 3)
    error('Input image should be of dimension MxNx3!');
    return;
end
if (strcmp(njet_type, '1jet'))
    types_to_process = {'0', '1x', '1y', '1grad'};
    if (~iscell(canonical_gamut))
        error('Intersection using 1-jet requires four canonical gamuts!');
        return;
    else
        if (numel(canonical_gamut) ~= 4)
            error('Intersection using 1-jet requires four canonical gamuts!');
            return;
        end
    end 
elseif (strcmp(njet_type, '2jet'))
    types_to_process = {'0', '1x', '1y', '1grad', '2xx', '2xy', '2yy', '2grad'};
    if (~iscell(canonical_gamut))
        error('Intersection using 1-jet requires eight canonical gamuts!');
        return;
    else
        if (numel(canonical_gamut) ~= 8)
            error('Intersection using 1-jet requires eight canonical gamuts!');
            return;
        end
    end 
else
    types_to_process{1} = njet_type;
    if ((ndims(canonical_gamut) ~= 2) | (size(canonical_gamut,2) ~= 3))
        error('Canonical gamut should be matrix of size Px3!');
        return;
    end
end
if (njet_sigma < 0)
    error('Sigma should be larger or equal to zero!');
    return;
end
if (~iscell(canonical_gamut))
    % Convert input to cell-format
    tmp = canonical_gamut;
    clear canonical_gamut;
    canonical_gamut{1} = tmp;
end

% Now loop over all njet_types to gather the data
for i=1:length(canonical_gamut)
    % Process the data by adding origin and recomputing canonical gamut
    canonical_gamut{i}(size(canonical_gamut{i},1)+1, :) = [0, 0, 0];
    [curr_out, curr_K] = compute_ch(canonical_gamut{i});
    
    % Then translate the facets of the canonical gamut into hyperplanes
    curr_hpa = tohyperplanes(curr_K, reshape(curr_out, size(curr_out, 1), 3, 1));
    curr_EE = curr_hpa(:, 1);
    curr_AA = -curr_hpa(:, 2:4);
    
    % Apply preprocessing to the input image. For now, this only involves
    % masking the saturated pixels, but this can be extended as desired (e.g.
    % segmentation has been shown to improve the gamut mapping accuracy).
    [curr_im, curr_mask] = preprocessingCG(input_image, njet_sigma, types_to_process{i});
    
    % Compute convex hull of preprocessed image.
    [curr_out2, curr_qq] = compute_ch(curr_im, types_to_process{i}, njet_sigma, ~curr_mask);
    
    % Now set all variables for the computation of the feasible set and the
    % estimation of the illuminant
    curr_N = size(curr_AA,1);
    curr_M = size(curr_out2,1);
    curr_Aq_all = [];
    for jj=1:curr_M
            curr_q_c = diag(curr_out2(jj,:)');             
            curr_Aq = [curr_AA*curr_q_c, curr_EE];
            curr_Aq_all = [curr_Aq_all; curr_Aq];
    end
    
    % Store current data in cells
    Aq_all{i} = curr_Aq_all;
end

% Now collect the Aq_all into one matrix
new_Aq_all = [];
for i=1:length(Aq_all)
    new_Aq_all = [new_Aq_all; Aq_all{i}];
end

% - Finally, estimate the illuminant using convex programming
cvx_quiet(1); 
AAA=[1 1 1];
cvx_begin
    variable x(3)
    maximize( x(1)+x(2)+x(3) )
    subject to
        new_Aq_all(:,1:3) * x <= new_Aq_all(:,4);
%         Aq_all{1}(:,1:3) * x <= Aq_all{1}(:,4);
%         Aq_all{2}(:,1:3) * x <= Aq_all{2}(:,4);
        x >= 0 ;
cvx_end

diagonal_coefs = x;

% - Store the estimated illuminant in the correct output variables
x = x.*sqrt(sum((1./x).^2));
white_point(1) = 1/x(1);
white_point(2) = 1/x(2);
white_point(3) = 1/x(3);

% - And finally color correct the input image
output_image = color_correct_image(input_image, white_point(1), white_point(2), white_point(3));





% end