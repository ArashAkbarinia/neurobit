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
crsSetVideoMode(CRS.EIGHTBITPALETTEMODE + CRS.GAMMACORRECT); %CRS.HYPERCOLOURMODE );

%% experiment parameters

ExperimentParameters = CreateExperimentParameters(CRS, 'Arch');

%% preparing the experiment

ExperimentParameters.minradius = 10;
ExperimentParameters.maxradius = 50;
% (the margin the observer is allowed to wander outside the focus colour bracket (in radians)
ang_margin_fraction = 0.1;
ini_angularstep = 0.01; % one jnd (?)

% TODO: should I add this 'binomials'?
[FrontierTable, conditions] = GetExperimentConditions(FrontierTable, ExperimentParameters);

disp('Finding possible radioes. Please wait....');
% find the largest radious possible within the limits of the monitor
FrontierTable = NeighbourArchs(ExperimentParameters, PolarFocals, FrontierTable);

if ExperimentParameters.plotresults
  FigurePlanes = unique(FrontierTable(:, 1));
  for i = 1:length(FigurePlanes)
    FigurePlanes{i, 2} = figure;
    % TODO: add figure position
    set(FigurePlanes{i, 2}, 'Name', ['Plane L= ', FigurePlanes{i, 1}], 'NumberTitle', 'off');
    % plotting all the borders at the start
    PlaneIndex = ~cellfun('isempty', strfind(FrontierTable(:, 1), FigurePlanes{i, 1}));
    PlaneTable = FrontierTable(PlaneIndex, :);
    for j = 1:size(PlaneTable, 1)
      PlotColour(PlaneTable(j, :), PolarFocals, FigurePlanes);
    end
  end
end

totnumruns = length(conditions);
expjunk.startangles = zeros(totnumruns, 1);
expjunk.anglelimits = zeros(totnumruns, 2);
expjunk.final_angles = zeros(totnumruns, 1);
expjunk.radioes = zeros(totnumruns, 1);
expjunk.times = zeros(totnumruns, 1);
expjunk.lumplanes = zeros(totnumruns, 1);

%% start of experiment
SubjectName = StartExperiment(ExperimentParameters);

crsResetTimer();

%==========================================================================
%                CHOOSE INITAL COLOURS
%==========================================================================
condition_elapsedtime = 0;
ExperimentCounter = 1;
for borderNr = conditions
  
  if ExperimentParameters.plotresults
    FigureIndex = ~cellfun('isempty', strfind(FigurePlanes(:, 1), FrontierTable{borderNr, 1}));
    h = FigurePlanes{FigureIndex, 2};
    figure(h);
  end
  
  %======================================================================
  %                    Select border interfase
  %======================================================================
  
  [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ArchColour(FrontierTable(borderNr, :), PolarFocals, ExperimentParameters);
  
  if start_ang > end_ang
    end_ang = end_ang + 2 * pi();
  end
  
  %==========================================================================
  %                CHOOSE DISTANCES TO CENTRE
  %==========================================================================
  ang_margin = ang_margin_fraction * abs(end_ang - start_ang);
  current_radius = radioes;
  current_angle = start_ang + (end_ang - start_ang) * rand;
  expjunk.startangles(ExperimentCounter) = current_angle;
  
  %==========================================================================
  %                GENERATE MONDRIAN
  %==========================================================================
  [~, ~, ~, palette] = GenerateMondrian(ExperimentParameters, current_angle, current_radius, theplane, startcolourname, endcolourname);
  
  wavplay(ExperimentParameters.y_DingDong, ExperimentParameters.Fs_DingDong); %#ok
  condition_starttime = crsGetTimer();
  
  %==========================================================================
  %                USER INPUT
  %==========================================================================
  disp('===================================');
  disp(['Current colour border: ', startcolourname,' - ', endcolourname]);
  disp(['Radious #', num2str(ExperimentCounter), ' : ', num2str(current_radius)]);
  disp([startcolourname, ' Lab colour:  ', num2str(pol2cart3([start_ang, current_radius, theplane], 1))]);
  disp([endcolourname,   ' Lab colour:  ', num2str(pol2cart3([end_ang,   current_radius, theplane], 1))]);
  disp(['Luminance Plane: ', num2str(theplane)]);
  disp(['Start up angle: ', num2str(current_angle), ' rad']);
  % TODO: experimentcounter should start from 0.
  disp(['There are still ', num2str(totnumruns - ExperimentCounter), ' runs to go (', num2str(round(ExperimentCounter / totnumruns * 100)), '% completed).']);
  
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
  
  expjunk.anglelimits(ExperimentCounter, :) = [start_ang - ang_margin, end_ang + ang_margin];
  
  crsPaletteSet(ExperimentParameters.junkpalette);
  crsSetDisplayPage(3);
  
  disp(['Selected angle: ', num2str(current_angle), ' rad']);
  disp(['Final Lab colour: ', num2str(pol2cart3([current_angle, current_radius, theplane], 1))]);
  disp(['Time elapsed: ', num2str(condition_elapsedtime / 1000000), ' secs']);
  
  %==================================================================
  % collect results and other junk
  %==================================================================
  expjunk.final_angles(ExperimentCounter) = current_angle;
  expjunk.radioes(ExperimentCounter) = current_radius;
  expjunk.times(ExperimentCounter) = condition_elapsedtime / 1000000;
  expjunk.lumplanes(ExperimentCounter) = theplane;
  
  ExperimentCounter = ExperimentCounter + 1;
end

expjunk.conditions = conditions;
expjunk.blacknwhite = ExperimentParameters.BackgroundType;

%% cleaning and saving

CleanAndSave(ExperimentParameters, SubjectName, expjunk);

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
radioes = ExperimentParameters.minradius + (radius_pn - ExperimentParameters.minradius) * rand(1, 1);
start_ang = PoloarColourA(1);
end_ang = PoloarColourB(1);

end

%% PlotColour

function [] = PlotColour(frontier, PolarFocals, FigurePlanes)

ColourA = lower(frontier{2});
ColourB = lower(frontier{3});
labplane = str2double(frontier{1});

PoloarColourA = PolarFocals.(ColourA)((PolarFocals.(ColourA)(:, 3) == labplane), :);
PoloarColourB = PolarFocals.(ColourB)((PolarFocals.(ColourB)(:, 3) == labplane), :);

FigureIndex = ~cellfun('isempty', strfind(FigurePlanes(:, 1), frontier{1}));
h = FigurePlanes{FigureIndex, 2};
figure(h);
hold on;

pp = pol2cart3([PoloarColourA(1), frontier{4}]);
plot([pp(1), 0], [pp(2), 0], 'r');
text(pp(1), pp(2), ColourA, 'color', 'r');

pp = pol2cart3([PoloarColourB(1), frontier{4}]);
plot([pp(1), 0], [pp(2), 0], 'r');
text(pp(1), pp(2), ColourB, 'color','r');

axis([-50, 50, -50, 50]);
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
  % adding the sixth column and the allowed radius
  FrontierTableArchs(i, :) = {FrontierTable{i, :}, min(MaxRadiusAllowed, ExperimentParameters.maxradius)};
end

end
