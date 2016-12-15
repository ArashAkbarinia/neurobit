function labmap = LabColourMap()
%LabColourMap  generates the colour map of CIE Lab space.
%   Detailed explanation goes here

radius = 1;
clength = 64;
labmap = zeros(clength, 3);

AngleGap = 2 * pi / clength;
for i = 1:clength
  labmap(i, :) = pol2cart3([(i - 1) * AngleGap, radius, 1], true);
end

labmap = lab2rgb(labmap);
labmap = labmap ./ repmat(max(labmap, [], 2), [1, 3]);

labmap = double(GammaCorrection(labmap .* 255, 2.2)) ./ 255;

end
