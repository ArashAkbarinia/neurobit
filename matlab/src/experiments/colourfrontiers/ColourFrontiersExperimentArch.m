function [] = ColourFrontiersExperimentArch()

%% initialisation

% cleaning the workspace
clearvars;
close all;

% number of samples in the mondrian background
numsamples = 200;

% invoque the list of nameable colours from the literature
[~, PolarFocals] = FocalColours();

resultsdir = 'D:\Results\ColorCategorizationMondrian\';
[y_ding , Fs_ding , nbits_ding] = wavread('D:\MatLab_m-files\Visage\Jordi\sound\sound_ding.wav'); %#ok
[y_DingDong , Fs_DingDong , nbits_DingDong] = wavread('D:\MatLab_m-files\Visage\Jordi\sound\DingDong.wav'); %#ok

%% CRS setup

% setting the monitor up
crsStartup;
crsSet24bitColourMode;
crsSetColourSpace(CRS.CS_RGB);
% crsSetVideoMode( CRS.TRUECOLOURMODE+CRS.GAMMACORRECT ) ;
% Gammacorrect should be turned off when showing non-linear images
crsSetVideoMode(CRS.EIGHTBITPALETTEMODE + CRS.GAMMACORRECT); %CRS.HYPERCOLOURMODE );
% Height = crsGetScreenHeightPixels;
% Width  = crsGetScreenWidthPixels;

%% experiment parameters

% 'all'        --> does all conditions (may take too long!!)
% '36'         --> does only the low luminance boders
% '58'         --> does only the mid-luminance borders
% '81'         --> does only the hight luminance borders
% 'binomials'  --> does only the borders that gave binomial distributions
%                  using the previous paradigm
which_level = '58';

% x >= 0  --> no mondrians, presents colours on a grey background with
%             luminance 'x'.
% x = -1  --> does only luminance mondrians
% x = -2  --> does colour mondrians
% a white "frame" is present in all conditions
BackgroundType = 0;

% time in seconds for the dark adaptation period (should be 120)
darkadaptation = 10;
endexppause = 15;

% the TOTAL number of conditions. It should be 50 by default.
numcolconditions = 10;

%% preparing the experiment

PrepareExperiment();
minradius = 10;
maxradius = 50;
% (the margin the observer is allowed to wander outside the focus colour bracket (in radians)
ang_margin_fraction = 0.1;
ini_angularstep = 0.01; % one jnd (?)
leftfigposition   = [-9,   514, 560, 420];
centrefigposition = [562,  467, 560, 420];
rightfigposition  = [1125, 515, 560, 420];
conditions = [];

switch which_level
  case 'all'
    for i = 1:numcolconditions
      conditions = [conditions, randomisevector((1:numfrontiers))];
    end
    
  case 'binomials' %borders that gave binomial distributions using the previous paradigm
    for i = 1:numcolconditions
      conditions = [conditions, randomisevector([1, 3, 5, 7, 9, 10, 14, 15, 16])];
    end
    
  case '36'
    for i = 1:numcolconditions
      conditions = [conditions, randomisevector((1:6))];
    end
  case '58'
    for i = 1:numcolconditions
      conditions = [conditions, randomisevector((7:13))];
    end
  case '81'
    for i = 1:numcolconditions
      conditions = [conditions, randomisevector((14:19))];
    end
end
totnumruns = length(conditions);%.* numcolconditions;
expjunk.expresults = zeros(numfrontiers, numcolconditions);
expjunk.startangles = zeros(numfrontiers, numcolconditions);
expjunk.radioes = zeros(numfrontiers, numcolconditions);
expjunk.conditions = zeros(numfrontiers, numcolconditions);
expjunk.times = zeros(numfrontiers, numcolconditions);
anglelimits = zeros(numfrontiers, 2);

%% start of experiment
SubjectName = StartExperiment(blackpalette, CRS, Black_palette_name, answer, darkadaptation, junkpalette);

disp('Finding possible radioes. Please wait....');
% find the largest radious possible within the limits of the monitor
archs = NeighbourArchs(PolarFocals, labplane1, labplane2, labplane3, maxradius);
if plotresults
  h1 = figure; %axis([-maxradius maxradius -maxradius maxradius]), axis ('square');
  set(h1, 'Name', ['Plane L= ', num2str(labplane1)], 'NumberTitle', 'off', 'Position', leftfigposition);
  h2 = figure; %axis([-maxradius maxradius -maxradius maxradius]), axis ('square');
  set(h2, 'Name', ['Plane L= ', num2str(labplane2)], 'NumberTitle', 'off', 'Position', centrefigposition);
  h3 = figure; %axis([-maxradius maxradius -maxradius maxradius]), axis ('square');
  set(h3, 'Name', ['Plane L= ', num2str(labplane3)], 'NumberTitle', 'off', 'Position', rightfigposition);
end

crsResetTimer();
%==========================================================================
%                CHOOSE INITAL COLOURS
%==========================================================================

flag = 0;
for borderNr = conditions
  %======================================================================
  %                    Select border interfase
  %======================================================================
  radioNr = floor(flag/(length(conditions)./numcolconditions))+1;
  flag = flag+1;
  switch borderNr
    case 1
      [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
        ArchColour(archs, PolarFocals, 'Green', 'Blue', plotresults, labplane1, minradius, h1, 1);
    case 2
      [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
        ArchColour(archs, PolarFocals, 'Blue', 'Purple', plotresults, labplane1, minradius, h1, 1);
    case 3
      [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
        ArchColour(archs, PolarFocals, 'Purple', 'Pink', plotresults, labplane1, minradius, h1, 1);
    case 4
      [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
        ArchColour(archs, PolarFocals, 'Pink', 'Red', plotresults, labplane1, minradius, h1, 1);
    case 5
      [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
        ArchColour(archs, PolarFocals, 'Red', 'Brown', plotresults, labplane1, minradius, h1, 1);
    case 6
      [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
        ArchColour(archs, PolarFocals, 'Brown', 'Green', plotresults, labplane1, minradius, h1, 1);
    case 7
      [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
        ArchColour(archs, PolarFocals, 'Green', 'Blue', plotresults, labplane2, minradius, h2, 2);
    case 8
      [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
        ArchColour(archs, PolarFocals, 'Blue', 'Purple', plotresults, labplane2, minradius, h2, 2);
    case 9
      [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
        ArchColour(archs, PolarFocals, 'Purple', 'Pink', plotresults, labplane2, minradius, h2, 2);
    case 10
      [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
        ArchColour(archs, PolarFocals, 'Pink', 'Red', plotresults, labplane2, minradius, h2, 2);
    case 11
      [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
        ArchColour(archs, PolarFocals, 'Red', 'Orange', plotresults, labplane2, minradius, h2, 2);
    case 12
      [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
        ArchColour(archs, PolarFocals, 'Orange', 'Yellow', plotresults, labplane2, minradius, h2, 2);
    case 13
      [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
        ArchColour(archs, PolarFocals, 'Yellow', 'Green', plotresults, labplane2, minradius, h2, 2);
    case 14
      [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
        ArchColour(archs, PolarFocals, 'Green', 'Blue', plotresults, labplane3, minradius, h3, 3);
    case 15
      [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
        ArchColour(archs, PolarFocals, 'Blue', 'Purple', plotresults, labplane3, minradius, h3, 3);
    case 16
      [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
        ArchColour(archs, PolarFocals, 'Purple', 'Pink', plotresults, labplane3, minradius, h3, 3);
    case 17
      [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
        ArchColour(archs, PolarFocals, 'Pink', 'Orange', plotresults, labplane3, minradius, h3, 3);
    case 18
      [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
        ArchColour(archs, PolarFocals, 'Orange', 'Yellow', plotresults, labplane3, minradius, h3, 3);
    case 19
      [radioes, start_ang, end_ang, theplane, startcolourname, endcolourname] = ...
        ArchColour(archs, PolarFocals, 'Yellow', 'Green', plotresults, labplane3, minradius, h3, 3);
  end
  
  if plotresults
    refresh;
  end
  
  if start_ang > end_ang
    end_ang = end_ang + 2 * pi();
  end
  %==========================================================================
  %                CHOOSE DISTANCES TO CENTRE
  %==========================================================================
  
  ang_margin = ang_margin_fraction * abs(end_ang - start_ang);
  %==========================================================================
  %                CHOOSE DISTANCES TO CENTRE
  %==========================================================================
  current_radius = radioes;
  current_angle = start_ang + (end_ang - start_ang) * rand;
  expjunk.startangles(borderNr, radioNr) = current_angle;
  
  %==========================================================================
  %                GENERATE MONDRIAN
  %==========================================================================
  [mondrianmeanlum, RGB_colors, mymondrian, palette, Height, Width] = ...
    GenerateMondrian(BackgroundType, refillum, numsamples, MondrianParameters, CRS, ExperimentParameters, ...
    Black_palette_name, Central_patch_name, current_angle, current_radius, frame_name, shadow_name, D65_RGB, ...
    theplane);
  
  crsDrawString([-(Width / 2 - textposition_x), Height / 2 - textposition_y], startcolourname);
  crsDrawString([ (Width / 2 - textposition_x), Height / 2 - textposition_y], endcolourname);
  wavplay(y_DingDong, Fs_DingDong);
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
  
  %Joystick loop quit condition variable
  out = 0;
  %Activate joystick
  joystick on;
  rawdataindex = 1;
  %shift_step = 0.1 ;
  all_buttons = [ 7 8 5 6 9 ] ;
  angularstep = ini_angularstep;
  
  while out == 0
    %   Get the joystick response.
    new_buttons = [ 0 0 0 0 0 ];
    new_buttons = joystick('get' , all_buttons);
    Shift = 0 ;
    if new_buttons(1)
      Shift = Shift - angularstep;        %   left correction
    end
    if new_buttons(2)
      Shift = Shift + angularstep;        %   right correction
    end
    if new_buttons(3)
      Shift = Shift - fastsampling * angularstep;        %   left correction
    end
    if new_buttons(4)
      Shift = Shift + fastsampling * angularstep;        %   right correction
    end
    if new_buttons(5)
      out = 1;                             %   Indicates last run.
      condition_elapsedtime = crsGetTimer() - condition_starttime;
      wavplay(y_ding , Fs_ding);
      if plotresults
        pp = pol2cart3([current_angle, current_radius]);
        plot(pp(1), pp(2), 'or');
        hold on;
        refresh
      end
      Shift = 0;
    end
    if Shift ~= 0
      %   This pause is necessary due to behaviour of the joystick in
      %   order to slow the adquisition process.
      pause(joystickdelay);
      if plotresults
        pp = pol2cart3([current_angle, current_radius]);
        plot(pp(1),pp(2),'.b');
        hold on;
        refresh;
      end
      rawtimes(rawdataindex) = (crsGetTimer() - condition_starttime);
      %   Update current_angle.
      
      current_angle = current_angle + Shift ;
      
      if ( current_angle > end_ang + ang_margin )
        current_angle = end_ang + ang_margin;
        angularstep = -angularstep;
      end
      
      if ( current_angle < start_ang - ang_margin )
        current_angle = start_ang - ang_margin;
        angularstep = -angularstep;
      end
      
      %                 if (current_angle > end_ang + ang_margin)||(current_angle < start_ang - ang_margin)
      %                     disp('WRONG ANGLE');
      %                 end
      rawcolours(rawdataindex) = current_angle;
      rawdataindex = rawdataindex+1;
      %   Update the CRT.
      testcolourRGB=Lab2CRSRGB(pol2cart3([current_angle, current_radius, theplane],1),refillum);
      palette(Central_patch_name,:)= testcolourRGB ;
      crsPaletteSet(palette');
      %disp(['          Current angle: ', num2str(current_angle), ' rad']);
      if plotresults
        pp = pol2cart3([current_angle, current_radius]);
        plot(pp(1),pp(2),'.r');
        hold on;
        refresh;
      end
    end
  end
  %   Deactivate Joystick.
  joystick off ;
  anglelimits(borderNr,:)=[ start_ang-ang_margin, end_ang+ang_margin ];
  crsPaletteSet(junkpalette);
  crsSetDisplayPage(3);
  disp(['Selected angle: ', num2str(current_angle), ' rad']);
  disp(['Final Lab colour:  ', num2str(pol2cart3([current_angle, current_radius, theplane],1))]);
  disp(['Time elapsed: ', num2str(condition_elapsedtime/1000000), ' secs']);
  currentrun = currentrun+1;
  %==================================================================
  %Collect results and other junk
  %==================================================================
  expjunk.expresults(borderNr, radioNr) = current_angle;
  expjunk.radioes(borderNr, radioNr) = current_radius;
  expjunk.times(borderNr, radioNr) = condition_elapsedtime/1000000;
  expjunk.lumplanes(borderNr, radioNr) = theplane;
  expjunk.meanluminance(borderNr, radioNr) = mondrianmeanlum;
  %         expjunk.RGB_colors(borderNr, radioNr).R = RGB_colors(:,1)';
  %         expjunk.RGB_colors(borderNr, radioNr).G = RGB_colors(:,2)';
  %         expjunk.RGB_colors(borderNr, radioNr).B = RGB_colors(:,3)';
  rawjunk(borderNr, radioNr).mondrian_RGB_colors = RGB_colors; RGB_colors = [];
  rawjunk(borderNr, radioNr).times = rawtimes/1000000; rawtimes = [];
  rawjunk(borderNr, radioNr).colours = rawcolours; rawcolours = [];
  rawjunk(borderNr, radioNr).mondrian = mymondrian; mymondrian = [];
  rawjunk(borderNr, radioNr).palette = palette; palette = [];
end

CollectResults();
expjunk.constants.blacknwhite = BackgroundType;
expjunk.constants.anglelimits = anglelimits;

%% cleaning and saving

ExperimentType = '';
CleanAndSave(junkpalette, y_DingDong, Fs_DingDong, resultsdir, SubjectName, ExperimentType, expjunk, endexppause);

end
