classdef ColourCategory
  %ColourCategory  wrapper for the colour class.
  
  properties
    name     % the english name of the colour.
    rgb      % the rgb value of the colour.
    borders  % the borders in the lsY space.
  end
  
  methods
    function obj = ColourCategory(name)
      obj.name = name;
      obj.rgb = name2rgb(name);
      obj.borders = [];
    end
    
    function obj = AddBorder(obj, border)
      obj.borders = [obj.borders; border];
    end
    
    function obj = SetBorder(obj, border)
      ColourA = border.colour1.name;
      ColourB = border.colour2.name;
      for i = 1:length(obj.borders)
        colour1 = obj.borders(i).colour1.name;
        colour2 = obj.borders(i).colour2.name;
        if (strcmpi(colour1, ColourA) || strcmpi(colour1, ColourB)) && ...
            (strcmpi(colour2, ColourA) || strcmpi(colour2, ColourB))
          obj.borders(i) = border;
          return;
        end
      end
    end
    
    function borders = GetBorder(obj, luminance)
      borders = [];
      for i = 1:length(obj.borders)
        for j = 1:length(luminance)
          LumName = ['lum', num2str(luminance(j))];
          if isfield(obj.borders(i).points, LumName)
            borders = [borders; obj.borders(i).points.(LumName)]; %#ok<AGROW>
          end
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
