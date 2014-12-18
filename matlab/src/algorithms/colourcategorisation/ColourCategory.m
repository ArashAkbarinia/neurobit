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
    
    function borders = GetBorder(obj, luminance)
      borders = [];
      for i = 1:length(obj.borders)
        for j = 1:length(luminance)
          borders = [borders; obj.borders(i).points.(['lum', num2str(luminance(j))])]; %#ok<AGROW>
        end
      end
    end
    
    function borders = GetAllBorders(obj)
      borders = [];
      for i = 1:length(obj.borders)
        luminance = fieldnames(obj.borders(i).points);
        for j = 1:numel(luminance)
          borders = [borders; obj.borders(i).points.(luminance{j})]; %#ok<AGROW>
        end
      end
    end
    
    function [] = PlotBorders(obj)
      for i = 1:length(obj.borders)
        obj.borders(i).PlotBorders();
      end
    end
  end
  
end
