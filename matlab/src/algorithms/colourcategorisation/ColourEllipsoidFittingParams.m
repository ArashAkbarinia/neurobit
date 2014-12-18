classdef ColourEllipsoidFittingParams
  %ColourEllipsoidFittingParams Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    colour
    AxesDeviation
    EstimatedAxes
    MaxAxes
    CentreDeviation
    EstimatedCentre
    EstimatedAngles %(*) in degrees counterclockwise
    AllStd
  end
  
  methods
    function obj = ColourEllipsoidFittingParams(colour)
      obj.colour = colour;
    end
  end
  
end
