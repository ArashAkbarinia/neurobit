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
% crsSetVideoMode( CRS.TRUECOLOURMODE+CRS.GAMMACORRECT ) ;
% Gammacorrect should be turned off when showing non-linear images
crsSetVideoMode(CRS.EIGHTBITPALETTEMODE + CRS.GAMMACORRECT); %CRS.HYPERCOLOURMODE );

%% experiment parameters

ExperimentParameters = CreateExperimentParameters(CRS, '');

%% preparing the experiment

% PrepareExperiment();
numfrontiers = 19;

ExperimentParameters.minradius = 10;
ExperimentParameters.maxradius = 50;
% (the margin the observer is allowed to wander outside the focus colour bracket (in radians)
ang_margin_fraction = 0.1;
ini_angularstep = 0.01; % one jnd (?)

% FIXME: should I add this 'binomials'?
[FrontierTableLumX, conditions] = GetExperimentConditions(FrontierTable, ExperimentParameters);

disp('Finding possible radioes. Please wait....');
% find the largest radious possible within the limits of the monitor
FrontierTableLumXArchs = NeighbourArchs(ExperimentParameters, PolarFocals, FrontierTableLumX);

if ExperimentParameters.plotresults
  FigurePlanes = unique(FrontierTableLumX(:, 1));
  for i = 1:length(FigurePlanes)
    FigurePlanes{i, 2} = figure;
    % TODO: add figure position
    set(FigurePlanes{i, 2}, 'Name', ['Plane L= ', FigurePlanes{i}], 'NumberTitle', 'off');
  end
end

totnumruns = length(conditions);
expjunk.expresults = zeros(numfrontiers, ExperimentParameters.numcolconditions);
expjunk.startangles = zeros(numfrontiers, ExperimentParameters.numcolconditions);
expjunk.radioes = zeros(numfrontiers, ExperimentParameters.numcolconditions);
expjunk.conditions = zeros(numfrontiers, ExperimentParameters.numcolconditions);
expjunk.times = zeros(numfrontiers, ExperimentParameters.numcolconditions);
anglelimits = zeros(numfrontiers, 2);

%% start of experiment
SubjectName = StartExperiment(ExperimentParameters);

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
  radioNr = floor(flag / (totnumruns ./ ExperimentParameters.numcolconditions)) + 1;
  flag = flag + 1;

  [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
      ArchColour(FrontierTableLumXArchs(borderNr, :), PolarFocals, ExperimentParameters, FigurePlanes);

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
      palette(ExperimentParameters.Central_patch_name, :) = Lab2CRSRGB(ExperimentParameters.CRS, pol2cart3([current_angle, current_radius, theplane], 1), ExperimentParameters.refillum);
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
reshape(conditions, ceil(totnumruns ./ ExperimentParameters.numcolconditions), ExperimentParameters.numcolconditions);
expjunk.constants.blacknwhite = ExperimentParameters.BackgroundType;
expjunk.constants.anglelimits = anglelimits;

%% cleaning and saving

CleanAndSave(ExperimentParameters, SubjectName, expjunk);

end

%% other functions

function [FrontierTableLumX, conditions] = GetExperimentConditions(FrontierTable, ExperimentParameters)

luminance = ExperimentParameters.which_level;
nconditions = ExperimentParameters.numcolconditions;

if strcmp(luminance, 'all')
  FrontierTableLumX = FrontierTable;
else
  indeces = ~cellfun('isempty', strfind(FrontierTable(:, 1), luminance));
  FrontierTableLumX = FrontierTable(indeces, :);
end

nfrontiers = size(FrontierTableLumX, 1);

conditions = zeros(1, nconditions * nfrontiers);
for i = 1:nconditions
  j = (i - 1) * nfrontiers;
  indeces = (j + 1):(j + nfrontiers);
  conditions(indeces) = randomisevector(1:nfrontiers);
end

end
