function lsYFrontiers = organize_frontiers(FilePath, WhiteReference, XYZ2lsYChoise)

if nargin < 3
  XYZ2lsYChoise = 'evenly_ditributed_stds';
end

RawDataMat = load(FilePath);
saturated_chrom_Lab = RawDataMat.saturated_chrom_Lab;
saturated_achrom_Lab = RawDataMat.saturated_achrom_Lab;
unsaturated_chrom_Lab = RawDataMat.unsaturated_chrom_Lab;
unsaturated_achrom_Lab = RawDataMat.unsaturated_achrom_Lab;

%=======================================

%saturated frontiers (coloured background)

%=======================================

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

%=======================================

%saturated frontiers (achromatic background)

%=======================================

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

%=======================================

%unsaturated frontiers (chromatic background)

%=======================================

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

%=======================================

%unsaturated frontiers (achromatic background)

%=======================================

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

% ========================================================
%              all backgrounds combined
% ========================================================

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

% putting them in a struct for the output

lsYFrontiers= struct();
lsYFrontiers.lsY_36_G_B = lsY_36_G_B;
lsYFrontiers.lsY_36_B_Pp = lsY_36_B_Pp;
lsYFrontiers.lsY_36_Pp_Pk = lsY_36_Pp_Pk;
lsYFrontiers.lsY_36_Pk_R = lsY_36_Pk_R;
lsYFrontiers.lsY_36_R_Br = lsY_36_R_Br;
lsYFrontiers.lsY_36_Br_G = lsY_36_Br_G;
lsYFrontiers.lsY_58_G_B = lsY_58_G_B;
lsYFrontiers.lsY_58_B_Pp = lsY_58_B_Pp;
lsYFrontiers.lsY_58_Pp_Pk = lsY_58_Pp_Pk;
lsYFrontiers.lsY_58_Pk_R = lsY_58_Pk_R;
lsYFrontiers.lsY_58_R_O = lsY_58_R_O;
lsYFrontiers.lsY_58_O_Y = lsY_58_O_Y;
lsYFrontiers.lsY_58_Y_G = lsY_58_Y_G;
lsYFrontiers.lsY_81_G_B = lsY_81_G_B;
lsYFrontiers.lsY_81_B_Pp = lsY_81_B_Pp;
lsYFrontiers.lsY_81_Pp_Pk = lsY_81_Pp_Pk;
lsYFrontiers.lsY_81_Pk_O = lsY_81_Pk_O;
lsYFrontiers.lsY_81_O_Y = lsY_81_O_Y;
lsYFrontiers.lsY_81_Y_G = lsY_81_Y_G;
lsYFrontiers.lsY_36_W_G = lsY_36_W_G;
lsYFrontiers.lsY_36_W_B = lsY_36_W_B;
lsYFrontiers.lsY_36_W_Pp = lsY_36_W_Pp;
lsYFrontiers.lsY_36_W_Pk = lsY_36_W_Pk;
lsYFrontiers.lsY_36_W_R = lsY_36_W_R;
lsYFrontiers.lsY_36_W_Br = lsY_36_W_Br;
lsYFrontiers.lsY_58_W_G = lsY_58_W_G;
lsYFrontiers.lsY_58_W_B = lsY_58_W_B;
lsYFrontiers.lsY_58_W_Pp = lsY_58_W_Pp;
lsYFrontiers.lsY_58_W_Pk = lsY_58_W_Pk;
lsYFrontiers.lsY_58_W_R = lsY_58_W_R;
lsYFrontiers.lsY_58_W_O = lsY_58_W_O;
lsYFrontiers.lsY_58_W_Y = lsY_58_W_Y;
lsYFrontiers.lsY_81_W_G = lsY_81_W_G;
lsYFrontiers.lsY_81_W_B = lsY_81_W_B;
lsYFrontiers.lsY_81_W_Pp = lsY_81_W_Pp;
lsYFrontiers.lsY_81_W_Pk = lsY_81_W_Pk;
lsYFrontiers.lsY_81_W_O = lsY_81_W_O;
lsYFrontiers.lsY_81_W_Y = lsY_81_W_Y;

lsY_frontiers_all_c = ...
  [
  lsY_36_G_B_c;
  lsY_36_B_Pp_c;
  lsY_36_Pp_Pk_c;
  lsY_36_Pk_R_c;
  lsY_36_R_Br_c;
  lsY_36_Br_G_c;
  lsY_58_G_B_c;
  lsY_58_B_Pp_c;
  lsY_58_Pp_Pk_c;
  lsY_58_Pk_R_c;
  lsY_58_R_O_c;
  lsY_58_O_Y_c;
  lsY_58_Y_G_c;
  lsY_81_G_B_c;
  lsY_81_B_Pp_c;
  lsY_81_Pp_Pk_c;
  lsY_81_Pk_O_c;
  lsY_81_O_Y_c;
  lsY_81_Y_G_c
  ];

lsY_frontiers_all_a = ...
  [
  lsY_36_G_B_a;
  lsY_36_B_Pp_a;
  lsY_36_Pp_Pk_a;
  lsY_36_Pk_R_a;
  lsY_36_R_Br_a;
  lsY_36_Br_G_a;
  lsY_58_G_B_a;
  lsY_58_B_Pp_a;
  lsY_58_Pp_Pk_a;
  lsY_58_Pk_R_a;
  lsY_58_R_O_a;
  lsY_58_O_Y_a;
  lsY_58_Y_G_a;
  lsY_81_G_B_a;
  lsY_81_B_Pp_a;
  lsY_81_Pp_Pk_a;
  lsY_81_Pk_O_a;
  lsY_81_O_Y_a;
  lsY_81_Y_G_a
  ];

lsYFrontiers.lsY_frontiers_all_c = lsY_frontiers_all_c;
lsYFrontiers.lsY_frontiers_all_a = lsY_frontiers_all_a;

end