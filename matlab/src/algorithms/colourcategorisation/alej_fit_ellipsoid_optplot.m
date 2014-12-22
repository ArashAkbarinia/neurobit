function RSS = alej_fit_ellipsoid_optplot(x, plotme, verbose, FittingData, FittingParams)
% Describe the function
% This function does the actual fitting of the three level datapoints
% obtained by variables data36 data58 and data81 and the 3D-ellipsoid.
% The datapoints correspond to the psychophysical results obtained through
% colour categorization experiments in the frontiers between colour names.
% The ellipsoid parameters are passed to the funtion though the variable x
% which contains the centre and the semi-axes of the 3D-ellipsoid to fit to
% the data. Imagine the ellipsoid as a rugby ball placed with its main axis
% vertically. It intersects the three horizontal dataplanes (at three
% luminance levels) forming three horizontal ellipses.
% The actual fitting is done considering the distance between each
% point in the luminance data plane and the closest point on the ellipse
% for each plane. The output of this function is the residual
% sum of squares (RSS) of these distances, added for the three planes.
% Since the data in the lowest luminance plane has the largest variance, it
% tends to bias the fitting. To counter this, we weighted the RSS
% corresponding to each luminance plane.

if nargin < 3
  verbose = 0;
end
if nargin < 2
  plotme = 0;
end

%check whether fminsearch is doing a good job===========================
global doproperdistance;
if doproperdistance
  [carryon, PlotAxes] = DoSomething(FittingData, x, verbose);
  
  if carryon
    % FIXME; make it dynamic
    borders = [25, 36, 47, 58, 70, 81];
    RSS = 0;
    for i = borders
      RSS = RSS + FitData(FittingData.(['data', num2str(i)]), FittingData.(['ylevel', num2str(i)])(2), x);
      
      if plotme
        PlotData(FittingData.data36, FittingData.Y_level36, FittingData.kolor, x, 0.36);
        
        center = x(1:3);
        plot3(center(1), center(2), center(3), 'LineWidth', 3);
        axis(PlotAxes);
        title('Best Fit');
        xlabel('l');
        ylabel('s');
        zlabel('Y');
        hold on;
        %hold off;
        
        view(2);
      end
    end
  else
    RSS = 100;
  end
else
  RSS = FitData(FittingData.borders, 0, x);
end

end

function RSS = FitData(data, ylevel, x)

% TODO: if speed matters we pass some of the parameters to the function

global doproperdistance;
if ~isempty(data)
  if doproperdistance
    centre = x(1:3);
    axes = x(4:6);
    rotation = x(7);
    % TODO: why multiplication shouldn't we just sum?
    axes(:, 1:2) = real(axes(:, 1:2) .* sqrt(1 - ((ylevel - centre(3)) ./ axes(3)) .^ 2));
    
    lscolumns = data(:, 1:2);
    RSS = norm_points_to_ellipse(lscolumns, [centre(1), centre(2), axes(1), axes(2), rotation]);
  else
    RSS = norm_points_to_ellipse(data, x);
  end
else
  RSS = 0;
end

end

function [] = PlotData(data, ylevel, kolor, x)

if ~isempty(data)
  center = x(1:3);
  radii = x(4:6);
  Angle_rad = x(7);
  curradii(:,1:2) = real(radii(:,1:2).* (sqrt(1-((ylevel - center(3))./radii(3))^2)));
  [x1, y1] = alej_ellipse(center(1), center(2), curradii(1), curradii(2), Angle_rad) ;
  z1 = ylevel * ones(size(x1,1));
  plot3(data(:, 1), data(:, 2), data(:, 3), '.', 'Color', kolor * kfactor);
  hold on;
  plot3(x1, y1, z1, 'LineWidth', 3);
  hold on;
end

end

function [carryon, PlotAxes] = DoSomething(FittingData, x, verbose)

center = x(1:3);
radii = x(4:6);

carryon = 1;

switch FittingData.category
  case 'green'
    n1 = 10;
    n2 = 1;
    PlotAxes = [0.55 0.85 -0.1 0.2 0 300];
    if  (sum(radii > n1*FittingData.allstd))
      if verbose
        disp(['The ellipse is larger than ',num2str(n1),' StDev']);
      end;
      carryon = 0;
    elseif ((sum(abs(center-[0.60,0.00,FittingData.allmeans(3)]) > n2*FittingData.allstd)) || (center(2)<0))
      if verbose
        disp(['The centre is further than ',num2str(n2),' StDev from the mean of the points']);
      end;
      carryon = 0;
    end
  case 'blue'
    n1 = 100;
    n2 = 1;
    PlotAxes = [0.55 0.85 -0.1 0.2 0 300];
    if  (sum(radii > n1*FittingData.allstd))
      if verbose
        disp(['The ellipse is larger than ',num2str(n1),' StDev']);
      end;
      carryon = 0;
    elseif ((sum(abs(center-[0.58,0.25, FittingData.allmeans(3)]) > n2*FittingData.allstd)) || (center(3)<0))
      if verbose
        disp(['The centre is further than ',num2str(n2),' StDev from the mean of the points']);
      end;
      carryon = 0;
    end
  case 'purple'
    n1 = 20;
    n2 = 0.5;
    PlotAxes = [0.55 0.85 -0.1 0.2 0 60];
    if  (sum(radii > n1*FittingData.allstd))% || (radii(3) > 50)
      if verbose
        disp(['The ellipse is larger than ',num2str(n1),' StDev']);
      end;
      carryon = 0;
    elseif (sum(abs(center-[0.68, 0.20, FittingData.allmeans(3)]) > n2*FittingData.allstd))
      if verbose
        disp(['The centre is further than ',num2str(n2),' StDev from the mean of the points']);
      end;
      carryon = 0;
    end
  case 'pink'
    n1 = 10; % regulates the axes
    n2 = 1; % regulates the centre
    PlotAxes = [0.55 0.85 -0.1 0.2 0 300];
    if (sum(radii > n1 * FittingData.allstd)) %|| (radii(3) > 100)
      if verbose
        disp(['The ellipse is larger than ', num2str(n1), ' StDev']);
      end;
      carryon = 0;
    elseif (sum(abs(center-[0.8, 0.1, FittingData.allmeans(3)]) > n2 * FittingData.allstd)) %|| (center(3)>100)
      if verbose
        disp(['The centre is further than ', num2str(n2), ' StDev from the mean of the points']);
      end;
      carryon = 0;
    end
  case 'red'
    n1 = 10;
    n2 = 0.5;
    PlotAxes = [0.55 0.85 -0.1 0.2 0 60];
    if  (sum(radii > n1*FittingData.allstd)) || (radii(3) > 80)
      if verbose
        disp(['The ellipse is larger than ',num2str(n1),' StDev']);
      end;
      carryon = 0;
    elseif ((sum(abs(center-[0.8, 0.025, FittingData.allmeans(3)]) > n2*FittingData.allstd)) || (center(3)<0))
      if verbose
        disp(['The centre is further than ',num2str(n2),' StDev from the mean of the points']);
      end;
      carryon = 0;
    end
  case 'orange'
    n1 = 10;
    n2 = 10;
    PlotAxes = [0.55 0.85 -0.1 0.2 0 60];
    if  (sum(radii > n1*FittingData.allstd)) || (radii(3) > 100)
      if verbose
        disp(['The ellipse is larger than ',num2str(n1),' StDev']);
      end;
      carryon = 0;
    elseif ((sum(abs(center-[0.74, 0.00, FittingData.allmeans(3)]) > n2*FittingData.allstd))) || (center(3) <100)
      if verbose
        disp(['The centre is further than ',num2str(n2),' StDev from the mean of the points']);
      end;
      carryon = 0;
    end
  case 'yellow'
    n1 = 5;
    n2 = 1;
    PlotAxes = [0.55 0.85 -0.1 0.2 0 60];
    if  (sum(radii > n1*FittingData.allstd)) || (radii(3) > 100)
      if verbose
        disp(['The ellipse is larger than ',num2str(n1),' StDev']);
      end;
      carryon = 0;
    elseif ((sum(abs(center-[0.68, 0.01, FittingData.allmeans(3)]) > n2*FittingData.allstd)) || (center(3)<100))
      if verbose
        disp(['The centre is further than ',num2str(n2),' StDev from the mean of the points']);
      end;
      carryon = 0;
    end
  case 'brown'
    n1 = 5;
    n2 = 5;
    PlotAxes = [0.55 0.85 -0.1 0.2 0 60];
    if  (sum(radii > n1*FittingData.allstd))
      if verbose
        disp(['The ellipse is larger than ',num2str(n1),' StDev']);
      end;
      carryon = 0;
    elseif ((sum(abs(center-[0.73, 0.00, FittingData.allmeans(3)]) > n2*FittingData.allstd)) || (center(3)<0))
      if verbose
        disp(['The centre is further than ',num2str(n2),' StDev from the mean of the points']);
      end;
      carryon = 0;
    end
  case 'grey'
    n1 = 10;
    n2 = 10;
    PlotAxes = [0.55 0.85 -0.1 0.2 0 60];
    if  (sum(radii > n1*FittingData.allstd))
      if verbose
        disp(['The ellipse is larger than ',num2str(n1),' StDev']);
      end;
      carryon = 0;
    elseif (sum(abs(center-FittingData.allmeans) > n2*FittingData.allstd)) || (center(3) < 0)
      if verbose
        disp(['The centre is further than ',num2str(n2),' StDev from the mean of the points']);
      end;
      carryon = 0;
    end
  case 'white'
    n1 = 10;
    n2 = 10;
    PlotAxes = [0.55 0.85 -0.1 0.2 0 60];
    if  (sum(radii > n1*FittingData.allstd))
      if verbose
        disp(['The ellipse is larger than ',num2str(n1),' StDev']);
      end;
      carryon = 0;
    elseif ((sum(abs(center-FittingData.allmeans) > n2*FittingData.allstd)) || (center(3)<0))
      if verbose
        disp(['The centre is further than ',num2str(n2),' StDev from the mean of the points']);
      end;
      carryon = 0;
    end
end

end

function RSS = norm_points_to_ellipse(XY, ParG, plotme)

if nargin < 3
  plotme = 0;
end

global doproperdistance;
if doproperdistance
  distances = point_to_ellipse(XY, ParG, plotme);
  RSS = norm(distances, 'fro') .^ 2;
  %   RSS = mean(distances) .^ 2;
else
  distances = DistanceEllipsoid(XY, ParG, plotme);
  RSS = norm(distances .^ 2, 'fro') .^ 2;
  %   RSS = mean(distances);
end

%  The Frobenius norm, sometimes also called the Euclidean norm (which may
%  cause confusion with the vector L^2-norm which also sometimes known as
%  the Euclidean norm), is matrix norm of an min matrix  A defined as the
%  square root of the sum of the absolute squares of its elements
% RSS = norm(distances, 'fro') .^ 2;

end
