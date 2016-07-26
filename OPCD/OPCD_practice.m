%% Eye push script
%% AG.Mitchell, Daniela 

% This script is used to isolate oculoproprioceptive (OP) mechanisms and
% corollary discharge(CD)
% Plays a 3s beep, 
% Beep indicates that participants should push on their eye
% The conditions are randomised throughout the experiment - eyepush dark,
% orbitbone push dark, eyepush light, orbitbone push light
% When piloting, don't use these conditions because need to use the
% eye-tracker
% Voice instruction marks the start of each condition (for in the scanner)


% Daniela 20.08.08, Alex 24.11.15, Daniela 3.05.2016

%% Clean up

if exist('restart_after_error','var'),
    if ~restart_after_error,
        clear;
        restart_after_error = 0;
    end
else
    restart_after_error = 0;
end

%% SET UP FILE NAME 
datenow(1:6) = fix(clock); %Use the current date/time as a suffix to the file label to prevent overwriting
expName = 'practice_s1'; %All files from this experiment will be saved as this
matfile = ([expName, num2str(datenow(1)), num2str(datenow(2)), num2str(datenow(3)), num2str(datenow(4)), num2str(datenow(5)), num2str(datenow(6))]); 
matfilename = sprintf(matfile); 
experimentStart = GetSecs; %TimeStamp for start of the experiment

%% environment for the experiment (needed for tracker, may change with location)

dummymode=0; %1 for experiment programming 
sx=41; %cm, xscreen
sy=23;
sd=60; %cm, dist eye-screen

%% Iimport trial matrix

[Data,Text] = xlsread('TrialMatrix_prac'); %Practice;
 
Cond = Data(:, ismember(Text, 'Push')); % 1 for push, 0 for no push
nrtrials=length(Cond);

%% load the wavefiles
% This is important to load the sound files and trial length
%load wavfiles.mat; %freq 11025, duration 3 seconds each, these files instruct the condition for each block. Sound created with wavrecord
%load restwav.mat;

beepfreq=500; %Hz
cbeepfreq=700; %control beep higher freq than push beep
beepdur=3; %seconds

% make the beep to be played later on with Snd
beep=MakeBeep(beepfreq,beepdur); %push beep is three seconds long with frequency of 500 Hz
beep=beep/3; %sound intensity

cbeep=MakeBeep(cbeepfreq,beepdur); %this is the 'control' beep - higher frequency than the push beep

%% psychtoolbox initialisation

%instruction screen
try
   
    %Fullscreen for experiment
    screens = Screen('Screens');
    screenNumber = max(screens);
    %Basically gets rid of all sync warnings if not needed
    Screen('Preference', 'SkipSyncTests', 1);
    Screen('Preference','SuppressAllWarnings', 1);
    Screen('Preference','VisualDebugLevel', 0);

    %define back and white (white = 1, black = 0)
    white = WhiteIndex(screenNumber);
    black = BlackIndex(screenNumber);
    red = [255 0 0];
   
   
    if dummymode==1%For debugging use a smaller window
     [window,rect] = Screen('OpenWindow', screenNumber, black,[ RectLeft, RectTop RectLeft+800 RectTop+200]); %for testing    
    else
     [window,rect]= Screen('OpenWindow', screenNumber, black); %full screen window
    end
    [winWidth, winHeight] = WindowSize(window);  
    HideCursor;
    
 
   
    %% TEXT SIZE 
    textpt = 0.0352; %cm for 1 pt
    textsizedeg = 1.5; %degrees, visual crowding in fovea under 0.2 deg; 0.35 deg visual angle, size of one letter according to Spinelli 2002;
    textsizecm = tan(pi*textsizedeg/360)*2*sd; %in cm
    textsizept = round(textsizecm/textpt); %in pt, for some reason this number needs to be doubled
    Screen('TextSize', window, textsizept);
    
    %% DISPLAY DIMENSIONS 
    % find the size of the display
    DisplayXSize = rect(3);
    DisplayYSize = rect(4);
    midX = DisplayXSize/2;
    midY = DisplayYSize/2;
    fixcross = '+';
    
    %find pixels/cm
    vadxcm=DisplayXSize/sx; %pix per 1 cm
    vadycm=DisplayYSize/sy;
    %find pixels/degree
    vadx=vadxcm/(atan(1/sd)*180/pi); % pixels for 1 degree visual angle
    vady=vadycm/(atan(1/sd)*180/pi); % pixels for 1 degree visual angle

    frame_duration = Screen('GetFlipInterval', window);
    frame_rate = 1/frame_duration;
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    %% Piloting instructions
    DrawFormattedText(window, 'Tell the experimenter when you are ready to start the practice', 'center', 'center', white);
    Screen('Flip', window);
    KbStrokeWait; %wait for keypress
       
    %% FIXATION  
    text = '+';
    width=RectWidth(Screen ('TextBounds', window, text));
    height=RectHeight(Screen ('TextBounds', window, text));
    Screen('Flip', window);
    Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, white); %fixation cross at center
    Screen('Flip', window);

 %% Experiment starts
 
   for i=1:nrtrials
       WaitSecs(0.5); 
       %fixation cross white        
       Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, white); %fixation cross at center
       Screen('Flip', window);
       if Cond(i) == 1 %push trial
           Snd('Play', beep);
           WaitSecs(3);
           Snd('Quiet');
       else %Cond(i) == 0, control (no push) trial
           Snd('Play', cbeep);
           WaitSecs(3)
           Snd('Quiet');
       end
       WaitSecs(1); %wait 1s
       
   end
   WaitSecs(0.5);
   
   sca; %close ptb
    
catch
    % if there is an error in our try batch, this returns the user to
    % MATLAB prompt
    rethrow(lasterror);
    Screen('CloseAll');
end

%% save
save(matfilename)%this is for mat filename with all variables
