function output_image = color_correct_image(input_image, light_color, light_color_G, light_color_B)
% COLOR_CORRECT_IMAGE: Support function for gamut_mapping.m
%
%   This function will color correct the input image, given the specified
%   color of the light source.
%

if ((nargin > 4) | (nargin < 2) | (nargin == 3))
    error('Input image AND color of the light source should be specified!');
    return;
end
if (nargin ==4)
    light_color(1) = light_color;
    light_color(2) = light_color_G;
    light_color(3) = light_color_B;
end

light_color = light_color ./ norm(light_color);

output_image(:,:,1) = input_image(:,:,1) ./ (light_color(1)*sqrt(3));
output_image(:,:,2) = input_image(:,:,2) ./ (light_color(2)*sqrt(3));
output_image(:,:,3) = input_image(:,:,3) ./ (light_color(3)*sqrt(3));




