function h = EdgeSurroundModulation()
%EdgeSurroundModulation Summary  returing a edge detector filter.
%

MrfSize = [3, 3];
SrfSize = MrfSize .* 3;
NrfSize = MrfSize .* 5;
FrfSize = MrfSize .* 7;
OrfSize = MrfSize .* 9;

MrfExp = -1.00;
SrfExp = -1.50;
NrfExp = -1.50;
FrfExp = -1.75;
OrfExp = -2.00;

hsx = OrfSize(1);
hsy = OrfSize(2);
midp = [(hsx + 1) / 2, (hsy + 1) / 2];
MapGrid = ones(midp(1) - 1, hsy) * 2;
MapGrid(midp(1) - 1, midp(2)) = 1;
gradi = brushfire(MapGrid, 4);
gradi(midp(1) + 1, :) = 0;
gradi(midp(1) + 1:hsx, :) = gradi(midp(1) - 1:-1:1, :);

MrfOff = floor(MrfSize / 2);
hmrf = gradi((midp(1) - MrfOff(1)):(midp(1) + MrfOff(1)), (midp(2) - MrfOff(2)):(midp(2) + MrfOff(2)));
hmrf(hmrf ~= 0) = hmrf(hmrf ~= 0) .^ MrfExp;
[hmrfrows, ~] = size(hmrf);
hmrfmid = ceil(hmrfrows / 2);
hmrf(hmrfmid + 1:end, :) = -hmrf(hmrfmid + 1:end, :);

SrfOff = floor(SrfSize / 2);
hsrf = gradi((midp(1) - SrfOff(1)):(midp(1) + SrfOff(1)), (midp(2) - SrfOff(2)):(midp(2) + SrfOff(2)));
hsrf(hsrf ~= 0) = hsrf(hsrf ~= 0) .^ SrfExp;
[hsrfrows, ~] = size(hsrf);
hsrfmid = ceil(hsrfrows / 2);
% to be part of surround
hsrf(1:hsrfmid - 1, :) = -hsrf(1:hsrfmid - 1, :);
% to be part of centre
% hsrf(hsrfmid + 1:end, :) = -hsrf(hsrfmid + 1:end, :);

NrfOff = floor(NrfSize / 2);
hnrf = gradi((midp(1) - NrfOff(1)):(midp(1) + NrfOff(1)), (midp(2) - NrfOff(2)):(midp(2) + NrfOff(2)));
hnrf(hnrf ~= 0) = hnrf(hnrf ~= 0) .^ NrfExp;
[hnrfrow, ~] = size(hnrf);
hnrfmid = ceil(hnrfrow / 2);
hnrf(1:hnrfmid - 1, :) = -hnrf(1:hnrfmid - 1, :);

FrfOff = floor(FrfSize / 2);
hfrf = gradi((midp(1) - FrfOff(1)):(midp(1) + FrfOff(1)), (midp(2) - FrfOff(2)):(midp(2) + FrfOff(2)));
hfrf(hfrf ~= 0) = hfrf(hfrf ~= 0) .^ FrfExp;
[hfrfrows, ~] = size(hfrf);
hfrfmid = ceil(hfrfrows / 2);
hfrf(hfrfmid + 1:end, :) = -hfrf(hfrfmid + 1:end, :);

OrfOff = floor(OrfSize / 2);
horf = gradi((midp(1) - OrfOff(1)):(midp(1) + OrfOff(1)), (midp(2) - OrfOff(2)):(midp(2) + OrfOff(2)));
horf(horf ~= 0) = horf(horf ~= 0) .^ OrfExp;
[horfrows, ~] = size(horf);
horfmid = ceil(horfrows / 2);
horf(horfmid + 1:end, :) = -horf(horfmid + 1:end, :);

h = horf;
h((midp(1) - FrfOff(1)):(midp(1) + FrfOff(1)), (midp(2) - FrfOff(2)):(midp(2) + FrfOff(2))) = hfrf;
h((midp(1) - NrfOff(1)):(midp(1) + NrfOff(1)), (midp(2) - NrfOff(2)):(midp(2) + NrfOff(2))) = hnrf;
h((midp(1) - SrfOff(1)):(midp(1) + SrfOff(1)), (midp(2) - SrfOff(2)):(midp(2) + SrfOff(2))) = hsrf;
h((midp(1) - MrfOff(1)):(midp(1) + MrfOff(1)), (midp(2) - MrfOff(2)):(midp(2) + MrfOff(2))) = hmrf;

end
