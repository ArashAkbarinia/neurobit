classdef ColourCategory
  %ColourCategory wrapper for the colour class.
  
  properties
    name     % the english name of the colour.
    rgb      % the rgb value of the colour.
    borders  % the borders in the lsY space.
  end
  
  methods
    function obj = ColourCategory(name, rgb)
      obj.name = name;
      obj.rgb = rgb;
      obj.borders = [];
    end
    
    function obj = AddBorder(obj, borders)
      obj.borders = [obj.borders; borders];
    end
    
    function borders = GetBorders(obj, luminance)
      borders = [];
      for i = 1:length(obj.borders)
        borders = [borders; obj.borders(i).points.(['lum', num2str(luminance)])]; %#ok<AGROW>
      end
    end
  end
  
end
