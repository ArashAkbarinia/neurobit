function RSS = alej_fit_ellipsoid_optplot(x, plotme, verbose, FittingData)
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
carryon= 1;
center=x(1:3);
radii=x(4:6); %radii(3) = 100;
Angle_rad=x(7);

%check whether fminsearch is doing a good job===========================
switch FittingData.category
  case 'green'
    n1 = 10;
    n2 = 1;
    kolor = [0 1 0];
    myaxes = [0.55 0.85 -0.1 0.2 0 300];
    if  (sum(radii > n1*FittingData.allstd))
      RSS = 100;
      if verbose
        disp(['The ellipse is larger than ',num2str(n1),' StDev']);
      end;
      carryon = 0;
    elseif ((sum(abs(center-[0.60,0.00,FittingData.allmeans(3)]) > n2*FittingData.allstd)) || (center(2)<0))
      RSS = 100;
      if verbose
        disp(['The centre is further than ',num2str(n2),' StDev from the mean of the points']);
      end;
      carryon = 0;
    end
  case 'blue'
    n1 = 100;
    n2 = 1;
    kolor = [0 0 1];
    myaxes = [0.55 0.85 -0.1 0.2 0 300];
    if  (sum(radii > n1*FittingData.allstd))
      RSS = 100;
      if verbose
        disp(['The ellipse is larger than ',num2str(n1),' StDev']);
      end;
      carryon = 0;
    elseif ((sum(abs(center-[0.58,0.25, FittingData.allmeans(3)]) > n2*FittingData.allstd)) || (center(3)<0))
      RSS = 100;
      if verbose
        disp(['The centre is further than ',num2str(n2),' StDev from the mean of the points']);
      end;
      carryon = 0;
    end
  case 'purple'
    n1 = 20;
    n2 = 0.5;
    kolor = [0.7 0 0.7];
    myaxes = [0.55 0.85 -0.1 0.2 0 60];
    if  (sum(radii > n1*FittingData.allstd))% || (radii(3) > 50)
      RSS = 100;
      if verbose
        disp(['The ellipse is larger than ',num2str(n1),' StDev']);
      end;
      carryon = 0;
    elseif (sum(abs(center-[0.68, 0.20, FittingData.allmeans(3)]) > n2*FittingData.allstd))
      RSS = 100;
      if verbose
        disp(['The centre is further than ',num2str(n2),' StDev from the mean of the points']);
      end;
      carryon = 0;
    end
  case 'pink'
    n1 = 10; % regulates the axes
    n2 = 1; % regulates the centre
    kolor = [1 0 0.7];
    myaxes = [0.55 0.85 -0.1 0.2 0 300];
    if  (sum(radii > n1*FittingData.allstd)) %|| (radii(3) > 100)
      RSS = 100;
      if verbose
        disp(['The ellipse is larger than ',num2str(n1),' StDev']);
      end;
      carryon = 0;
    elseif (sum(abs(center-[0.8, 0.1, FittingData.allmeans(3)]) > n2*FittingData.allstd)) %|| (center(3)>100)
      RSS = 100;
      if verbose
        disp(['The centre is further than ',num2str(n2),' StDev from the mean of the points']);
      end;
      carryon = 0;
    end
  case 'red'
    n1 = 10;
    n2 = 0.5;
    
    kolor = [1 0 0];
    myaxes = [0.55 0.85 -0.1 0.2 0 60];
    if  (sum(radii > n1*FittingData.allstd)) || (radii(3) > 80)
      RSS = 100;
      if verbose
        disp(['The ellipse is larger than ',num2str(n1),' StDev']);
      end;
      carryon = 0;
    elseif ((sum(abs(center-[0.8, 0.025, FittingData.allmeans(3)]) > n2*FittingData.allstd)) || (center(3)<0))
      RSS = 100;
      if verbose
        disp(['The centre is further than ',num2str(n2),' StDev from the mean of the points']);
      end;
      carryon = 0;
    end
  case 'orange'
    n1 = 10;
    n2 = 10;
    kolor = [1 0.5 0];
    myaxes = [0.55 0.85 -0.1 0.2 0 60];
    if  (sum(radii > n1*FittingData.allstd)) || (radii(3) > 100)
      RSS = 100;
      if verbose
        disp(['The ellipse is larger than ',num2str(n1),' StDev']);
      end;
      carryon = 0;
    elseif ((sum(abs(center-[0.74, 0.00, FittingData.allmeans(3)]) > n2*FittingData.allstd))) || (center(3) <100)
      RSS = 100;
      if verbose
        disp(['The centre is further than ',num2str(n2),' StDev from the mean of the points']);
      end;
      carryon = 0;
    end
  case 'yellow'
    n1 = 5;
    n2 = 1;
    kolor = [1 1 0];
    myaxes = [0.55 0.85 -0.1 0.2 0 60];
    if  (sum(radii > n1*FittingData.allstd)) || (radii(3) > 100)
      RSS = 100;
      if verbose
        disp(['The ellipse is larger than ',num2str(n1),' StDev']);
      end;
      carryon = 0;
    elseif ((sum(abs(center-[0.68, 0.01, FittingData.allmeans(3)]) > n2*FittingData.allstd)) || (center(3)<100))
      RSS = 100;
      if verbose
        disp(['The centre is further than ',num2str(n2),' StDev from the mean of the points']);
      end;
      carryon = 0;
    end
  case 'brown'
    n1 = 5;
    n2 = 5;
    kolor = [1 1 0];
    myaxes = [0.55 0.85 -0.1 0.2 0 60];
    if  (sum(radii > n1*FittingData.allstd))
      RSS = 100;
      if verbose
        disp(['The ellipse is larger than ',num2str(n1),' StDev']);
      end;
      carryon = 0;
    elseif ((sum(abs(center-[0.73, 0.00, FittingData.allmeans(3)]) > n2*FittingData.allstd)) || (center(3)<0))
      RSS = 100;
      if verbose
        disp(['The centre is further than ',num2str(n2),' StDev from the mean of the points']);
      end;
      carryon = 0;
    end
  case 'grey'
    n1 = 10;
    n2 = 10;
    kolor = [1 1 1];
    myaxes = [0.55 0.85 -0.1 0.2 0 60];
    if  (sum(radii > n1*FittingData.allstd))
      RSS = 100;
      if verbose
        disp(['The ellipse is larger than ',num2str(n1),' StDev']);
      end;
      carryon = 0;
    elseif (sum(abs(center-FittingData.allmeans) > n2*FittingData.allstd)) || (center(3) < 0)
      RSS = 100;
      if verbose
        disp(['The centre is further than ',num2str(n2),' StDev from the mean of the points']);
      end;
      carryon = 0;
    end
  case 'white'
    n1 = 10;
    n2 = 10;
    kolor = [0 0 0];
    myaxes = [0.55 0.85 -0.1 0.2 0 60];
    if  (sum(radii > n1*FittingData.allstd))
      RSS = 100;
      if verbose
        disp(['The ellipse is larger than ',num2str(n1),' StDev']);
      end;
      carryon = 0;
    elseif ((sum(abs(center-FittingData.allmeans) > n2*FittingData.allstd)) || (center(3)<0))
      RSS = 100;
      if verbose
        disp(['The centre is further than ',num2str(n2),' StDev from the mean of the points']);
      end;
      carryon = 0;
    end
end

%fit plane 36==============================================================

if carryon
  if ~isempty(FittingData.data36)
    radii36(:,1:2) = real(radii(:,1:2).* (sqrt(1-((FittingData.Y_level36-center(3))./radii(3))^2)));
    data36s = FittingData.data36(:,1:2);
    
    %     RSS1 = Residuals_ellipse(data36s,[[center(1), center(2)],...
    %         [radii36(1), radii36(2)],Angle_rad]');
    RSS1 = norm_points_to_ellipse(data36s,[center(1), center(2), radii36(1), radii36(2), Angle_rad]);
    if plotme
      [x1, y1] = alej_ellipse(center(1), center(2), radii36(1), radii36(2), Angle_rad) ;
      z1 = FittingData.Y_level36 * ones(size(x1,1));
    end
    
  else
    RSS1 = 0;
  end
  
  %fit plane 58 =============================================================
  if ~isempty(FittingData.data58)
    radii58(:,1:2) = real(radii(:,1:2).* (sqrt(1-((FittingData.Y_level58-center(3))./radii(3))^2)));
    data58s = FittingData.data58(:,1:2);
    
    %     RSS2 = Residuals_ellipse(data58s,[[center(1), center(2)],...
    %         [radii58(1), radii58(2)], Angle_rad]');
    RSS2 = norm_points_to_ellipse(data58s, [center(1), center(2), radii58(1), radii58(2), Angle_rad]);
    if plotme
      [x2, y2] = alej_ellipse(center(1), center(2), radii58(1), radii58(2), Angle_rad) ;
      z2 = FittingData.Y_level58 * ones(size(x2,1));
    end
  else
    RSS2 = 0;
  end
  
  %fit plane 81 =============================================================
  if ~isempty(FittingData.data81)
    radii81(:,1:2) = real(radii(:,1:2).* (sqrt(1-((FittingData.Y_level81-center(3))./radii(3))^2)));
    data81s = FittingData.data81(:,1:2);
    
    %     RSS3 = Residuals_ellipse(data81s,[[center(1), center(2)],...
    %         [radii81(1), radii81(2)], Angle_rad]');
    RSS3 = norm_points_to_ellipse(data81s, [center(1), center(2), radii81(1), radii81(2), Angle_rad]);
    if plotme
      [x3, y3] = alej_ellipse(center(1), center(2), radii81(1), radii81(2), Angle_rad) ;
      z3 = FittingData.Y_level81 * ones(size(x3,1));
    end
  else
    RSS3 = 0;
  end
  
  if plotme
    %h = figure;
    if ~isempty(FittingData.data36)
      plot3(FittingData.data36(:,1), FittingData.data36(:,2), FittingData.data36(:,3), '.', 'Color', kolor * 0.36); hold on;
      plot3(x1, y1, z1,'LineWidth', 3); hold on;
    else
      RSS1 = 0;
    end
    if ~isempty(FittingData.data58)
      plot3(FittingData.data58(:,1), FittingData.data58(:,2), FittingData.data58(:,3), '.', 'Color', kolor * 0.58);  hold on;
      plot3(x2, y2, z2, 'LineWidth', 3); hold on;
    else
      RSS2 = 0;
    end
    if ~isempty(FittingData.data81)
      plot3(FittingData.data81(:,1), FittingData.data81(:,2), FittingData.data81(:,3), '.', 'Color', kolor * 0.81); hold on;
      plot3(x3, y3, z3, 'LineWidth', 3); hold on;
    else
      RSS3 = 0;
    end
    
    plot3(center(1),center(2),center(3),'LineWidth',3);
    axis(myaxes);
    title('Best Fit');
    xlabel('l');
    ylabel('s');
    zlabel('Y');
    hold on;
    %hold off;
    
    view(2);
  end
  
  RSS = RSS1 + 2 * RSS2 + 4 * RSS3;
end

end

function RSS = norm_points_to_ellipse(XY, ParG, plotme)

if nargin < 3
  plotme = 0;
end

distances = point_to_ellipse(XY, ParG, plotme);

%  The Frobenius norm, sometimes also called the Euclidean norm (which may
%  cause confusion with the vector L^2-norm which also sometimes known as
%  the Euclidean norm), is matrix norm of an m�n matrix  A defined as the
%  square root of the sum of the absolute squares of its elements
RSS = norm(distances, 'fro') .^ 2;

end