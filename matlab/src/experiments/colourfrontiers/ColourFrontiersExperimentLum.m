function [] = ColourFrontiersExperimentLum()
%ColourFrontiersExperimentLum Summary of this function goes here
%   Detailed explanation goes here

%% initialisation

% cleaning the workspace
clearvars;
close all;
clc;

% creating the luminance frontiers
FrontierTable = LuminanceFrontiers();
% TODO: just a work around for now till we find real luminance of monitor
FrontierTable(:, 5:6) = cellfun(@(x) x * 100, FrontierTable(:, 5:6), 'un', 0);
% FIXME: fix the step, axes, plot borders based on the luminance level.

% find the limits of the luminance of the monitor
% FIXME: add this function
% also the max and min luminance allowed for this experiment
% [MinLum, MaxLum] = LuminanceLimits();

%% CRS setup

% setting the monitor up
crsStartup;
crsSet24bitColourMode;
crsSetColourSpace(CRS.CS_RGB);
% Gammacorrect should be turned off when showing non-linear images
crsSetVideoMode(CRS.EIGHTBITPALETTEMODE + CRS.GAMMACORRECT); %CRS.HYPERCOLOURMODE );

%% experiment parameters

ExperimentParameters = CreateExperimentParameters(CRS, 'Lum');
% TODO, this should be always all, move it from experiment parameters
ExperimentParameters.which_level = 'all';

LuminanceStep = 0.5;

%% preparing the experiment

[FrontierTable, conditions] = GetExperimentConditions(FrontierTable, ExperimentParameters);

if ExperimentParameters.plotresults
  [UniqueAB, ~, UniqueABIndeces] = unique(cell2mat(FrontierTable(:, 3:4)), 'rows');
  FigurePlanes = cell(length(UniqueAB), 2);
  FigurePlanes{1, 2} = [];
  for i = 1:size(FigurePlanes, 1)
    AvailablePosition = AvailableFigurePosition(cell2mat(FigurePlanes(:, 2)));
    FigurePlanes{i, 1} = [num2str(UniqueAB(i, 1)), '-', num2str(UniqueAB(i, 2))];
    FigurePlanes{i, 2} = figure;
    set(FigurePlanes{i, 2}, 'Name', ['Plane AB= ', FigurePlanes{i, 1}], 'NumberTitle', 'off', 'position', AvailablePosition);
    hold on;
    axis([0, 100, 0, 100]);
    % plotting all the borders at the start
    PlaneTable = FrontierTable(UniqueABIndeces == i, :);
    for j = 1:size(PlaneTable, 1)
      PlotLum(PlaneTable(j, :));
    end
  end
end

totnumruns = length(conditions);
expjunk.FinalBorders = zeros(totnumruns, 1);
expjunk.times = zeros(totnumruns, 1);

%% start of experiment

SubjectName = StartExperiment(ExperimentParameters);

crsResetTimer();

condition_elapsedtime = 0;
ExperimentCounter = 1;
for nborder = conditions
  % selecting the figure for this condition
  if ExperimentParameters.plotresults
    FigureName = [num2str(FrontierTable{nborder, 3}), '-', num2str(FrontierTable{nborder, 4})];
    FigureIndex = ~cellfun('isempty', strfind(FigurePlanes(:, 1), FigureName));
    h = FigurePlanes{FigureIndex, 2};
    figure(h);
  end
  
  % selection the borders of this condition
  % TODO: add here the a and b ...
  ColourA = lower(FrontierTable{nborder, 1});
  ColourB = lower(FrontierTable{nborder, 2});
  theplane = (FrontierTable{nborder, 5} - FrontierTable{nborder, 6}) / 2;
  CurrentLuminance = theplane;
  polcolour = cart2pol3([FrontierTable{nborder, 3} - 0.5, FrontierTable{nborder, 4} - 0.5, theplane]);
  current_angle = polcolour(1);
  current_radius = polcolour(2);
  MinLum = FrontierTable{nborder, 5};
  MaxLum = FrontierTable{nborder, 6};
  
  % generating mondrian
  % TODO: which parameters should I pass
  % FIXME: the background level must be adapted based on the colours we're testing.
  [~, ~, ~, palette] = GenerateMondrian(ExperimentParameters, current_angle, current_radius, theplane, ColourA, ColourB);
  
  wavplay(ExperimentParameters.y_DingDong, ExperimentParameters.Fs_DingDong); %#ok
  condition_starttime = crsGetTimer();
  
  % displaying experiment information
  disp('===================================');
  disp(['Current colour border: ', ColourA,' - ', ColourB]);
  disp(['Lab Plane: ', [num2str(FrontierTable{nborder, 3}), ' - ', num2str(FrontierTable{nborder, 4})]]);
  % TODO: create starting position for luminance
  disp(['Start up luminance: ', num2str(theplane), ' cd/m^2']);
  disp(['There are still ', num2str(totnumruns - ExperimentCounter - 1), ' runs to go (', num2str(round((ExperimentCounter - 1) / totnumruns * 100)), '% completed).']);
  
  % joystick loop quit condition variable
  QuitButtonPressed = 0;
  % activate joystick
  joystick on;
  
  all_buttons = [7, 8, 5, 6, 9];
  CurrentLumStep = LuminanceStep;
  
  while QuitButtonPressed == 0
    % get the joystick response.
    new_buttons = joystick('get' , all_buttons);
    Shift = 0 ;
    if new_buttons(1)
      % left correction
      Shift = Shift - CurrentLumStep;
    end
    if new_buttons(2)
      % right correction
      Shift = Shift + CurrentLumStep;
    end
    if new_buttons(3)
      % left correction
      Shift = Shift - ExperimentParameters.fastsampling * CurrentLumStep;
    end
    if new_buttons(4)
      % right correction
      Shift = Shift + ExperimentParameters.fastsampling * CurrentLumStep;
    end
    if new_buttons(5)
      % indicates last run.
      QuitButtonPressed = 1;
      condition_elapsedtime = crsGetTimer() - condition_starttime;
      wavplay(ExperimentParameters.y_ding , ExperimentParameters.Fs_ding); %#ok
      %       UpdatePlotCurrentBorder(current_angle, current_radius, ExperimentParameters.plotresults, 'or');
      plot(CurrentLuminance, 0.5, 'or');
      Shift = 0;
    end
    if Shift ~= 0
      % this pause is necessary due to behaviour of the joystick in order
      % to slow the adquisition process.
      pause(ExperimentParameters.joystickdelay);
      
      %       UpdatePlotCurrentBorder(current_angle, current_radius, ExperimentParameters.plotresults, '.b');
      plot(CurrentLuminance, 0.5, '.b');
      
      % update current angle
      CurrentLuminance = CurrentLuminance + Shift;
      if CurrentLuminance > MaxLum
        CurrentLuminance = MaxLum;
        CurrentLumStep = -CurrentLumStep;
      elseif CurrentLuminance < MinLum
        CurrentLuminance = MinLum;
        CurrentLumStep = -CurrentLumStep;
      end
      
      % update the CRT
      palette(ExperimentParameters.Central_patch_name, :) = Lab2CRSRGB(ExperimentParameters.CRS, pol2cart3([current_angle, current_radius, CurrentLuminance], 1), ExperimentParameters.refillum);
      crsPaletteSet(palette');
      %       UpdatePlotCurrentBorder(current_angle, current_radius, ExperimentParameters.plotresults, '.r');
      plot(CurrentLuminance, 0.5, '.r');
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
  expjunk.FinalBorders(ExperimentCounter) = CurrentLuminance;
  expjunk.times(ExperimentCounter) = condition_elapsedtime / 1000000;
  
  ExperimentCounter = ExperimentCounter + 1;
end

expjunk.conditions = conditions;
expjunk.blacknwhite = ExperimentParameters.BackgroundType;

%% cleaning and saving

CleanAndSave(ExperimentParameters, SubjectName, expjunk);

end

%% PlotLum

function [] = PlotLum(LumBorder)

lumm = (LumBorder{5} + LumBorder{6}) / 2;
plot([lumm, lumm], [0, 100], 'r');
text(LumBorder{5}, 0, LumBorder{1}, 'color', 'r');
text(LumBorder{6}, 0, LumBorder{2}, 'color', 'r');

end
