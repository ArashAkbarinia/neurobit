function res = xyz2lms(x,norm)

%XYZ to LMS transformation
% transforms from the Judd-Vos-modified CIE 2-deg color matching functions (XYZ) into
% the Smith and Pokorny (1975) cone fundamentals (LMS)
% norm defines the normalisation applied to the LMS fundamentals
%
%
% Revision History...
%
% V 1.0001      8th October 2004
%
% PGL : Added a 'getoptions' argument to the norm switchyard. Use xyztolms([], 'getoptions')
%       to retrieve the available normalisation vectors for the Smith and Pokorny LMS cone sensitivity functions...
%
% 'unity'           : normalisation is such that the max value is 1 for all fundamentals
%
% 'crossing'        : Normalisation is such that crossings occur near 505 nm for the
%                     blue and yellow and 580 for the red and green fundamentals
%
% 'crossingandarea' : This is an attempt to keep the areas the same while trying to
%                     consistent with the above. Not very good.
%
% 'none'          : Uses the unnormalised S&P LMS fundamentals.

% V 1.002 11th October 2004
%
% CAP : Mapping between the white locus in XYZ space and LMS space added instead of the 'crossingandarea' option
%       To do so I attempted to make the rows of transfromation matrix Trans multiplied by each coefficient of
%       Equaliser to add up to the same number. The label 'crossingandarea' is kept for consistency.
%


Transf=[0.15514	    0.54312	    -0.03286;
  -0.15514	0.45684	    0.03286;
  0	        0	        0.00801];

%Equaliser = [0.502796814	1	41.76791511]; %to map the white locus in one space to the other

if nargin < 2
  norm = 'unity';
end

%disp(['Using the ' norm ' crossing option']);

switch lower(norm)
  case 'unity'
    Equaliser = [1.569459091	2.551291018	77.2253704]; % normalisation is such that the max value is 1 for all fundamentals
  case 'crossing'
    Equaliser = [0.415460518	1	188.4430366];% normalisation is such that crossings occur near 505 nm for the
    % blue and yellow and 580 for the red and green fundamentals
  case 'crossingandwhitepoint'
    Equaliser = [0.415460749 1 41.76786682]; % this is an attempt to map both white point locus while trying to
    % be consistent with the above. Not 100% accurate.
  case 'none'
    Equaliser = [1 1 1]; % uses the unnormalised S&P LMS fundamentals.
    
  case 'getoptions'
    
    res = [];
    res.names    = {};
    res.tooltips = {};
    
    res.names{1}    = 'crossingandwhitepoint';
    res.tooltips{1} = 'A compromise between mapping the white locus while trying to be consistent with crossings.';
    
    res.names{2}    = 'unity';
    res.tooltips{2} = 'normalisation is such that the max value is 1 for all fundamentals';
    
    res.names{3}    = 'crossing';
    res.tooltips{3} = 'Normalisation is such that crossings occur near 505 nm for the blue and yellow and 580 for the red and green fundamentals';
    
    res.names{4}    = 'none';
    res.tooltips{4} = 'Uses the unnormalised S&P LMS fundamentals.';
    
    return;
    
  otherwise
    error(['Unrecognised argument (' norm ')']);
    
end %case


res(:,:,1) = (x(:,:,1).*Transf(1,1) + x(:,:,2).*Transf(1,2) + x(:,:,3).*Transf(1,3)).*Equaliser(1);
res(:,:,2) = (x(:,:,1).*Transf(2,1) + x(:,:,2).*Transf(2,2) + x(:,:,3).*Transf(2,3)).*Equaliser(2);
res(:,:,3) = (x(:,:,1).*Transf(3,1) + x(:,:,2).*Transf(3,2) + x(:,:,3).*Transf(3,3)).*Equaliser(3);

res=res.*(res>0);

end