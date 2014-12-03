classdef ColourBorder
  %ColourBorder wrapper for the colour border class.
  
  properties
    colour1  % on side of the border
    colour2  % other side of the border
    points   % the points defining the border
  end
  
  methods
    function obj = ColourBorder(colour1, colour2, points, luminances)
      obj.colour1 = colour1;
      obj.colour2 = colour2;
      obj.points = struct();
      for i = 1:length(luminances)
        obj.points.(['lum', num2str(luminances(i))]) = points(:, :, i);
      end
    end
    
    function obj = AddPoints(obj, points, luminances)
      for i = 1:length(luminances)
        lumi = ['lum', num2str(luminances(i))];
        CurrentPoints = [];
        if isfield(obj.points, lumi)
          CurrentPoints = obj.points.(lumi);
        end
        obj.points.(lumi) = [CurrentPoints; points(:, :, i)];
      end
    end
  end
  
end

