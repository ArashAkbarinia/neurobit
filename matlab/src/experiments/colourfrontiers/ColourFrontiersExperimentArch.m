function [] = ColourFrontiersExperimentArch()

%% initialisation

% cleaning the workspace
clearvars;
close all;
clc;

% creating the colour frontiers
FrontierTable = ColourFrontiers();

% invoque the list of nameable colours from the literature
[~, PolarFocals] = FocalColours();

%% CRS setup

% setting the monitor up
crsStartup;
crsSet24bitColourMode;
crsSetColourSpace(CRS.CS_RGB);
% Gammacorrect should be turned off when showing non-linear images
crsSetVideoMode(CRS.EIGHTBITPALETTEMODE + CRS.NOGAMMACORRECT);

%% experiment parameters

ExperimentParameters = CreateExperimentParameters(CRS, 'Arch');

ExperimentParameters.maxradius = 50;
% (the margin the observer is allowed to wander outside the focus colour bracket (in radians)
ang_margin_fraction = 0.1;
ini_angularstep = 0.01; % one jnd (?)

%% preparing the experiment

% TODO: should I add this 'binomials'?
[FrontierTable, conditions] = GetExperimentConditions(FrontierTable, ExperimentParameters);

disp('Finding possible radioes. Please wait....');
% find the largest radious possible within the limits of the monitor
FrontierTable = NeighbourArchs(ExperimentParameters, PolarFocals, FrontierTable);

if ExperimentParameters.plotresults
  FigurePlanes = unique(FrontierTable(:, 1));
  FigurePlanes{1, 2} = [];
  for i = 1:size(FigurePlanes, 1)
    AvailablePosition = AvailableFigurePosition(cell2mat(FigurePlanes(:, 2)));
    FigurePlanes{i, 2} = figure;
    set(FigurePlanes{i, 2}, 'Name', ['Plane L= ', FigurePlanes{i, 1}], 'NumberTitle', 'off', 'position', AvailablePosition);
    hold on;
    % plotting all the borders at the start
    PlaneIndex = ~cellfun('isempty', strfind(FrontierTable(:, 1), FigurePlanes{i, 1}));
    PlaneTable = FrontierTable(PlaneIndex, :);
    for j = 1:size(PlaneTable, 1)
      PlotColour(PlaneTable(j, :), PolarFocals);
    end
  end
end

totnumruns = length(conditions);

% the parameters that we save in excel
ExperimentResults.angles = zeros(totnumruns, 1);
ExperimentResults.radii = zeros(totnumruns, 1);
ExperimentResults.luminances = zeros(totnumruns, 1);
ExperimentResults.times = zeros(totnumruns, 1);
ExperimentResults.conditions = conditions;
ExperimentResults.type = ExperimentParameters.ExperimentType;
ExperimentResults.background = ExperimentParameters.BackgroundType;
ExperimentResults.background = ExperimentParameters.BackgroundType;
ExperimentResults.FrontierColours = cell(totnumruns, 2);

ExperimentResults.startangles = zeros(totnumruns, 1);
ExperimentResults.anglelimits = zeros(totnumruns, 2);

%% start of experiment

SubjectName = StartExperiment(ExperimentParameters);

crsResetTimer();

condition_elapsedtime = 0;
ExperimentCounter = 1;
for borderNr = conditions
  % selecting the figure for this condition
  if ExperimentParameters.plotresults
    FigureIndex = ~cellfun('isempty', strfind(FigurePlanes(:, 1), FrontierTable{borderNr, 1}));
    h = FigurePlanes{FigureIndex, 2};
    figure(h);
  end
  
  % selection the borders of this condition
  [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ArchColour(FrontierTable(borderNr, :), PolarFocals, ExperimentParameters);
  ExperimentResults.FrontierColours(ExperimentCounter, :) = {startcolourname, endcolourname};
  
  if start_ang > end_ang
    end_ang = end_ang + 2 * pi();
  end
  
  % choose distance to centre
  ang_margin = ang_margin_fraction * abs(end_ang - start_ang);
  current_radius = radioes;
  % randomise between 0.5 to 1.0 so we wont be close to grey
  current_angle = start_ang + (end_ang - start_ang) * (0.5 * rand + 0.5);
  ExperimentResults.startangles(ExperimentCounter) = current_angle;
  
  % generating mondrian
  [~, ~, ~, palette] = GenerateMondrian(ExperimentParameters, current_angle, current_radius, theplane, startcolourname, endcolourname);
  
  wavplay(ExperimentParameters.y_DingDong, ExperimentParameters.Fs_DingDong); %#ok
  condition_starttime = crsGetTimer();
  
  % displaying experiment information
  disp('===================================');
  disp(['Current colour border: ', startcolourname,' - ', endcolourname]);
  disp(['Radious #', num2str(ExperimentCounter), ' : ', num2str(current_radius)]);
  disp([startcolourname, ' Lab colour: ', num2str(pol2cart3([start_ang, current_radius, theplane], 1))]);
  disp([endcolourname,   ' Lab colour: ', num2str(pol2cart3([end_ang,   current_radius, theplane], 1))]);
  disp(['Luminance Plane: ', num2str(theplane)]);
  disp(['Start up angle: ', num2str(current_angle), ' rad']);
  disp(['There are still ', num2str(totnumruns - ExperimentCounter - 1), ' runs to go (', num2str(round((ExperimentCounter - 1) / totnumruns * 100)), '% completed).']);
  
  % joystick loop quit condition variable
  QuitButtonPressed = 0;
  % activate joystick
  joystick on;
  
  all_buttons = [7, 8, 5, 6, 9];
  angularstep = ini_angularstep;
  
  while QuitButtonPressed == 0
    % get the joystick response.
    new_buttons = joystick('get' , all_buttons);
    Shift = 0 ;
    if new_buttons(1)
      % left correction
      Shift = Shift - angularstep;
    end
    if new_buttons(2)
      % right correction
      Shift = Shift + angularstep;
    end
    if new_buttons(3)
      % left correction
      Shift = Shift - ExperimentParameters.fastsampling * angularstep;
    end
    if new_buttons(4)
      % right correction
      Shift = Shift + ExperimentParameters.fastsampling * angularstep;
    end
    if new_buttons(5)
      % indicates last run.
      QuitButtonPressed = 1;
      condition_elapsedtime = crsGetTimer() - condition_starttime;
      wavplay(ExperimentParameters.y_ding , ExperimentParameters.Fs_ding); %#ok
      UpdatePlotCurrentBorder(current_angle, current_radius, ExperimentParameters.plotresults, 'or');
      Shift = 0;
    end
    if Shift ~= 0
      % this pause is necessary due to behaviour of the joystick in order
      % to slow the adquisition process.
      pause(ExperimentParameters.joystickdelay);
      
      UpdatePlotCurrentBorder(current_angle, current_radius, ExperimentParameters.plotresults, '.b');
      
      % update current angle
      current_angle = current_angle + Shift;
      if current_angle > end_ang + ang_margin
        current_angle = end_ang + ang_margin;
        angularstep = -angularstep;
      end
      if current_angle < start_ang - ang_margin
        current_angle = start_ang - ang_margin;
        angularstep = -angularstep;
      end
      
      % update the CRT
      palette(ExperimentParameters.Central_patch_name, :) = Lab2CRSRGB(ExperimentParameters.CRS, pol2cart3([current_angle, current_radius, theplane], 1), ExperimentParameters.refillum);
      crsPaletteSet(palette');
      UpdatePlotCurrentBorder(current_angle, current_radius, ExperimentParameters.plotresults, '.r');
    end
  end
  
  % deactivate joystick
  joystick off;
  
  crsPaletteSet(ExperimentParameters.junkpalette);
  crsSetDisplayPage(3);
  
  % displaying the final selected border
  disp(['Selected angle: ', num2str(current_angle), ' rad']);
  disp(['Final Lab colour: ', num2str(pol2cart3([current_angle, current_radius, theplane], 1))]);
  disp(['Time elapsed: ', num2str(condition_elapsedtime / 1000000), ' secs']);
  
  % collect results and other junk
  ExperimentResults.angles(ExperimentCounter) = current_angle;
  ExperimentResults.radii(ExperimentCounter) = current_radius;
  ExperimentResults.luminances(ExperimentCounter) = theplane;
  ExperimentResults.times(ExperimentCounter) = condition_elapsedtime / 1000000;
  
  ExperimentResults.anglelimits(ExperimentCounter, :) = [start_ang - ang_margin, end_ang + ang_margin];
  
  ExperimentCounter = ExperimentCounter + 1;
end

%% cleaning and saving

CleanAndSave(ExperimentParameters, SubjectName, ExperimentResults);

end

%% ArchColour

function [radioes, start_ang, end_ang, labplane, ColourA, ColourB] = ArchColour(frontier, PolarFocals, ExperimentParameters)

ColourA = lower(frontier{2});
ColourB = lower(frontier{3});
labplane = str2double(frontier{1});

PoloarColourA = PolarFocals.(ColourA)((PolarFocals.(ColourA)(:, 3) == labplane), :);
PoloarColourB = PolarFocals.(ColourB)((PolarFocals.(ColourB)(:, 3) == labplane), :);

disp(['luminance: ', frontier{1}, ', ', ColourA, '-', ColourB, ' border selected']);
radius_pn = frontier{4};
minradius = 0.95 * radius_pn;
radioes = minradius + (radius_pn - minradius) * rand(1, 1);
start_ang = PoloarColourA(1);
end_ang = PoloarColourB(1);

end

%% PlotColour

function [] = PlotColour(frontier, PolarFocals)

ColourA = lower(frontier{2});
ColourB = lower(frontier{3});
labplane = str2double(frontier{1});

PoloarColourA = PolarFocals.(ColourA)((PolarFocals.(ColourA)(:, 3) == labplane), :);
PoloarColourB = PolarFocals.(ColourB)((PolarFocals.(ColourB)(:, 3) == labplane), :);

pp = pol2cart3([PoloarColourA(1), frontier{4}]);
plot([pp(1), 0], [pp(2), 0], 'r');
text(pp(1), pp(2), ColourA, 'color', 'r');

pp = pol2cart3([PoloarColourB(1), frontier{4}]);
plot([pp(1), 0], [pp(2), 0], 'r');
text(pp(1), pp(2), ColourB, 'color', 'r');

refresh;

end

%% NeighbourArchs

function FrontierTableArchs = NeighbourArchs(ExperimentParameters, PolarFocals, FrontierTable)

crs = ExperimentParameters.CRS;

[rows, cols] = size(FrontierTable);
FrontierTableArchs = cell(rows, cols + 1);

for i = 1:rows
  labplane = str2double(lower(FrontierTable{i, 1}));
  ColourA = lower(FrontierTable{i, 2});
  ColourB = lower(FrontierTable{i, 3});
  PoloarColourA = PolarFocals.(ColourA)((PolarFocals.(ColourA)(:, 3) == labplane), :);
  PoloarColourB = PolarFocals.(ColourB)((PolarFocals.(ColourB)(:, 3) == labplane), :);
  MaxRadiusAllowed = find_max_rad_allowed(crs, PoloarColourA(1), PoloarColourB(1), labplane);
  % adding the last column and the allowed radius
  FrontierTableArchs(i, :) = {FrontierTable{i, :}, max(MaxRadiusAllowed, ExperimentParameters.maxradius)};
end

end
