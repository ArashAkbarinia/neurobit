function lsYFrontiers = OrganiseExperimentFrontiers(FilePath, plotme, XYZ2lsYChoise)

if nargin < 2
  plotme = 0;
end

if nargin < 3
  XYZ2lsYChoise = 'evenly_ditributed_stds';
end

RawDataMat = load(FilePath);
saturated_chrom_Lab = RawDataMat.saturated_chrom_Lab;
saturated_achrom_Lab = RawDataMat.saturated_achrom_Lab;
unsaturated_chrom_Lab = RawDataMat.unsaturated_chrom_Lab;
unsaturated_achrom_Lab = RawDataMat.unsaturated_achrom_Lab;

% reference white used in the experiments
WhiteReference = RawDataMat.WhiteReference;

lsYFrontiers = struct();
borders = {};

% colour objects
lsYFrontiers.black  = ColourCategory('black');
lsYFrontiers.blue   = ColourCategory('blue');
lsYFrontiers.brown  = ColourCategory('brown');
lsYFrontiers.green  = ColourCategory('green');
lsYFrontiers.grey   = ColourCategory('grey');
lsYFrontiers.orange = ColourCategory('orange');
lsYFrontiers.pink   = ColourCategory('pink');
lsYFrontiers.purple = ColourCategory('purple');
lsYFrontiers.red    = ColourCategory('red');
lsYFrontiers.yellow = ColourCategory('yellow');
lsYFrontiers.white  = ColourCategory('white');

%% saturated frontiers (coloured background)

lsY_36_G_B_c   = XYZ2lsY(Lab2XYZ(saturated_chrom_Lab(:, 1:3),   WhiteReference), XYZ2lsYChoise);
lsY_36_B_Pp_c  = XYZ2lsY(Lab2XYZ(saturated_chrom_Lab(:, 4:6),   WhiteReference), XYZ2lsYChoise);
lsY_36_Pp_Pk_c = XYZ2lsY(Lab2XYZ(saturated_chrom_Lab(:, 7:9),   WhiteReference), XYZ2lsYChoise);
lsY_36_Pk_R_c  = XYZ2lsY(Lab2XYZ(saturated_chrom_Lab(:, 10:12), WhiteReference), XYZ2lsYChoise);
lsY_36_R_Br_c  = XYZ2lsY(Lab2XYZ(saturated_chrom_Lab(:, 13:15), WhiteReference), XYZ2lsYChoise);
lsY_36_Br_G_c  = XYZ2lsY(Lab2XYZ(saturated_chrom_Lab(:, 16:18), WhiteReference), XYZ2lsYChoise);

lsY_58_G_B_c   = XYZ2lsY(Lab2XYZ(saturated_chrom_Lab(:, 19:21), WhiteReference), XYZ2lsYChoise);
lsY_58_B_Pp_c  = XYZ2lsY(Lab2XYZ(saturated_chrom_Lab(:, 22:24), WhiteReference), XYZ2lsYChoise);
lsY_58_Pp_Pk_c = XYZ2lsY(Lab2XYZ(saturated_chrom_Lab(:, 25:27), WhiteReference), XYZ2lsYChoise);
lsY_58_Pk_R_c  = XYZ2lsY(Lab2XYZ(saturated_chrom_Lab(:, 28:30), WhiteReference), XYZ2lsYChoise);
lsY_58_R_O_c   = XYZ2lsY(Lab2XYZ(saturated_chrom_Lab(:, 31:33), WhiteReference), XYZ2lsYChoise);
lsY_58_O_Y_c   = XYZ2lsY(Lab2XYZ(saturated_chrom_Lab(:, 34:36), WhiteReference), XYZ2lsYChoise);
lsY_58_Y_G_c   = XYZ2lsY(Lab2XYZ(saturated_chrom_Lab(:, 37:39), WhiteReference), XYZ2lsYChoise);

lsY_81_G_B_c   = XYZ2lsY(Lab2XYZ(saturated_chrom_Lab(:, 40:42), WhiteReference), XYZ2lsYChoise);
lsY_81_B_Pp_c  = XYZ2lsY(Lab2XYZ(saturated_chrom_Lab(:, 43:45), WhiteReference), XYZ2lsYChoise);
lsY_81_Pp_Pk_c = XYZ2lsY(Lab2XYZ(saturated_chrom_Lab(:, 46:48), WhiteReference), XYZ2lsYChoise);
lsY_81_Pk_O_c  = XYZ2lsY(Lab2XYZ(saturated_chrom_Lab(:, 49:51), WhiteReference), XYZ2lsYChoise);
lsY_81_O_Y_c   = XYZ2lsY(Lab2XYZ(saturated_chrom_Lab(:, 52:54), WhiteReference), XYZ2lsYChoise);
lsY_81_Y_G_c   = XYZ2lsY(Lab2XYZ(saturated_chrom_Lab(:, 55:57), WhiteReference), XYZ2lsYChoise);

%% saturated frontiers (achromatic background)

lsY_36_G_B_a   = XYZ2lsY(Lab2XYZ(saturated_achrom_Lab(:, 1:3),   WhiteReference), XYZ2lsYChoise);
lsY_36_B_Pp_a  = XYZ2lsY(Lab2XYZ(saturated_achrom_Lab(:, 4:6),   WhiteReference), XYZ2lsYChoise);
lsY_36_Pp_Pk_a = XYZ2lsY(Lab2XYZ(saturated_achrom_Lab(:, 7:9),   WhiteReference), XYZ2lsYChoise);
lsY_36_Pk_R_a  = XYZ2lsY(Lab2XYZ(saturated_achrom_Lab(:, 10:12), WhiteReference), XYZ2lsYChoise);
lsY_36_R_Br_a  = XYZ2lsY(Lab2XYZ(saturated_achrom_Lab(:, 13:15), WhiteReference), XYZ2lsYChoise);
lsY_36_Br_G_a  = XYZ2lsY(Lab2XYZ(saturated_achrom_Lab(:, 16:18), WhiteReference), XYZ2lsYChoise);

lsY_58_G_B_a   = XYZ2lsY(Lab2XYZ(saturated_achrom_Lab(:, 19:21), WhiteReference), XYZ2lsYChoise);
lsY_58_B_Pp_a  = XYZ2lsY(Lab2XYZ(saturated_achrom_Lab(:, 22:24), WhiteReference), XYZ2lsYChoise);
lsY_58_Pp_Pk_a = XYZ2lsY(Lab2XYZ(saturated_achrom_Lab(:, 25:27), WhiteReference), XYZ2lsYChoise);
lsY_58_Pk_R_a  = XYZ2lsY(Lab2XYZ(saturated_achrom_Lab(:, 28:30), WhiteReference), XYZ2lsYChoise);
lsY_58_R_O_a   = XYZ2lsY(Lab2XYZ(saturated_achrom_Lab(:, 31:33), WhiteReference), XYZ2lsYChoise);
lsY_58_O_Y_a   = XYZ2lsY(Lab2XYZ(saturated_achrom_Lab(:, 34:36), WhiteReference), XYZ2lsYChoise);
lsY_58_Y_G_a   = XYZ2lsY(Lab2XYZ(saturated_achrom_Lab(:, 37:39), WhiteReference), XYZ2lsYChoise);

lsY_81_G_B_a   = XYZ2lsY(Lab2XYZ(saturated_achrom_Lab(:, 40:42), WhiteReference), XYZ2lsYChoise);
lsY_81_B_Pp_a  = XYZ2lsY(Lab2XYZ(saturated_achrom_Lab(:, 43:45), WhiteReference), XYZ2lsYChoise);
lsY_81_Pp_Pk_a = XYZ2lsY(Lab2XYZ(saturated_achrom_Lab(:, 46:48), WhiteReference), XYZ2lsYChoise);
lsY_81_Pk_O_a  = XYZ2lsY(Lab2XYZ(saturated_achrom_Lab(:, 49:51), WhiteReference), XYZ2lsYChoise);
lsY_81_O_Y_a   = XYZ2lsY(Lab2XYZ(saturated_achrom_Lab(:, 52:54), WhiteReference), XYZ2lsYChoise);
lsY_81_Y_G_a   = XYZ2lsY(Lab2XYZ(saturated_achrom_Lab(:, 55:57), WhiteReference), XYZ2lsYChoise);

%% unsaturated frontiers (chromatic background)

Lab_36_W_G_c  = unsaturated_chrom_Lab(:, 1:3);
Lab_36_W_B_c  = unsaturated_chrom_Lab(:, 4:6);
Lab_36_W_Pp_c = unsaturated_chrom_Lab(:, 7:9);
Lab_36_W_Pk_c = unsaturated_chrom_Lab(:, 10:12);
Lab_36_W_R_c  = unsaturated_chrom_Lab(:, 13:15);
Lab_36_W_Br_c = unsaturated_chrom_Lab(:, 16:18);

Lab_36_W_G_c(all(Lab_36_W_G_c' == 0), :) = [];
Lab_36_W_B_c(all(Lab_36_W_B_c' == 0), :) = [];
Lab_36_W_Pp_c(all(Lab_36_W_Pp_c' == 0), :) = [];
Lab_36_W_Pk_c(all(Lab_36_W_Pk_c' == 0), :) = [];
Lab_36_W_R_c(all(Lab_36_W_R_c' == 0), :) = [];
Lab_36_W_Br_c(all(Lab_36_W_Br_c' == 0), :) = [];

Lab_58_W_G_c  = unsaturated_chrom_Lab(:, 19:21);
Lab_58_W_B_c  = unsaturated_chrom_Lab(:, 22:24);
Lab_58_W_Pp_c = unsaturated_chrom_Lab(:, 25:27);
Lab_58_W_Pk_c = unsaturated_chrom_Lab(:, 28:30);
Lab_58_W_R_c  = unsaturated_chrom_Lab(:, 31:33);
Lab_58_W_O_c  = unsaturated_chrom_Lab(:, 34:36);
Lab_58_W_Y_c  = unsaturated_chrom_Lab(:, 37:39);

Lab_58_W_G_c(all(Lab_58_W_G_c' == 0), :) = [];
Lab_58_W_B_c(all(Lab_58_W_B_c' == 0), :) = [];
Lab_58_W_Pp_c(all(Lab_58_W_Pp_c' == 0), :) = [];
Lab_58_W_Pk_c(all(Lab_58_W_Pk_c' == 0), :) = [];
Lab_58_W_R_c(all(Lab_58_W_R_c' == 0), :) = [];
Lab_58_W_O_c(all(Lab_58_W_O_c' == 0), :) = [];
Lab_58_W_Y_c(all(Lab_58_W_Y_c' == 0), :) = [];

Lab_81_W_G_c  = unsaturated_chrom_Lab(:, 40:42);
Lab_81_W_B_c  = unsaturated_chrom_Lab(:, 43:45);
Lab_81_W_Pp_c = unsaturated_chrom_Lab(:, 46:48);
Lab_81_W_Pk_c = unsaturated_chrom_Lab(:, 49:51);
Lab_81_W_O_c  = unsaturated_chrom_Lab(:, 52:54);
Lab_81_W_Y_c  = unsaturated_chrom_Lab(:, 55:57);

Lab_81_W_G_c(all(Lab_81_W_G_c' == 0), :) = [];
Lab_81_W_B_c(all(Lab_81_W_B_c' == 0), :) = [];
Lab_81_W_Pp_c(all(Lab_81_W_Pp_c' == 0), :) = [];
Lab_81_W_Pk_c(all(Lab_81_W_Pk_c' == 0), :) = [];
Lab_81_W_O_c(all(Lab_81_W_O_c' == 0), :) = [];
Lab_81_W_Y_c(all(Lab_81_W_Y_c' == 0), :) = [];

lsY_36_W_G_c  = XYZ2lsY(Lab2XYZ(Lab_36_W_G_c,  WhiteReference), XYZ2lsYChoise);
lsY_36_W_B_c  = XYZ2lsY(Lab2XYZ(Lab_36_W_B_c,  WhiteReference), XYZ2lsYChoise);
lsY_36_W_Pp_c = XYZ2lsY(Lab2XYZ(Lab_36_W_Pp_c, WhiteReference), XYZ2lsYChoise);
lsY_36_W_Pk_c = XYZ2lsY(Lab2XYZ(Lab_36_W_Pk_c, WhiteReference), XYZ2lsYChoise);
lsY_36_W_R_c  = XYZ2lsY(Lab2XYZ(Lab_36_W_R_c,  WhiteReference), XYZ2lsYChoise);
lsY_36_W_Br_c = XYZ2lsY(Lab2XYZ(Lab_36_W_Br_c, WhiteReference), XYZ2lsYChoise);

lsY_58_W_G_c  = XYZ2lsY(Lab2XYZ(Lab_58_W_G_c,  WhiteReference), XYZ2lsYChoise);
lsY_58_W_B_c  = XYZ2lsY(Lab2XYZ(Lab_58_W_B_c,  WhiteReference), XYZ2lsYChoise);
lsY_58_W_Pp_c = XYZ2lsY(Lab2XYZ(Lab_58_W_Pp_c, WhiteReference), XYZ2lsYChoise);
lsY_58_W_Pk_c = XYZ2lsY(Lab2XYZ(Lab_58_W_Pk_c, WhiteReference), XYZ2lsYChoise);
lsY_58_W_R_c  = XYZ2lsY(Lab2XYZ(Lab_58_W_R_c,  WhiteReference), XYZ2lsYChoise);
lsY_58_W_O_c  = XYZ2lsY(Lab2XYZ(Lab_58_W_O_c,  WhiteReference), XYZ2lsYChoise);
lsY_58_W_Y_c  = XYZ2lsY(Lab2XYZ(Lab_58_W_Y_c,  WhiteReference), XYZ2lsYChoise);

lsY_81_W_G_c  = XYZ2lsY(Lab2XYZ(Lab_81_W_G_c,  WhiteReference), XYZ2lsYChoise);
lsY_81_W_B_c  = XYZ2lsY(Lab2XYZ(Lab_81_W_B_c,  WhiteReference), XYZ2lsYChoise);
lsY_81_W_Pp_c = XYZ2lsY(Lab2XYZ(Lab_81_W_Pp_c, WhiteReference), XYZ2lsYChoise);
lsY_81_W_Pk_c = XYZ2lsY(Lab2XYZ(Lab_81_W_Pk_c, WhiteReference), XYZ2lsYChoise);
lsY_81_W_O_c  = XYZ2lsY(Lab2XYZ(Lab_81_W_O_c,  WhiteReference), XYZ2lsYChoise);
lsY_81_W_Y_c  = XYZ2lsY(Lab2XYZ(Lab_81_W_Y_c,  WhiteReference), XYZ2lsYChoise);

%% unsaturated frontiers (achromatic background)

Lab_36_W_G_a  = unsaturated_achrom_Lab(:, 1:3);
Lab_36_W_B_a  = unsaturated_achrom_Lab(:, 4:6);
Lab_36_W_Pp_a = unsaturated_achrom_Lab(:, 7:9);
Lab_36_W_Pk_a = unsaturated_achrom_Lab(:, 10:12);
Lab_36_W_R_a  = unsaturated_achrom_Lab(:, 13:15);
Lab_36_W_Br_a = unsaturated_achrom_Lab(:, 16:18);

Lab_36_W_G_a(all(Lab_36_W_G_a' == 0), :) = [];
Lab_36_W_B_a(all(Lab_36_W_B_a' == 0), :) = [];
Lab_36_W_Pp_a(all(Lab_36_W_Pp_a' == 0), :) = [];
Lab_36_W_Pk_a(all(Lab_36_W_Pk_a' == 0), :) = [];
Lab_36_W_R_a(all(Lab_36_W_R_a' == 0), :) = [];
Lab_36_W_Br_a(all(Lab_36_W_Br_a' == 0), :) = [];

Lab_58_W_G_a  = unsaturated_achrom_Lab(:, 19:21);
Lab_58_W_B_a  = unsaturated_achrom_Lab(:, 22:24);
Lab_58_W_Pp_a = unsaturated_achrom_Lab(:, 25:27);
Lab_58_W_Pk_a = unsaturated_achrom_Lab(:, 28:30);
Lab_58_W_R_a  = unsaturated_achrom_Lab(:, 31:33);
Lab_58_W_O_a  = unsaturated_achrom_Lab(:, 34:36);
Lab_58_W_Y_a  = unsaturated_achrom_Lab(:, 37:39);

Lab_58_W_G_a(all(Lab_58_W_G_a' == 0), :) = [];
Lab_58_W_B_a(all(Lab_58_W_B_a' == 0), :) = [];
Lab_58_W_Pp_a(all(Lab_58_W_Pp_a' == 0), :) = [];
Lab_58_W_Pk_a(all(Lab_58_W_Pk_a' == 0), :) = [];
Lab_58_W_R_a(all(Lab_58_W_R_a' == 0), :) = [];
Lab_58_W_O_a(all(Lab_58_W_O_a' == 0), :) = [];
Lab_58_W_Y_a(all(Lab_58_W_Y_a' == 0), :) = [];

Lab_81_W_G_a  = unsaturated_achrom_Lab(:, 40:42);
Lab_81_W_B_a  = unsaturated_achrom_Lab(:, 43:45);
Lab_81_W_Pp_a = unsaturated_achrom_Lab(:, 46:48);
Lab_81_W_Pk_a = unsaturated_achrom_Lab(:, 49:51);
Lab_81_W_O_a  = unsaturated_achrom_Lab(:, 52:54);
Lab_81_W_Y_a  = unsaturated_achrom_Lab(:, 55:57);

Lab_81_W_G_a(all(Lab_81_W_G_a' == 0), :) = [];
Lab_81_W_B_a(all(Lab_81_W_B_a' == 0), :) = [];
Lab_81_W_Pp_a(all(Lab_81_W_Pp_a' == 0), :) = [];
Lab_81_W_Pk_a(all(Lab_81_W_Pk_a' == 0), :) = [];
Lab_81_W_O_a(all(Lab_81_W_O_a' == 0), :) = [];
Lab_81_W_Y_a(all(Lab_81_W_Y_a' == 0), :) = [];

lsY_36_W_G_a  = XYZ2lsY(Lab2XYZ(Lab_36_W_G_a,  WhiteReference), XYZ2lsYChoise);
lsY_36_W_B_a  = XYZ2lsY(Lab2XYZ(Lab_36_W_B_a,  WhiteReference), XYZ2lsYChoise);
lsY_36_W_Pp_a = XYZ2lsY(Lab2XYZ(Lab_36_W_Pp_a, WhiteReference), XYZ2lsYChoise);
lsY_36_W_Pk_a = XYZ2lsY(Lab2XYZ(Lab_36_W_Pk_a, WhiteReference), XYZ2lsYChoise);
lsY_36_W_R_a  = XYZ2lsY(Lab2XYZ(Lab_36_W_R_a,  WhiteReference), XYZ2lsYChoise);
lsY_36_W_Br_a = XYZ2lsY(Lab2XYZ(Lab_36_W_Br_a, WhiteReference), XYZ2lsYChoise);

lsY_58_W_G_a  = XYZ2lsY(Lab2XYZ(Lab_58_W_G_a,  WhiteReference), XYZ2lsYChoise);
lsY_58_W_B_a  = XYZ2lsY(Lab2XYZ(Lab_58_W_B_a,  WhiteReference), XYZ2lsYChoise);
lsY_58_W_Pp_a = XYZ2lsY(Lab2XYZ(Lab_58_W_Pp_a, WhiteReference), XYZ2lsYChoise);
lsY_58_W_Pk_a = XYZ2lsY(Lab2XYZ(Lab_58_W_Pk_a, WhiteReference), XYZ2lsYChoise);
lsY_58_W_R_a  = XYZ2lsY(Lab2XYZ(Lab_58_W_R_a,  WhiteReference), XYZ2lsYChoise);
lsY_58_W_O_a  = XYZ2lsY(Lab2XYZ(Lab_58_W_O_a,  WhiteReference), XYZ2lsYChoise);
lsY_58_W_Y_a  = XYZ2lsY(Lab2XYZ(Lab_58_W_Y_a,  WhiteReference), XYZ2lsYChoise);

lsY_81_W_G_a  = XYZ2lsY(Lab2XYZ(Lab_81_W_G_a,  WhiteReference), XYZ2lsYChoise);
lsY_81_W_B_a  = XYZ2lsY(Lab2XYZ(Lab_81_W_B_a,  WhiteReference), XYZ2lsYChoise);
lsY_81_W_Pp_a = XYZ2lsY(Lab2XYZ(Lab_81_W_Pp_a, WhiteReference), XYZ2lsYChoise);
lsY_81_W_Pk_a = XYZ2lsY(Lab2XYZ(Lab_81_W_Pk_a, WhiteReference), XYZ2lsYChoise);
lsY_81_W_O_a  = XYZ2lsY(Lab2XYZ(Lab_81_W_O_a,  WhiteReference), XYZ2lsYChoise);
lsY_81_W_Y_a  = XYZ2lsY(Lab2XYZ(Lab_81_W_Y_a,  WhiteReference), XYZ2lsYChoise);

%% all backgrounds combined

lsY_36_G_B   = [lsY_36_G_B_c;   lsY_36_G_B_a];
lsY_36_B_Pp  = [lsY_36_B_Pp_c;  lsY_36_B_Pp_a];
lsY_36_Pp_Pk = [lsY_36_Pp_Pk_c; lsY_36_Pp_Pk_a];
lsY_36_Pk_R  = [lsY_36_Pk_R_c;  lsY_36_Pk_R_a];
lsY_36_R_Br  = [lsY_36_R_Br_c;  lsY_36_R_Br_a];
lsY_36_Br_G  = [lsY_36_Br_G_c;  lsY_36_Br_G_a];

lsY_58_G_B   = [lsY_58_G_B_c;   lsY_58_G_B_a];
lsY_58_B_Pp  = [lsY_58_B_Pp_c;  lsY_58_B_Pp_a];
lsY_58_Pp_Pk = [lsY_58_Pp_Pk_c; lsY_58_Pp_Pk_a];
lsY_58_Pk_R  = [lsY_58_Pk_R_c;  lsY_58_Pk_R_a];
lsY_58_R_O   = [lsY_58_R_O_c;   lsY_58_R_O_a];
lsY_58_O_Y   = [lsY_58_O_Y_c;   lsY_58_O_Y_a];
lsY_58_Y_G   = [lsY_58_Y_G_c;   lsY_58_Y_G_a];

lsY_81_G_B   = [lsY_81_G_B_c;   lsY_81_G_B_a];
lsY_81_B_Pp  = [lsY_81_B_Pp_c;  lsY_81_B_Pp_a];
lsY_81_Pp_Pk = [lsY_81_Pp_Pk_c; lsY_81_Pp_Pk_a];
lsY_81_Pk_O  = [lsY_81_Pk_O_c;  lsY_81_Pk_O_a];
lsY_81_O_Y   = [lsY_81_O_Y_c;   lsY_81_O_Y_a];
lsY_81_Y_G   = [lsY_81_Y_G_c;   lsY_81_Y_G_a];

[lsYFrontiers, borders] = AddColourBorders365881(borders, lsYFrontiers, 'green', 'blue', lsY_36_G_B, lsY_58_G_B, lsY_81_G_B);
[lsYFrontiers, borders] = AddColourBorders365881(borders, lsYFrontiers, 'blue', 'purple', lsY_36_B_Pp, lsY_58_B_Pp, lsY_81_B_Pp);
[lsYFrontiers, borders] = AddColourBorders365881(borders, lsYFrontiers, 'purple', 'pink', lsY_36_Pp_Pk, lsY_58_Pp_Pk, lsY_81_Pp_Pk);
[lsYFrontiers, borders] = AddColourBorders365881(borders, lsYFrontiers, 'pink', 'red', lsY_36_Pk_R, lsY_58_Pk_R, []);
[lsYFrontiers, borders] = AddColourBorders365881(borders, lsYFrontiers, 'red', 'brown', lsY_36_R_Br, [], []);
[lsYFrontiers, borders] = AddColourBorders365881(borders, lsYFrontiers, 'brown', 'green', lsY_36_Br_G, [], []);
[lsYFrontiers, borders] = AddColourBorders365881(borders, lsYFrontiers, 'red', 'orange', [], lsY_58_R_O, []);
[lsYFrontiers, borders] = AddColourBorders365881(borders, lsYFrontiers, 'orange', 'yellow', [], lsY_58_O_Y, lsY_81_O_Y);
[lsYFrontiers, borders] = AddColourBorders365881(borders, lsYFrontiers, 'yellow', 'green', [], lsY_58_Y_G, lsY_81_Y_G);
[lsYFrontiers, borders] = AddColourBorders365881(borders, lsYFrontiers, 'pink', 'orange', [], [], lsY_81_Pk_O);

lsY_36_W_G   = [lsY_36_W_G_c;   lsY_36_W_G_a];
lsY_36_W_B   = [lsY_36_W_B_c;   lsY_36_W_B_a];
lsY_36_W_Pp  = [lsY_36_W_Pp_c;  lsY_36_W_Pp_a];
lsY_36_W_Pk  = [lsY_36_W_Pk_c;  lsY_36_W_Pk_a];
lsY_36_W_R   = [lsY_36_W_R_c;   lsY_36_W_R_a];
lsY_36_W_Br  = [lsY_36_W_Br_c;  lsY_36_W_Br_a];

lsY_58_W_G   = [lsY_58_W_G_c;   lsY_58_W_G_a];
lsY_58_W_B   = [lsY_58_W_B_c;   lsY_58_W_B_a];
lsY_58_W_Pp  = [lsY_58_W_Pp_c;  lsY_58_W_Pp_a];
lsY_58_W_Pk  = [lsY_58_W_Pk_c;  lsY_58_W_Pk_a];
lsY_58_W_R   = [lsY_58_W_R_c;   lsY_58_W_R_a];
lsY_58_W_O   = [lsY_58_W_O_c;   lsY_58_W_O_a];
lsY_58_W_Y   = [lsY_58_W_Y_c;   lsY_58_W_Y_a];

lsY_81_W_G   = [lsY_81_W_G_c;   lsY_81_W_G_a];
lsY_81_W_B   = [lsY_81_W_B_c;   lsY_81_W_B_a];
lsY_81_W_Pp  = [lsY_81_W_Pp_c;  lsY_81_W_Pp_a];
lsY_81_W_Pk  = [lsY_81_W_Pk_c;  lsY_81_W_Pk_a];
lsY_81_W_O   = [lsY_81_W_O_c;   lsY_81_W_O_a];
lsY_81_W_Y   = [lsY_81_W_Y_c;   lsY_81_W_Y_a];

[lsYFrontiers, borders] = AddColourBorders365881(borders, lsYFrontiers, 'grey', 'green', lsY_36_W_G, lsY_58_W_G, lsY_81_W_G);
[lsYFrontiers, borders] = AddColourBorders365881(borders, lsYFrontiers, 'grey', 'blue', lsY_36_W_B, lsY_58_W_B, lsY_81_W_B);
[lsYFrontiers, borders] = AddColourBorders365881(borders, lsYFrontiers, 'grey', 'purple', lsY_36_W_Pp, lsY_58_W_Pp, lsY_81_W_Pp);
[lsYFrontiers, borders] = AddColourBorders365881(borders, lsYFrontiers, 'grey', 'pink', lsY_36_W_Pk, lsY_58_W_Pk, lsY_81_W_Pk);
[lsYFrontiers, borders] = AddColourBorders365881(borders, lsYFrontiers, 'grey', 'red', lsY_36_W_R, lsY_58_W_R, []);
[lsYFrontiers, borders] = AddColourBorders365881(borders, lsYFrontiers, 'grey', 'brown', lsY_36_W_Br, [], []);
[lsYFrontiers, borders] = AddColourBorders365881(borders, lsYFrontiers, 'grey', 'orange', [], lsY_58_W_O, lsY_81_W_O);
[lsYFrontiers, borders] = AddColourBorders365881(borders, lsYFrontiers, 'grey', 'yellow', [], lsY_58_W_Y, lsY_81_W_Y);

%% new experiments

ScriptPath = mfilename('fullpath');
DirPath = strrep(ScriptPath, 'matlab/src/algorithms/colourcategorisation/OrganiseExperimentFrontiers', 'matlab/data/mats/results/experiments/colourfrontiers/real/');

MatFiles = dir([DirPath, '*.mat']);

for i = 1:length(MatFiles)
  CurrentMatPath = [DirPath, MatFiles(i).name];
  [lsYFrontiers, borders] = ReadExperimentResults(lsYFrontiers, borders, CurrentMatPath);
end

if plotme
  figure('NumberTitle', 'Off', 'Name', 'Colour Frontiers');
  hold on;
  PlotColourBorders(borders);
  xlabel('l');
  ylabel('s');
  zlabel('Y');
  grid on;
end

end

function [lsYFrontiers, borders] = AddColourBorders365881(borders, lsYFrontiers, ColourA, ColourB, lum36, lum58, lum81)

border = ColourBorder(lsYFrontiers.(ColourA), lsYFrontiers.(ColourB), lum36, 36);
border = border.AddPoints(lum58, 58);
border = border.AddPoints(lum81, 81);
lsYFrontiers.(ColourA) = lsYFrontiers.(ColourA).AddBorder(border);
lsYFrontiers.(ColourB) = lsYFrontiers.(ColourB).AddBorder(border);
borders{end + 1} = border;

end

function [] = PlotColourBorders(borders)

for i = 1:length(borders)
  borderi = borders{i};
  borderi.PlotBorders();
end

end

function [lsYFrontiers, borders] = ReadExperimentResults(lsYFrontiers, borders, FilePath)

MatFile = load(FilePath);
ExperimentResult = MatFile.ExperimentResults;

if strcmpi(ExperimentResult.type, 'arch') || strcmpi(ExperimentResult.type, 'centre')
  [lsYFrontiers, borders] = DoArchCentre(lsYFrontiers, borders, ExperimentResult);
else
  % FIXME: how to integrate luminance
  [lsYFrontiers, borders] = DoLuminance(lsYFrontiers, borders, ExperimentResult);
end

end

% TODO: make this code more readable
function [lsYFrontiers, borders] = DoArchCentre(lsYFrontiers, borders, ExperimentResult)

angles = ExperimentResult.angles;
radii = ExperimentResult.radii;
luminances = ExperimentResult.luminances;
FrontierColours = ExperimentResult.FrontierColours;
WhiteReference = ExperimentResult.WhiteReference;
XYZ2lsYChoise = 'evenly_ditributed_stds';

nborders = length(unique(ExperimentResult.conditions));
nexperiments = length(angles);
nluminances = unique(luminances);
nconditions = floor(nexperiments / nborders);

% containts the points for different luminances
lsys = struct();
% counter for each luminance
lcounter = struct();
lsysnames = struct();

for i = 1:length(nluminances)
  LumName = ['lum', num2str(nluminances(i))];
  lsys.(LumName) = zeros(nconditions, 3);
  lcounter.(LumName) = 1;
  lsysnames.(LumName) = cell(nconditions, 2);
end

for i = 1:nexperiments
  lab = pol2cart3([angles(i), radii(i), luminances(i)], 1);
  LumName = ['lum', num2str(luminances(i))];
  lsys.(LumName)(lcounter.(LumName), :) = XYZ2lsY(Lab2XYZ(lab, WhiteReference), XYZ2lsYChoise);
  ColourA = lower(FrontierColours{i, 1});
  ColourB = lower(FrontierColours{i, 2});
  lsysnames.(LumName)(lcounter.(LumName), :) = {ColourA, ColourB};
  lcounter.(LumName) = lcounter.(LumName) + 1;
end

for i = 1:length(nluminances)
  LumName = ['lum', num2str(nluminances(i))];
  
  for k = 1:nconditions
    ColourA = lsysnames.(LumName){k, 1};
    ColourB = lsysnames.(LumName){k, 2};
    
    border = [];
    for j = 1:length(borders)
      colour1 = borders{j}.colour1.name;
      colour2 = borders{j}.colour2.name;
      if (strcmpi(colour1, ColourA) || strcmpi(colour1, ColourB)) && ...
          (strcmpi(colour2, ColourA) || strcmpi(colour2, ColourB))
        border = borders{j};
        border = border.AddPoints(lsys.(LumName)(k, :), nluminances(i));
        lsYFrontiers.(ColourA) = lsYFrontiers.(ColourA).SetBorder(border);
        lsYFrontiers.(ColourB) = lsYFrontiers.(ColourB).SetBorder(border);
        borders{j} = border;
        break;
      end
    end
    
    if isempty(border)
      border = ColourBorder(lsYFrontiers.(ColourA), lsYFrontiers.(ColourB), lsys.(LumName)(k, :), nluminances(i));
      lsYFrontiers.(ColourA) = lsYFrontiers.(ColourA).AddBorder(border);
      lsYFrontiers.(ColourB) = lsYFrontiers.(ColourB).AddBorder(border);
      borders{end + 1} = border; %#ok<AGROW>
    end
  end
end

end

function [lsYFrontiers, borders] = DoLuminance(lsYFrontiers, borders, ExperimentResult)

angles = ExperimentResult.angles;
radii = ExperimentResult.radii;
luminances = ExperimentResult.luminances;
FrontierColours = ExperimentResult.FrontierColours;
WhiteReference = ExperimentResult.WhiteReference;
XYZ2lsYChoise = 'evenly_ditributed_stds';

nexperiments = length(angles);

LumName = 0;

lsys = zeros(nexperiments, 3);
lsysnames = cell(nexperiments, 2);

for i = 1:nexperiments
  lab = pol2cart3([angles(i), radii(i), luminances(i)], 1);
  lsys(i, :) = XYZ2lsY(Lab2XYZ(lab, WhiteReference), XYZ2lsYChoise);
  ColourA = lower(FrontierColours{i, 1});
  ColourB = lower(FrontierColours{i, 2});
  lsysnames(i, :) = {ColourA, ColourB};
  
  border = [];
  for j = 1:length(borders)
    colour1 = borders{j}.colour1.name;
    colour2 = borders{j}.colour2.name;
    if (strcmpi(colour1, ColourA) || strcmpi(colour1, ColourB)) && ...
        (strcmpi(colour2, ColourA) || strcmpi(colour2, ColourB))
      border = borders{j};
      border = border.AddPoints(lsys(i, :), LumName);
      lsYFrontiers.(ColourA) = lsYFrontiers.(ColourA).SetBorder(border);
      lsYFrontiers.(ColourB) = lsYFrontiers.(ColourB).SetBorder(border);
      borders{j} = border;
      break;
    end
  end
  
  if isempty(border)
    border = ColourBorder(lsYFrontiers.(ColourA), lsYFrontiers.(ColourB), lsys(i, :), LumName);
    lsYFrontiers.(ColourA) = lsYFrontiers.(ColourA).AddBorder(border);
    lsYFrontiers.(ColourB) = lsYFrontiers.(ColourB).AddBorder(border);
    borders{end + 1} = border; %#ok<AGROW>
  end
end

end
