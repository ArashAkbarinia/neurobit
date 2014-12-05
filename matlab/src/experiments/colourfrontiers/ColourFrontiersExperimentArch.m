function [] = ColourFrontiersExperimentArch()

%% initialisation

% cleaning the workspace
clearvars;
close all;
clc;

% invoque the list of nameable colours from the literature
[~, PolarFocals] = FocalColours();

%% CRS setup

% setting the monitor up
crsStartup;
crsSet24bitColourMode;
crsSetColourSpace(CRS.CS_RGB);
% crsSetVideoMode( CRS.TRUECOLOURMODE+CRS.GAMMACORRECT ) ;
% Gammacorrect should be turned off when showing non-linear images
crsSetVideoMode(CRS.EIGHTBITPALETTEMODE + CRS.GAMMACORRECT); %CRS.HYPERCOLOURMODE );

%% experiment parameters

ExperimentParameters = CreateExperimentParameters(CRS, '');

%% preparing the experiment

% PrepareExperiment();
labplane1 = 36;
labplane2 = 58;
labplane3 = 81;
numfrontiers = 19;

ExperimentParameters.minradius = 10;
ExperimentParameters.maxradius = 50;
% (the margin the observer is allowed to wander outside the focus colour bracket (in radians)
ang_margin_fraction = 0.1;
ini_angularstep = 0.01; % one jnd (?)
leftfigposition   = [-9,   514, 560, 420];
centrefigposition = [562,  467, 560, 420];
rightfigposition  = [1125, 515, 560, 420];

conditions = [];
switch ExperimentParameters.which_level
  case 'all'
    for i = 1:ExperimentParameters.numcolconditions
      conditions = [conditions, randomisevector((1:numfrontiers))];
    end
    
  case 'binomials' %borders that gave binomial distributions using the previous paradigm
    for i = 1:ExperimentParameters.numcolconditions
      conditions = [conditions, randomisevector([1, 3, 5, 7, 9, 10, 14, 15, 16])];
    end
    
  case '36'
    for i = 1:ExperimentParameters.numcolconditions
      conditions = [conditions, randomisevector((1:6))];
    end
  case '58'
    for i = 1:ExperimentParameters.numcolconditions
      conditions = [conditions, randomisevector((7:13))];
    end
  case '81'
    for i = 1:ExperimentParameters.numcolconditions
      conditions = [conditions, randomisevector((14:19))];
    end
end

totnumruns = length(conditions);%.* ExperimentParameters.numcolconditions;
expjunk.expresults = zeros(numfrontiers, ExperimentParameters.numcolconditions);
expjunk.startangles = zeros(numfrontiers, ExperimentParameters.numcolconditions);
expjunk.radioes = zeros(numfrontiers, ExperimentParameters.numcolconditions);
expjunk.conditions = zeros(numfrontiers, ExperimentParameters.numcolconditions);
expjunk.times = zeros(numfrontiers, ExperimentParameters.numcolconditions);
anglelimits = zeros(numfrontiers, 2);

%% start of experiment
SubjectName = StartExperiment(ExperimentParameters);

disp('Finding possible radioes. Please wait....');
% find the largest radious possible within the limits of the monitor
archs = NeighbourArchs(PolarFocals, labplane1, labplane2, labplane3, ExperimentParameters.maxradius);

if ExperimentParameters.plotresults
  % FIXME: only show the figures which is necesarry
  h1 = figure;
  set(h1, 'Name', ['Plane L= ', num2str(labplane1)], 'NumberTitle', 'off', 'Position', leftfigposition);
  h2 = figure;
  set(h2, 'Name', ['Plane L= ', num2str(labplane2)], 'NumberTitle', 'off', 'Position', centrefigposition);
  h3 = figure;
  set(h3, 'Name', ['Plane L= ', num2str(labplane3)], 'NumberTitle', 'off', 'Position', rightfigposition);
end

crsResetTimer();

%==========================================================================
%                CHOOSE INITAL COLOURS
%==========================================================================
condition_elapsedtime = 0;
currentrun = 0;
flag = 0;
for borderNr = conditions
  rawtimes = [];
  rawcolours = [];
  
  %======================================================================
  %                    Select border interfase
  %======================================================================
  radioNr = floor(flag / (length(conditions) ./ ExperimentParameters.numcolconditions)) + 1;
  flag = flag + 1;

  [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
    SelectColourBorder(borderNr, archs, PolarFocals, ExperimentParameters, labplane1, labplane2, labplane3, h1, h2, h3);
  
  if start_ang > end_ang
    end_ang = end_ang + 2 * pi();
  end
  
  %==========================================================================
  %                CHOOSE DISTANCES TO CENTRE
  %==========================================================================
  ang_margin = ang_margin_fraction * abs(end_ang - start_ang);
  current_radius = radioes;
  current_angle = start_ang + (end_ang - start_ang) * rand;
  expjunk.startangles(borderNr, radioNr) = current_angle;
  
  %==========================================================================
  %                GENERATE MONDRIAN
  %==========================================================================
  [mondrianmeanlum, RGB_colors, mymondrian, palette] = ...
    GenerateMondrian(ExperimentParameters, current_angle, current_radius, theplane, startcolourname, endcolourname);
  
  wavplay(ExperimentParameters.y_DingDong, ExperimentParameters.Fs_DingDong); %#ok
  condition_starttime = crsGetTimer();
  
  %==========================================================================
  %                USER INPUT
  %==========================================================================
  disp('===================================');
  disp(['Current colour border: ', startcolourname,' - ', endcolourname]);
  disp(['Radious #', num2str(radioNr), ' : ', num2str(current_radius)]);
  disp([startcolourname, ' Lab colour:  ', num2str(pol2cart3([start_ang, current_radius, theplane], 1))]);
  disp([endcolourname,   ' Lab colour:  ', num2str(pol2cart3([end_ang,   current_radius, theplane], 1))]);
  disp(['Luminance Plane: ', num2str(theplane)]);
  disp(['Start up angle: ', num2str(current_angle), ' rad']);
  disp(['There are still ', num2str(totnumruns - currentrun), ' runs to go (', num2str(round(currentrun / totnumruns * 100)), '% completed).']);
  
  % joystick loop quit condition variable
  QuitButtonPressed = 0;
  % activate joystick
  joystick on;
  
  rawdataindex = 1;
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
      UpdatePlot(current_angle, current_radius, ExperimentParameters.plotresults, 'or');
      Shift = 0;
    end
    if Shift ~= 0
      % this pause is necessary due to behaviour of the joystick in order
      % to slow the adquisition process.
      pause(ExperimentParameters.joystickdelay);
      
      UpdatePlot(current_angle, current_radius, ExperimentParameters.plotresults, '.b');
      rawtimes(rawdataindex) = crsGetTimer() - condition_starttime;
      
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
      
      rawcolours(rawdataindex) = current_angle;
      rawdataindex = rawdataindex + 1;
      
      % update the CRT
      palette(ExperimentParameters.Central_patch_name, :) = Lab2CRSRGB(pol2cart3([current_angle, current_radius, theplane], 1), ExperimentParameters.refillum);
      crsPaletteSet(palette');
      UpdatePlot(current_angle, current_radius, ExperimentParameters.plotresults, '.r');
    end
  end
  
  % deactivate joystick
  joystick off;
  
  anglelimits(borderNr, :) = [start_ang - ang_margin, end_ang + ang_margin];
  
  crsPaletteSet(ExperimentParameters.junkpalette);
  crsSetDisplayPage(3);
  
  disp(['Selected angle: ', num2str(current_angle), ' rad']);
  disp(['Final Lab colour:  ', num2str(pol2cart3([current_angle, current_radius, theplane], 1))]);
  disp(['Time elapsed: ', num2str(condition_elapsedtime / 1000000), ' secs']);
  currentrun = currentrun + 1;
  
  %==================================================================
  %Collect results and other junk
  %==================================================================
  expjunk.expresults(borderNr, radioNr) = current_angle;
  expjunk.radioes(borderNr, radioNr) = current_radius;
  expjunk.times(borderNr, radioNr) = condition_elapsedtime / 1000000;
  expjunk.lumplanes(borderNr, radioNr) = theplane;
  expjunk.meanluminance(borderNr, radioNr) = mondrianmeanlum;
  rawjunk(borderNr, radioNr).mondrian_RGB_colors = RGB_colors;
  rawjunk(borderNr, radioNr).times = rawtimes / 1000000;
  rawjunk(borderNr, radioNr).colours = rawcolours;
  rawjunk(borderNr, radioNr).mondrian = mymondrian;
  rawjunk(borderNr, radioNr).palette = palette;
end

% CollectResults();
expjunk.conditions = conditions;
reshape(conditions, ceil(length(conditions) ./ ExperimentParameters.numcolconditions), ExperimentParameters.numcolconditions);
expjunk.constants.blacknwhite = ExperimentParameters.BackgroundType;
expjunk.constants.anglelimits = anglelimits;

%% cleaning and saving

CleanAndSave(ExperimentParameters, SubjectName, expjunk);

end

%% other function

function [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
  SelectColourBorder(borderNr, archs, PolarFocals, ExperimentParameters, labplane1, labplane2, labplane3, h1, h2, h3)

minradius = ExperimentParameters.minradius;

% FIXME: make it based on luminance, dont pass all to it
switch borderNr
  case 1
    [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
      ArchColour(archs, PolarFocals, 'Green', 'Blue', ExperimentParameters.plotresults, labplane1, minradius, h1, 1);
  case 2
    [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
      ArchColour(archs, PolarFocals, 'Blue', 'Purple', ExperimentParameters.plotresults, labplane1, minradius, h1, 1);
  case 3
    [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
      ArchColour(archs, PolarFocals, 'Purple', 'Pink', ExperimentParameters.plotresults, labplane1, minradius, h1, 1);
  case 4
    [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
      ArchColour(archs, PolarFocals, 'Pink', 'Red', ExperimentParameters.plotresults, labplane1, minradius, h1, 1);
  case 5
    [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
      ArchColour(archs, PolarFocals, 'Red', 'Brown', ExperimentParameters.plotresults, labplane1, minradius, h1, 1);
  case 6
    [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
      ArchColour(archs, PolarFocals, 'Brown', 'Green', ExperimentParameters.plotresults, labplane1, minradius, h1, 1);
  case 7
    [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
      ArchColour(archs, PolarFocals, 'Green', 'Blue', ExperimentParameters.plotresults, labplane2, minradius, h2, 2);
  case 8
    [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
      ArchColour(archs, PolarFocals, 'Blue', 'Purple', ExperimentParameters.plotresults, labplane2, minradius, h2, 2);
  case 9
    [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
      ArchColour(archs, PolarFocals, 'Purple', 'Pink', ExperimentParameters.plotresults, labplane2, minradius, h2, 2);
  case 10
    [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
      ArchColour(archs, PolarFocals, 'Pink', 'Red', ExperimentParameters.plotresults, labplane2, minradius, h2, 2);
  case 11
    [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
      ArchColour(archs, PolarFocals, 'Red', 'Orange', ExperimentParameters.plotresults, labplane2, minradius, h2, 2);
  case 12
    [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
      ArchColour(archs, PolarFocals, 'Orange', 'Yellow', ExperimentParameters.plotresults, labplane2, minradius, h2, 2);
  case 13
    [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
      ArchColour(archs, PolarFocals, 'Yellow', 'Green', ExperimentParameters.plotresults, labplane2, minradius, h2, 2);
  case 14
    [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
      ArchColour(archs, PolarFocals, 'Green', 'Blue', ExperimentParameters.plotresults, labplane3, minradius, h3, 3);
  case 15
    [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
      ArchColour(archs, PolarFocals, 'Blue', 'Purple', ExperimentParameters.plotresults, labplane3, minradius, h3, 3);
  case 16
    [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
      ArchColour(archs, PolarFocals, 'Purple', 'Pink', ExperimentParameters.plotresults, labplane3, minradius, h3, 3);
  case 17
    [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
      ArchColour(archs, PolarFocals, 'Pink', 'Orange', ExperimentParameters.plotresults, labplane3, minradius, h3, 3);
  case 18
    [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
      ArchColour(archs, PolarFocals, 'Orange', 'Yellow', ExperimentParameters.plotresults, labplane3, minradius, h3, 3);
  case 19
    [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
      ArchColour(archs, PolarFocals, 'Yellow', 'Green', ExperimentParameters.plotresults, labplane3, minradius, h3, 3);
end

end
