%% initialisation

clearvars;
crsStartup;

% cleaning the workspace
clear expjunk rawjunk;
close all;

% creating the colour frontiers
[FrontierNames, FrontierAngles, DesaturatedFrontiers] = ColourFrontiers();

% number of samples in the mondrian background
numsamples = 200;

% invoque the list of nameable colours from the literature
[CartFocals, PolarFocals] = FocalColours();

resultsdir = 'D:\Results\ColorCategorizationMondrian\';
[y_ding, Fs_ding, nbits_ding] = wavread('D:\MatLab_m-files\Visage\Jordi\sound\sound_ding.wav'); %#ok
[y_DingDong, Fs_DingDong, nbits_DingDong] = wavread('D:\MatLab_m-files\Visage\Jordi\sound\DingDong.wav'); %#ok

%% CRS setup

% setting the monitor up
% crsSet24bitColourMode ;
crsSetColourSpace(CRS.CS_RGB);
% crsSetVideoMode( CRS.TRUECOLOURMODE+CRS.GAMMACORRECT ) ;
% Gammacorrect should be turned on for this experiment.
% I turn it off here because it causes the black screen to look too bright
% I will tun it on just before the begining of the experiment...
crsSetVideoMode(CRS.EIGHTBITPALETTEMODE + CRS.NOGAMMACORRECT);
% Height = crsGetScreenHeightPixels;
% Width  = crsGetScreenWidthPixels;

%% experiment parameters

% 'all'        --> does all conditions (may take too long!!)
% '36'         --> does only the low luminance boders
% '58'         --> does only the mid-luminance borders
% '81'         --> does only the hight luminance borders
% 'binomials'  --> does only the borders that gave binomial distributions
%                  using the previous paradigm
which_level = '81';

% x >= 0  --> no mondrians, presents colours on a grey background with
%             luminance 'x'.
% x = -1  --> does only luminance mondrians
% x = -2  --> does colour mondrians
% a white "frame" is present in all conditions
mybackground = 0;

% time in seconds for the dark adaptation period (should be 120)
darkadaptation = 10;
endexppause = 15;

% the TOTAL number of conditions. It should be 50 by default.
numcolconditions = 10;

%% preparing the experiment
if mybackground == -1
  blacknwhite = 1;
  bkg = 'Coloured mondrians background';
elseif mybackground == -2
  blacknwhite = 2;
  bkg = 'Greylevel mondrians background';
elseif mybackground >= 0
  blacknwhite = 2;
  bkg = 'Plain grey background';
end

PrepareExperiment();
minradius = 0;
maxradius = 20;
ini_angularstep = 0.0; % one jnd (?)
ini_radialstep = 0.1;
radioNr = 1;

% pick the radioes that will be considered
if strcmpi(which_level, 'all')
  angles = 2 .* pi() .* rand(1, numcolconditions);
  colournames = FrontierNames{:, 4};
  lumlevels = zeros(1, 100);
  junklevels = randomisevector([36, 58, 81]);
  lumlevels(1:33) = junklevels(1);
  lumlevels(34:66) = junklevels(2);
  lumlevels(67:100) = junklevels(3);
  clear junklevels;
  
  frontiers = FrontierAngles(:,1);
  angle1 = angles(1:floor(numcolconditions / 3));
  angle2 = angles((floor(numcolconditions / 3) + 1):(2 * floor(numcolconditions / 3)));
  angle3 = angles((1 + 2 * floor(numcolconditions / 3)):(mod(numcolconditions, 3) + 3 * floor(numcolconditions / 3)));
  
  conditions1 = PrepareConditions(1, angle1, FrontierAngles, blacknwhite, 1:6);
  conditions2 = PrepareConditions(2, angle2, FrontierAngles, blacknwhite, 7:13);
  conditions3 = PrepareConditions(3, angle3, FrontierAngles, blacknwhite, 14:19);
  
  conditions = [conditions1 conditions2 conditions3];
elseif strcmpi(which_level, '36')
  angles = 2 .* pi() .* rand(1, numcolconditions);
  colournames = FrontierNames{1:6, 4};
  lumlevels = ones(numcolconditions, 1) .* 36;
  
  frontiers = FrontierAngles(1:6, 1); % w/contex
  conditions = PrepareConditions(1, angles, FrontierAngles, blacknwhite, 1:6);
  
elseif strcmpi(which_level, '58')
  angles = 2 .* pi() .* rand(1,numcolconditions);
  colournames = FrontierNames{7:13,4};
  lumlevels = ones(numcolconditions,1) .* 58;
  
  frontiers = FrontierAngles(7:13,1); %w/contex
  conditions = PrepareConditions(2, angles, FrontierAngles, blacknwhite, 7:13);
  
elseif strcmpi(which_level, '81')
  angles = 2 .* pi() .* rand(1,numcolconditions);
  colournames = FrontierNames{14:19,4};
  lumlevels = ones(numcolconditions,1) .* 81;
  
  frontiers = FrontierAngles(14:19,1); %w/contex
  conditions = PrepareConditions(3, angles, FrontierAngles, blacknwhite, 14:19);
else
  error('ColourFrontiersExperiment:lumnosupport', ['Luminance ', which_level, ' is not supported.'])
end

totnumruns = length(conditions);%.* numcolconditions;
expjunk.expresults = zeros(numfrontiers,numcolconditions)-1;
expjunk.startangles = zeros(numfrontiers,numcolconditions)-1;
expjunk.radioes = zeros(numfrontiers,numcolconditions)-1;
expjunk.conditions = zeros(numfrontiers,numcolconditions)-1;
expjunk.times = zeros(numfrontiers,numcolconditions)-1;
expjunk.meanluminance = zeros(numfrontiers,numcolconditions)-1;
%anglelimits = zeros(numfrontiers,2)-1;

%% start of experiment
StartExperiment();

if plotresults
  if strcmp(which_level, '36') || strcmp(which_level, 'all')
    h1= figure;
    pp = Alej_pol2cart([FrontierAngles(1,blacknwhite), maxradius + 10]);
    plot([pp(1),0],[pp(2),0],'r'); hold on;
    text(CartFocals.green(1,2)./2,CartFocals.green(1,3)./2, FrontierNames{1,3}, 'color', 'r');
    
    pp = Alej_pol2cart([FrontierAngles(2,blacknwhite), maxradius + 10]);
    plot([pp(1),0],[pp(2),0],'r'); hold on;
    text(CartFocals.blue(1,2)./2,CartFocals.blue(1,3)./2, FrontierNames{2,3}, 'color', 'r');
    
    pp = Alej_pol2cart([FrontierAngles(3,blacknwhite), maxradius + 10]);
    plot([pp(1),0],[pp(2),0],'r'); hold on;
    text(CartFocals.purple(1,2)./2,CartFocals.purple(1,3)./2, FrontierNames{3,3}, 'color', 'r');
    
    pp = Alej_pol2cart([FrontierAngles(4,blacknwhite), maxradius + 10]);
    plot([pp(1),0],[pp(2),0],'r'); hold on;
    text(CartFocals.pink(1,2)./2.5,CartFocals.pink(1,3)./2.5, FrontierNames{4,3}, 'color', 'r');
    
    pp = Alej_pol2cart([FrontierAngles(5,blacknwhite), maxradius + 10]);
    plot([pp(1),0],[pp(2),0],'r'); hold on;
    text(CartFocals.red(1,2)./3,CartFocals.red(1,3)./3, FrontierNames{5,3}, 'color', 'r');
    
    pp = Alej_pol2cart([FrontierAngles(6,blacknwhite), maxradius + 10]);
    plot([pp(1),0],[pp(2),0],'r'); hold on;
    text(CartFocals.brown(1,2)./2,CartFocals.brown(1,3)./2, FrontierNames{6,3}, 'color', 'r');
    set(h1,'Name','Plane L= 36','NumberTitle','off');
  end
  
  if strcmp(which_level, '58') || strcmp(which_level, 'all')
    h2= figure;
    pp = Alej_pol2cart([FrontierAngles(7,blacknwhite), maxradius + 10]);
    plot([pp(1),0],[pp(2),0],'r'); hold on;
    text(CartFocals.green(2,2)./2,CartFocals.green(2,3)./2, FrontierNames{7,3}, 'color', 'r');
    
    pp = Alej_pol2cart([FrontierAngles(8,blacknwhite), maxradius + 10]);
    plot([pp(1),0],[pp(2),0],'r'); hold on;
    text(CartFocals.blue(2,2)./2,CartFocals.blue(2,3)./2, FrontierNames{8,3}, 'color', 'r');
    
    pp = Alej_pol2cart([FrontierAngles(9,blacknwhite), maxradius + 10]);
    plot([pp(1),0],[pp(2),0],'r'); hold on;
    text(CartFocals.purple(2,2)./2,CartFocals.purple(2,3)./2, FrontierNames{9,3}, 'color', 'r');
    
    pp = Alej_pol2cart([FrontierAngles(10,blacknwhite), maxradius + 10]);
    plot([pp(1),0],[pp(2),0],'r'); hold on;
    text(CartFocals.pink(2,2)./2.5,CartFocals.pink(2,3)./2.5, FrontierNames{10,3}, 'color', 'r');
    
    pp = Alej_pol2cart([FrontierAngles(11,blacknwhite), maxradius + 10]);
    plot([pp(1),0],[pp(2),0],'r'); hold on;
    text(CartFocals.red(2,2)./3,CartFocals.red(2,3)./3, FrontierNames{11,3}, 'color', 'r');
    
    pp = Alej_pol2cart([FrontierAngles(12,blacknwhite), maxradius + 10]);
    plot([pp(1),0],[pp(2),0],'r'); hold on;
    text(CartFocals.orange(2,2)./3,CartFocals.orange(2,3)./3, FrontierNames{12,3}, 'color', 'r');
    
    pp = Alej_pol2cart([FrontierAngles(13,blacknwhite), maxradius + 10]);
    plot([pp(1),0],[pp(2),0],'r'); hold on;
    text(CartFocals.yellow(2,2)./4,CartFocals.yellow(2,3)./4, FrontierNames{13,3}, 'color', 'r');
    set(h2,'Name','Plane L= 58','NumberTitle','off');
  end
  if strcmp(which_level, '81') || strcmp(which_level, 'all')
    h3= figure; %axis([-maxradius maxradius -maxradius maxradius]), axis ('square');
    pp = Alej_pol2cart([FrontierAngles(14,blacknwhite), maxradius + 10]);
    plot([pp(1),0],[pp(2),0],'r'); hold on;
    text(CartFocals.green(3,2)./2,CartFocals.green(3,3)./2, FrontierNames{14,3}, 'color', 'r');
    
    pp = Alej_pol2cart([FrontierAngles(15,blacknwhite), maxradius + 10]);
    plot([pp(1),0],[pp(2),0],'r'); hold on;
    text(CartFocals.blue(3,2)./2,CartFocals.blue(3,3)./2, FrontierNames{15,3}, 'color', 'r');
    
    pp = Alej_pol2cart([FrontierAngles(16,blacknwhite), maxradius + 10]);
    plot([pp(1),0],[pp(2),0],'r'); hold on;
    text(CartFocals.purple(3,2)./2,CartFocals.purple(3,3)./2, FrontierNames{16,3}, 'color', 'r');
    
    pp = Alej_pol2cart([FrontierAngles(17,blacknwhite), maxradius + 10]);
    plot([pp(1),0],[pp(2),0],'r'); hold on;
    text(CartFocals.pink(3,2)./2.5,CartFocals.pink(3,3)./2.5, FrontierNames{17,3}, 'color', 'r');
    
    pp = Alej_pol2cart([FrontierAngles(18,blacknwhite), maxradius + 10]);
    plot([pp(1),0],[pp(2),0],'r'); hold on;
    text(CartFocals.orange(3,2)./3,CartFocals.orange(3,3)./3, FrontierNames{18,3}, 'color', 'r');
    
    pp = Alej_pol2cart([FrontierAngles(19,blacknwhite), maxradius + 10]);
    plot([pp(1),0],[pp(2),0],'r'); hold on;
    text(CartFocals.yellow(3,2)./3.5,CartFocals.yellow(3,3)./3.5, FrontierNames{19,3}, 'color', 'r');
    set(h3,'Name','Plane L= 81','NumberTitle','off');
  end
  title(['Subject: ', SubjectName, '; Background: ', bkg]);
  axis([-maxradius maxradius -maxradius maxradius]);
end
crsSetVideoMode(CRS.EIGHTBITPALETTEMODE + CRS.GAMMACORRECT); %CRS.HYPERCOLOURMODE );
crsResetTimer();

%==========================================================================
%                CHOOSE INITAL COLOURS
%==========================================================================

% flag = 0;
angleNr = 1;
for borderNr = conditions %conditions contains a list of regions from 1 to 19
  
  %ang_margin = ang_margin_fraction*abs(end_ang-start_ang);
  %==========================================================================
  %                CHOOSE DISTANCES TO CENTRE
  %==========================================================================
  %current_radius = radioes;
  current_angle = angles(angleNr);
  theplane = lumlevels(angleNr);
  
  %current_angle = start_ang + (end_ang-start_ang) * rand;
  current_radius = minradius + (maxradius-minradius) * rand;
  
  expjunk.startangles(borderNr, radioNr) = current_angle;
  expjunk.startradius(borderNr, radioNr) = current_radius;
  
  %==========================================================================
  %                GENERATE MONDRIAN
  %==========================================================================
  
  arashground = mybackground;
  
  GenerateMondrian();
  
  %==========================================================================
  %                USER INPUT
  %==========================================================================
  disp('===================================');
  disp(['Current colour zone: ', FrontierNames{conditions(angleNr),3}]);
  disp(['radius #',num2str(radioNr),' : ',num2str(current_radius)]);
  if  round(rand)
    startcolourname = FrontierNames{conditions(angleNr),3};
    endcolourname = 'Grey';
    disp([startcolourname,' Lab colour:  ', num2str(Alej_pol2cart([current_angle, current_radius, theplane],1))]);
    disp([endcolourname,' Lab colour:  0 0 ', num2str(theplane) ]);
  else
    endcolourname = FrontierNames{conditions(angleNr),3};
    startcolourname = 'Grey';
    disp([startcolourname,' Lab colour:  0 0 ', num2str(theplane) ]);
    disp([endcolourname,' Lab colour:  ', num2str(Alej_pol2cart([current_angle, current_radius, theplane],1))]);
  end
  disp(['Luminance Plane: ',num2str(theplane)]);
  disp(['Start up radius: ', num2str(current_radius), ' Lab units']);
  disp(['Test angle: ', num2str(current_angle), ' rad']);
  disp(['There are still ',num2str(totnumruns - currentrun), ' runs to go (',num2str(round(currentrun/totnumruns*100)),'% completed).']);
  crsDrawString([-(Width/2-textposition_x),Height/2-textposition_y],startcolourname);
  crsDrawString([(Width/2-textposition_x),Height/2-textposition_y],endcolourname);
  audioplayer(y_DingDong , Fs_DingDong);
  condition_starttime = crsGetTimer();
  
  %Joystick loop quit condition variable
  out = 0 ;
  %Activate joystick
  joystick on ;
  rawdataindex = 1;
  %shift_step = 0.1 ;
  all_buttons = [ 7 8 5 6 9 ] ;
  radialstep = ini_radialstep;
  
  while ( out == 0 )
    %   Get the joystick response.
    new_buttons = [ 0 0 0 0 0 ] ;
    new_buttons = joystick( 'get' , all_buttons ) ;
    Shift = 0 ;
    if ( new_buttons( 1 )  )
      Shift = Shift - radialstep ;        %   left correction
    end
    if ( new_buttons( 2 ) )
      Shift = Shift + radialstep ;        %   right correction
    end
    if ( new_buttons( 3 )  )
      Shift = Shift - fastsampling*radialstep ;        %   left correction
    end
    if ( new_buttons( 4 )  )
      Shift = Shift + fastsampling*radialstep ;        %   right correction
    end
    if ( new_buttons( 5 )  )
      out = 1 ;                             %   Indicates last run.
      condition_elapsedtime = crsGetTimer() - condition_starttime;
      wavplay( y_ding , Fs_ding ) ;
      if plotresults
        pp = Alej_pol2cart([current_angle, current_radius]);
        plot(pp(1),pp(2),'or');
        hold on;
        refresh
      end
      Shift = 0;
    end
    if Shift~=0
      %   This pause is necessary due to behaviour of the joystick in
      %   order to slow the adquisition process.
      pause( joystickdelay ) ;
      if plotresults
        pp = Alej_pol2cart([current_angle, current_radius]);
        plot(pp(1),pp(2),'.b');
        hold on;
        refresh;
      end
      rawtimes(rawdataindex) = (crsGetTimer() - condition_starttime);
      %   Update current_angle.
      
      current_radius = current_radius + Shift ;
      
      if (current_radius > maxradius)
        current_radius = maxradius;
        radialstep = -radialstep;
      end
      
      if (current_radius < minradius )
        current_radius = minradius;
        radialstep = -radialstep;
      end
      
      rawcolours(rawdataindex) = current_angle; %current_radius;
      rawradius(rawdataindex) = current_radius;
      rawdataindex = rawdataindex+1;
      %   Update the CRT.
      testcolourRGB=Lab2CRSRGB(Alej_pol2cart([current_angle, current_radius, theplane],1),refillum);
      palette(Central_patch_name,:)= testcolourRGB ;
      crsPaletteSet(palette');
      %disp(['          Current angle: ', num2str(current_angle), ' rad']);
      if plotresults
        pp = Alej_pol2cart([current_angle, current_radius]);
        plot(pp(1),pp(2),'.r');
        hold on;
        refresh;
      end
    end
  end
  %   Deactivate Joystick.
  joystick off ;
  %radiuslimits(borderNr,:)=[ start_ang-ang_margin, end_ang+ang_margin ];
  crsPaletteSet(junkpalette);
  crsSetDisplayPage(3);
  disp(['Selected radius: ', num2str(current_radius), ' Lab units']);
  disp(['Final Lab colour:  ', num2str(Alej_pol2cart([current_angle, current_radius, theplane],1))]);
  disp(['Time elapsed: ', num2str(condition_elapsedtime/1000000), ' secs']);
  currentrun = currentrun+1;
  
  %==================================================================
  %Collect results and other junk
  %==================================================================
  %radioNr = 1
  
  
  nextposition = find(expjunk.expresults(borderNr,:)== -1, 1, 'first');
  expjunk.expresults(borderNr,nextposition) = current_angle;
  expjunk.radioes(borderNr,nextposition) = current_radius;
  expjunk.times(borderNr,nextposition) = condition_elapsedtime/1000000;
  expjunk.lumplanes(borderNr) = theplane;
  expjunk.meanluminance(borderNr,nextposition) = mondrianmeanlum;
  
  %expjunk.expresults(borderNr, angleNr) = current_angle;
  %expjunk.radioes(borderNr, angleNr) = current_radius;
  %expjunk.times(borderNr, angleNr) = condition_elapsedtime/1000000;
  %expjunk.lumplanes(borderNr, angleNr) = theplane;
  %expjunk.meanluminance(borderNr, radioNr) = mondrianmeanlum;
  expjunk.RGB_colors(borderNr, nextposition).R = RGB_colors(:,1)';
  expjunk.RGB_colors(borderNr, nextposition).G = RGB_colors(:,2)';
  expjunk.RGB_colors(borderNr, nextposition).B = RGB_colors(:,3)';
  
  
  rawjunk(borderNr, nextposition).mondrian_RGB_colors = RGB_colors; RGB_colors = [];
  rawjunk(borderNr, nextposition).times = rawtimes/1000000; rawtimes = [];
  rawjunk(borderNr, nextposition).colours = rawcolours; rawcolours = [];
  rawjunk(borderNr, nextposition).radius = rawradius; rawradius = [];
  rawjunk(borderNr, nextposition).mondrian = mymondrian; mymondrian = [];
  rawjunk(borderNr, nextposition).palette = palette; palette = [];
  
  angleNr = angleNr +1;
end

CollectResults();
expjunk.constants.radialstep =  ini_radialstep;
expjunk.constants.mybackground = mybackground;
%expjunk.constants.anglelimits = anglelimits;

%% cleaning and saving

ExperimentType = ' (low-saturated frontiers)';
CleanAndSave();