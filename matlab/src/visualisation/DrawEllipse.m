function h = DrawEllipse(ellipse, varargin)
%DrawEllipse Summary of this function goes here

ntheta = 36;
PlotAlpha = 0.1;

% default set of options for drawing meshes
options = {'linestyle', '-'};

% extract input arguments
while length(varargin) > 1
  switch lower(varargin{1})
    case 'nphi'
      ntheta = varargin{2};
      
    case 'alpha'
      PlotAlpha = varargin{2};
      
    otherwise
      % assumes this is drawing option
      options = [options, varargin(1:2)]; %#ok<AGROW>
  end
  
  varargin(1:2) = [];
end

CircumferencePoints = PointsEllipseCircumference(ellipse, ntheta);
h = line(CircumferencePoints(:, 1), CircumferencePoints(:, 2));
set(h, options{:});

alpha(PlotAlpha);

end
