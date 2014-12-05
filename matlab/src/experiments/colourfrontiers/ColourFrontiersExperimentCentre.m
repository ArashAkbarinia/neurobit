function [] = ColourFrontiersExperimentCentre()

%% initialisation

% cleaning the workspace
clearvars;
close all;
clc;

% creating the colour frontiers
[FrontierNames, FrontierAngles, ~] = ColourFrontiers();

% invoque the list of nameable colours from the literature
[CartFocals, ~] = FocalColours();

%% CRS setup

% setting the monitor up
crsStartup;
% crsSet24bitColourMode ;
crsSetColourSpace(CRS.CS_RGB);
% crsSetVideoMode( CRS.TRUECOLOURMODE+CRS.GAMMACORRECT ) ;
% Gammacorrect should be turned on for this experiment.
% I turn it off here because it causes the black screen to look too bright
% I will tun it on just before the begining of the experiment...
crsSetVideoMode(CRS.EIGHTBITPALETTEMODE + CRS.NOGAMMACORRECT);

%% experiment parameters

ExperimentParameters = CreateExperimentParameters(CRS, ' (low-saturated frontiers)');

%% preparing the experiment
if ExperimentParameters.BackgroundType == -1
  blacknwhite = 1;
  bkg = 'Coloured mondrians background';
elseif ExperimentParameters.BackgroundType == -2
  blacknwhite = 2;
  bkg = 'Greylevel mondrians background';
elseif ExperimentParameters.BackgroundType >= 0
  blacknwhite = 2;
  bkg = 'Plain grey background';
end

% PrepareExperiment();
numfrontiers = 19;
minradius = 0;
maxradius = 20;
ini_radialstep = 0.1;
radioNr = 1;

% pick the radioes that will be considered
if strcmpi(ExperimentParameters.which_level, 'all')
  angles = 2 .* pi() .* rand(1, ExperimentParameters.numcolconditions);
  %   colournames = FrontierNames{:, 4};
  lumlevels = zeros(1, 100);
  junklevels = randomisevector([36, 58, 81]);
  lumlevels(1:33) = junklevels(1);
  lumlevels(34:66) = junklevels(2);
  lumlevels(67:100) = junklevels(3);
  
  %   frontiers = FrontierAngles(:,1);
  angle1 = angles(1:floor(ExperimentParameters.numcolconditions / 3));
  angle2 = angles((floor(ExperimentParameters.numcolconditions / 3) + 1):(2 * floor(ExperimentParameters.numcolconditions / 3)));
  angle3 = angles((1 + 2 * floor(ExperimentParameters.numcolconditions / 3)):(mod(ExperimentParameters.numcolconditions, 3) + 3 * floor(ExperimentParameters.numcolconditions / 3)));
  
  conditions1 = PrepareConditions(1, angle1, FrontierAngles, blacknwhite, 1:6);
  conditions2 = PrepareConditions(2, angle2, FrontierAngles, blacknwhite, 7:13);
  conditions3 = PrepareConditions(3, angle3, FrontierAngles, blacknwhite, 14:19);
  
  conditions = [conditions1 conditions2 conditions3];
elseif strcmpi(ExperimentParameters.which_level, '36')
  angles = 2 .* pi() .* rand(1, ExperimentParameters.numcolconditions);
  %   colournames = FrontierNames{1:6, 4};
  lumlevels = ones(ExperimentParameters.numcolconditions, 1) .* 36;
  
  %   frontiers = FrontierAngles(1:6, 1); % w/contex
  conditions = PrepareConditions(1, angles, FrontierAngles, blacknwhite, 1:6);
  
elseif strcmpi(ExperimentParameters.which_level, '58')
  angles = 2 .* pi() .* rand(1,ExperimentParameters.numcolconditions);
  %   colournames = FrontierNames{7:13,4};
  lumlevels = ones(ExperimentParameters.numcolconditions,1) .* 58;
  
  %   frontiers = FrontierAngles(7:13,1); %w/contex
  conditions = PrepareConditions(2, angles, FrontierAngles, blacknwhite, 7:13);
  
elseif strcmpi(ExperimentParameters.which_level, '81')
  angles = 2 .* pi() .* rand(1,ExperimentParameters.numcolconditions);
  %   colournames = FrontierNames{14:19,4};
  lumlevels = ones(ExperimentParameters.numcolconditions,1) .* 81;
  
  %   frontiers = FrontierAngles(14:19,1); %w/contex
  conditions = PrepareConditions(3, angles, FrontierAngles, blacknwhite, 14:19);
else
  error('ColourFrontiersExperiment:lumnosupport', ['Luminance ', ExperimentParameters.which_level, ' is not supported.'])
end

totnumruns = length(conditions);%.* ExperimentParameters.numcolconditions;
expjunk.expresults = zeros(numfrontiers,ExperimentParameters.numcolconditions)-1;
expjunk.startangles = zeros(numfrontiers,ExperimentParameters.numcolconditions)-1;
expjunk.radioes = zeros(numfrontiers,ExperimentParameters.numcolconditions)-1;
expjunk.conditions = zeros(numfrontiers,ExperimentParameters.numcolconditions)-1;
expjunk.times = zeros(numfrontiers,ExperimentParameters.numcolconditions)-1;
expjunk.meanluminance = zeros(numfrontiers,ExperimentParameters.numcolconditions)-1;

%% start of experiment
SubjectName = StartExperiment(ExperimentParameters);

if ExperimentParameters.plotresults
  if strcmp(ExperimentParameters.which_level, '36') || strcmp(ExperimentParameters.which_level, 'all')
    h1 = figure;
    PlotGrey(FrontierNames, 1, FrontierAngles, blacknwhite, maxradius, CartFocals.green, 1, 2);
    PlotGrey(FrontierNames, 2, FrontierAngles, blacknwhite, maxradius, CartFocals.blue, 1, 2);
    PlotGrey(FrontierNames, 3, FrontierAngles, blacknwhite, maxradius, CartFocals.purple, 1, 2);
    PlotGrey(FrontierNames, 4, FrontierAngles, blacknwhite, maxradius, CartFocals.pink, 1, 2.5);
    PlotGrey(FrontierNames, 5, FrontierAngles, blacknwhite, maxradius, CartFocals.red, 1, 3);
    PlotGrey(FrontierNames, 6, FrontierAngles, blacknwhite, maxradius, CartFocals.brown, 1, 2);
    set(h1, 'Name', 'Plane L=36', 'NumberTitle', 'off');
  end
  if strcmp(ExperimentParameters.which_level, '58') || strcmp(ExperimentParameters.which_level, 'all')
    h2 = figure;
    PlotGrey(FrontierNames, 7, FrontierAngles, blacknwhite, maxradius, CartFocals.green, 2, 2);
    PlotGrey(FrontierNames, 8, FrontierAngles, blacknwhite, maxradius, CartFocals.blue, 2, 2);
    PlotGrey(FrontierNames, 9, FrontierAngles, blacknwhite, maxradius, CartFocals.purple, 2, 2);
    PlotGrey(FrontierNames, 10, FrontierAngles, blacknwhite, maxradius, CartFocals.pink, 2, 2.5);
    PlotGrey(FrontierNames, 11, FrontierAngles, blacknwhite, maxradius, CartFocals.red, 2, 3);
    PlotGrey(FrontierNames, 12, FrontierAngles, blacknwhite, maxradius, CartFocals.orange, 2, 3);
    PlotGrey(FrontierNames, 13, FrontierAngles, blacknwhite, maxradius, CartFocals.yellow, 2, 4);
    set(h2, 'Name', 'Plane L=58', 'NumberTitle', 'off');
  end
  if strcmp(ExperimentParameters.which_level, '81') || strcmp(ExperimentParameters.which_level, 'all')
    h3 = figure;
    PlotGrey(FrontierNames, 14, FrontierAngles, blacknwhite, maxradius, CartFocals.green, 3, 2);
    PlotGrey(FrontierNames, 15, FrontierAngles, blacknwhite, maxradius, CartFocals.blue, 3, 2);
    PlotGrey(FrontierNames, 16, FrontierAngles, blacknwhite, maxradius, CartFocals.purple, 3, 2);
    PlotGrey(FrontierNames, 17, FrontierAngles, blacknwhite, maxradius, CartFocals.pink, 3, 2.5);
    PlotGrey(FrontierNames, 18, FrontierAngles, blacknwhite, maxradius, CartFocals.orange, 3, 3);
    PlotGrey(FrontierNames, 19, FrontierAngles, blacknwhite, maxradius, CartFocals.yellow, 3, 3.5);
    set(h3, 'Name', 'Plane L=81', 'NumberTitle', 'off');
  end
  title(['Subject: ', SubjectName, '; Background: ', bkg]);
  axis([-maxradius maxradius -maxradius maxradius]);
end

crsSetVideoMode(CRS.EIGHTBITPALETTEMODE + CRS.GAMMACORRECT); %CRS.HYPERCOLOURMODE );
crsResetTimer();

%==========================================================================
%                CHOOSE INITAL COLOURS
%==========================================================================
condition_elapsedtime = 0;
currentrun = 0;
angleNr = 1;
for borderNr = conditions %conditions contains a list of regions from 1 to 19
  rawtimes = [];
  rawcolours = [];
  rawradius = [];
  
  %======================================================================
  %                    Select border interfase
  %======================================================================
  if round(rand)
    startcolourname = FrontierNames{conditions(angleNr), 3};
    endcolourname = 'Grey';
  else
    endcolourname = FrontierNames{conditions(angleNr), 3};
    startcolourname = 'Grey';
  end
  
  %==========================================================================
  %                CHOOSE DISTANCES TO CENTRE
  %==========================================================================
  current_angle = angles(angleNr);
  theplane = lumlevels(angleNr);
  
  current_radius = minradius + (maxradius - minradius) * rand;
  
  expjunk.startangles(borderNr, radioNr) = current_angle;
  expjunk.startradius(borderNr, radioNr) = current_radius;
  
  %==========================================================================
  %                GENERATE MONDRIAN
  %==========================================================================
  [mondrianmeanlum, RGB_colors, mymondrian, palette] = ...
    GenerateMondrian(ExperimentParameters, current_angle, current_radius, theplane, startcolourname, endcolourname);
  
  audioplayer(ExperimentParameters.y_DingDong , ExperimentParameters.Fs_DingDong); %#ok
  condition_starttime = crsGetTimer();
  
  %==========================================================================
  %                USER INPUT
  %==========================================================================
  disp('===================================');
  disp(['Current colour zone: ', FrontierNames{conditions(angleNr), 3}]);
  disp(['radius #', num2str(radioNr), ' : ' , num2str(current_radius)]);
  if ~strcmpi(startcolourname, 'Grey')
    disp([startcolourname, ' Lab colour:  ', num2str(pol2cart3([current_angle, current_radius, theplane], 1))]);
    disp([endcolourname, ' Lab colour:  0 0 ', num2str(theplane)]);
  else
    disp([startcolourname, ' Lab colour:  0 0 ', num2str(theplane)]);
    disp([endcolourname, ' Lab colour:  ', num2str(pol2cart3([current_angle, current_radius, theplane], 1))]);
  end
  disp(['Luminance Plane: ',num2str(theplane)]);
  disp(['Start up radius: ', num2str(current_radius), ' Lab units']);
  disp(['Test angle: ', num2str(current_angle), ' rad']);
  disp(['There are still ',num2str(totnumruns - currentrun), ' runs to go (',num2str(round(currentrun / totnumruns * 100)), '% completed).']);
  
  % joystick loop quit condition variable
  QuitButtonPressed = 0;
  % activate joystick
  joystick on;
  
  rawdataindex = 1;
  all_buttons = [7, 8, 5, 6, 9];
  radialstep = ini_radialstep;
  
  while QuitButtonPressed == 0
    %   Get the joystick response.
    new_buttons = joystick( 'get' , all_buttons ) ;
    Shift = 0 ;
    if new_buttons(1)
      % left correction
      Shift = Shift - radialstep;
    end
    if new_buttons(2)
      % right correction
      Shift = Shift + radialstep;
    end
    if new_buttons(3)
      % left correction
      Shift = Shift - ExperimentParameters.fastsampling * radialstep;
    end
    if new_buttons(4)
      % right correction
      Shift = Shift + ExperimentParameters.fastsampling * radialstep;
    end
    if new_buttons(5)
      % indicates last run
      QuitButtonPressed = 1;
      condition_elapsedtime = crsGetTimer() - condition_starttime;
      wavplay(ExperimentParameters.y_ding, ExperimentParameters.Fs_ding); %#ok
      UpdatePlot(current_angle, current_radius, ExperimentParameters.plotresults, 'or');
      Shift = 0;
    end
    if Shift ~= 0
      % this pause is necessary due to behaviour of the joystick in order
      % to slow the adquisition process.
      pause(ExperimentParameters.joystickdelay);
      
      UpdatePlot(current_angle, current_radius, ExperimentParameters.plotresults, '.b');
      rawtimes(rawdataindex) = crsGetTimer() - condition_starttime;
      
      % update current radius
      current_radius = current_radius + Shift;
      if current_radius > maxradius
        current_radius = maxradius;
        radialstep = -radialstep;
      end
      if current_radius < minradius
        current_radius = minradius;
        radialstep = -radialstep;
      end
      
      rawcolours(rawdataindex) = current_angle;
      rawradius(rawdataindex) = current_radius;
      rawdataindex = rawdataindex + 1;

      % update the CRT
      palette(ExperimentParameters.Central_patch_name, :) = Lab2CRSRGB(pol2cart3([current_angle, current_radius, theplane], 1), ExperimentParameters.refillum);
      crsPaletteSet(palette');
      UpdatePlot(current_angle, current_radius, ExperimentParameters.plotresults, '.r');
    end
  end
  
  % deactivate joystick
  joystick off;
  
  crsPaletteSet(ExperimentParameters.junkpalette);
  crsSetDisplayPage(3);
  disp(['Selected radius: ', num2str(current_radius), ' Lab units']);
  disp(['Final Lab colour:  ', num2str(pol2cart3([current_angle, current_radius, theplane], 1))]);
  disp(['Time elapsed: ', num2str(condition_elapsedtime/1000000), ' secs']);
  currentrun = currentrun+1;
  
  %==================================================================
  %Collect results and other junk
  %==================================================================
  nextposition = find(expjunk.expresults(borderNr,:) == -1, 1, 'first');
  expjunk.expresults(borderNr,nextposition) = current_angle;
  expjunk.radioes(borderNr,nextposition) = current_radius;
  expjunk.times(borderNr,nextposition) = condition_elapsedtime/1000000;
  expjunk.lumplanes(borderNr) = theplane;
  expjunk.meanluminance(borderNr,nextposition) = mondrianmeanlum;
  
  expjunk.RGB_colors(borderNr, nextposition).R = RGB_colors(:,1)';
  expjunk.RGB_colors(borderNr, nextposition).G = RGB_colors(:,2)';
  expjunk.RGB_colors(borderNr, nextposition).B = RGB_colors(:,3)';
  
  rawjunk(borderNr, nextposition).mondrian_RGB_colors = RGB_colors;
  rawjunk(borderNr, nextposition).times = rawtimes/1000000;
  rawjunk(borderNr, nextposition).colours = rawcolours;
  rawjunk(borderNr, nextposition).radius = rawradius;
  rawjunk(borderNr, nextposition).mondrian = mymondrian;
  rawjunk(borderNr, nextposition).palette = palette;
  
  angleNr = angleNr +1;
end

% CollectResults();
expjunk.conditions = conditions;
reshape(conditions, ceil(length(conditions) ./ ExperimentParameters.numcolconditions), ExperimentParameters.numcolconditions);
expjunk.constants.radialstep = ini_radialstep;
expjunk.constants.mybackground = ExperimentParameters.BackgroundType;

%% cleaning and saving

CleanAndSave(ExperimentParameters, SubjectName, expjunk);

end

function [] = PlotGrey(FrontierNames, n, FrontierAngles, blacknwhite, maxradius, colour, m, x)

pp = pol2cart3([FrontierAngles(n, blacknwhite), maxradius + 10]);
plot([pp(1), 0], [pp(2), 0], 'r');
hold on;
text(colour(m, 2) ./ x, colour(m, 3) ./ x, FrontierNames{n, 3}, 'color', 'r');

end
