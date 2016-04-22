% Usage: 
%       [pb bm] = NonmaxHysthresh(img,theta,p);
% Function for performing non-maxima suppression(on an image using an orientation image) 
% followed by  hysteresis thresholding.
%
% Input: 
%      img    - Image to be non-maxima suppressed and binarize
%      theta  - Image containing feature normal orientation angles in degrees
%              (0-pi).the distribution of angles as flowws:
%                           0
%                         \ | /                                
%                 3*pi/2 -- * -- pi/2                
%                         / | \                                 
%                           pi                   
%      p      - The minimum fraciton of candidate pixels to be stained in the
%              final contour map. Here, p is used to determine the two
%              threholds for hysteresis thresholding.
% Output: 
%      pb     - Real-valued probability of contours. The results after non-max suppression.  
%      bm     - The thresholded image (containing values 0 or 1). The
%                results after hysteresis thresholding.
%
% Notes: 
%      Modified by Kaifu Yang, September 2014
%      Oringinal codes from David R. Martin.
%      February 2012
%=========================================================================%
function [pb bm] = NonmaxHysthresh(im,theta,p)

if any(size(im) ~= size(theta))
  error('image and orientation image are of different sizes');
end

% Normalize to [0 1] ...
  immax = max(im(:));
   if immax>0
     im = im / immax;   % normalize
   end
   
% STEP ONE: Non-max Suppression with orientation map...
if numel(theta)==1,
  theta = theta .* ones(size(im));
end

% Determine which pixels belong to which cases.
%        (4)    1        
%       *----*----*      
%   (3) |         | 2   
%       *    X    *      
%   (2) |         | 3   
%       *----*----*     
%        (1)    4   
mask1 = ( theta>=0 & theta<pi/4 );
mask2 = ( theta>=pi/4 & theta<pi/2 );
mask3 = ( theta>=pi/2 & theta<pi*3/4 );
mask4 = ( theta>=pi*3/4 & theta<pi );

mask = ones(size(im));
[h,w] = size(im);
[ix,iy] = meshgrid(1:w,1:h);

% case 1
idx = find( mask1 & ix<w & iy<h);  % ix<w & iy<h is remove border pixels
idxA = idx + h;
idxB = idx + h + 1;
d = tan(theta(idx));
imI = im(idxA).*(1-d) + im(idxB).*d;
mask(idx(find(im(idx)<imI))) = 0;

% case 5
idx = find( mask1 & ix>1 & iy>1);
idxA = idx - h;
idxB = idx - h - 1;
d = tan(theta(idx));
imI = im(idxA).*(1-d) + im(idxB).*d;
mask(idx(find(im(idx)<imI))) = 0;

% case 2
idx = find( mask2 & ix<w & iy<h );
idxA = idx + 1;
idxB = idx + h + 1;
d = tan(pi/2-theta(idx));
imI = im(idxA).*(1-d) + im(idxB).*d;
mask(idx(find(im(idx)<imI))) = 0;

% case 6
idx = find( mask2 & ix>1 & iy>1 );
idxA = idx - 1;
idxB = idx - h - 1;
d = tan(pi/2-theta(idx));
imI = im(idxA).*(1-d) + im(idxB).*d;
mask(idx(find(im(idx)<imI))) = 0;

% case 3
idx = find( mask3 & ix>1 & iy<h );
idxA = idx + 1;
idxB = idx - h + 1;
d = tan(theta(idx)-pi/2);
imI = im(idxA).*(1-d) + im(idxB).*d;
mask(idx(find(im(idx)<imI))) = 0;

% case 7
idx = find( mask3 & ix<w & iy>1 );
idxA = idx - 1;
idxB = idx + h - 1;
d = tan(theta(idx)-pi/2);
imI = im(idxA).*(1-d) + im(idxB).*d;
mask(idx(find(im(idx)<imI))) = 0;

% case 4
idx = find( mask4 & ix>1 & iy<h );
idxA = idx - h;
idxB = idx - h + 1;
d = tan(pi-theta(idx));
imI = im(idxA).*(1-d) + im(idxB).*d;
mask(idx(find(im(idx)<=imI))) = 0;

% case 8
idx = find( mask4 & ix<w & iy>1 );
idxA = idx + h;
idxB = idx + h - 1;
d = tan(pi-theta(idx));
imI = im(idxA).*(1-d) + im(idxB).*d;
mask(idx(find(im(idx)<imI))) = 0;

% apply mask
pb = im .* mask;

% STEP TWO: Hysteresis thresholding ... 
% Two threholds are selected with the precent of pixels 
% to be retained in the final map.

ThresholdRatio = .5;          % Low thresh is this fraction of the high.
counts=imhist(pb, 255);
counts(1,1)=0;
T1 = find(cumsum(counts) >= (1-p)*sum(counts),1,'first') / 255;
T2 = ThresholdRatio*T1;
    
aboveT2 = pb > T2;                     % Edge points above lower threshold. 
[aboveT1r, aboveT1c] = find(pb > T1);  % Row and colum coords of points
                                           % above upper threshold.
					   
% Obtain all connected regions in aboveT2 that include a point that has a
% value above T1 
bm = bwselect(aboveT2, aboveT1c, aboveT1r, 8);
%==========================================================================%
