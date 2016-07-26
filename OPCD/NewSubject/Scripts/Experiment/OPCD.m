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
expName = 'OPCD_pushAM'; %All files from this experiment will be saved as this
matfile = ([expName, num2str(datenow(1)), num2str(datenow(2)), num2str(datenow(3)), num2str(datenow(4)), num2str(datenow(5)), num2str(datenow(6))]); 
matfilename = sprintf(matfile); 
experimentStart = GetSecs; %TimeStamp for start of the experiment


%% environment for the experiment (needed for tracker, may change with location)

dummymode=0; %1 for experiment programming 
practiceMode=0;
eet=1; %eyelink
sx=41; %cm, xscreen
sy=23;
sd=60; %cm, dist eye-screen
eye=2; %binocular eye measurements
edfFile = 'eyeBi.edf'; %name of the eye-data file


%% IMPORT TRIAL MATRIX 
if 0
if practiceMode == 0 
    [Data,Text] = xlsread('TrialMatrixExp'); 
else 
    [Data,Text] = xlsread('TrialMatrixExpPractice');%Pract');
end 
trialMatrix(:, 1) = Data(:, ismember(Text, 'Cond')); % 1 for OP, 2 for CD
nrtrials=length(trialMatrix);
end
nrtrials=15;
%% load the wavefiles
% This is important to load the sound files and trial length
%load wavfiles.mat; %freq 11025, duration 3 seconds each, these files instruct the condition for each block. Sound created with wavrecord
%load restwav.mat;



beepfreq=500; %Hz
beepdur=3; %seconds


% log arrays
op=[]; %closed eye push
opc=[]; %closed eye control (push on orbit bone)
cd=[]; %open eye push
cdc=[]; %open eye control (orbit bone)
a=[]; %temporary array stores onsets
ops=[]; %onset of first beep in block
opcs=[];
cds=[];
cdcs=[];

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
   
   
    if dummymode==1%For debugging use a smaller window
     [window,rect] = Screen('OpenWindow', screenNumber, black,[ RectLeft, RectTop RectLeft+800 RectTop+200]); %for testing    
    else
     [window,rect]= Screen('OpenWindow', screenNumber, black); %full screen window
    end
    [winWidth, winHeight] = WindowSize(window);  
    HideCursor;
    
 
   
    %% TEXT SIZE 
    textpt = 0.0352; %cm for 1 pt
    textsizedeg = 1; %degrees, visual crowding in fovea under 0.2 deg; 0.35 deg visual angle, size of one letter according to Spinelli 2002;
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


 
 %% CALIBRATION SETTING (SAVED IN THE SAME FILE) 
    %Prepare and calibrate eyetracker, if connected 
    if eet
        % Hide the mouse cursor.
         HideCursor;
          if ~EyelinkInit(dummymode)
            fprintf('Eyelink Init aborted.\n');
            cleanup;  % cleanup function
            return;
          end
    %Defaults changed to black background with white text/red fix points 
    el=EyelinkInitDefaults(window);
    %eye_used = 1; 
    Eyelink('Openfile',edfFile);
    Eyelink('command', 'add_file_preamble_text ''Recorded with EyelinkII''');
    Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, winWidth-1, winHeight-1);
    Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, winWidth-1, winHeight-1);
    horizontalCalTarget = num2str(rect(4)/2); 
    Eyelink('command', ['horizontal_target_y =', horizontalCalTarget]); 
    el.calibrationtargetcolour = [255 0 0];
    el.backgroundcolour = BlackIndex(el.window);
    el.msgfontcolour = WhiteIndex(el.window);
    EyelinkUpdateDefaults(el);
    Eyelink('command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA'); 
    Eyelink('StartRecording');
    EyelinkDoTrackerSetup(el); %press space to accept, press Enter to move to Validation, press ESC to return to program
    EyelinkDoDriftCorrection(el);
    WaitSecs(0.1);
    end 
    if eet
    Eyelink('command', 'set_idle_mode'); %pause recording
    end
  
    %% Piloting instructions
    DrawFormattedText(window, 'Gently push under your right eye', 'center', 'center', white);
    Screen('Flip', window);
    KbStrokeWait; %wait for keypress
    
    
    %% FIXATION  
        text = '+';
        width=RectWidth(Screen ('TextBounds', window, text));
        height=RectHeight(Screen ('TextBounds', window, text));
        Screen('Flip', window);
        Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, white); %fixation cross at center
        Screen('Flip', window);

    
    % Start recording with eyetracker
    if eet 
        Eyelink('StartRecording');
        Eyelink('Message', 'SYNCTIME');
    end

 %% Experiment starts
 

   for i=1:nrtrials
       
       %fixation cross           
       WaitSecs(0.5);
       if eet
          Eyelink('Message', 'SOUNDON'); %send eet message that fixation is ON; prediction - push eye static, non push eye moves
       end
       Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, white); %fixation cross at center
       Screen('Flip', window);  
       WaitSecs(3);
       %remove cross
       Screen('Flip', window); 
       if eet
          Eyelink('Message', 'SOUNDEND'); %send eet message that fixation is off; prediction - push eye moves, non push eye static
       end
       WaitSecs(0.5);
       
   end
   WaitSecs(0.5);
   
    sca; %close ptb

    if eet
                Eyelink('StopRecording'); %stop eyelink recording
                Eyelink('CloseFile');
    end


    %% Download data file, retrieve data and draw plots from eyedata at stimulus onset

    if eet
            try
                fprintf('Receiving data file ''%s''\n', edfFile );
                status=Eyelink('ReceiveFile');
                if status > 0
                    fprintf('ReceiveFile status %d\n', status);
                end
                if 2==exist(edfFile, 'file')
                    fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
                end
            catch
                fprintf('Problem receiving data file ''%s''\n', edfFile );
            end
            %convert to ASCII,- sp is only pupil location, extract both
            %eyes
           !edf2asc eyeBi -sp

    Screen('CloseAll');
    
% convert unreadable edf file into readable asc file    
        [EH, EJ, EX] = dbrede_read_edfsnd('eyeBi.asc'); % asc file data
        datenow(1:6) = fix(clock);
        eyeSaveName = ['EYE'  num2str(datenow(1)), num2str(datenow(2)), num2str(datenow(3)), num2str(datenow(4)), num2str(datenow(5)), num2str(datenow(6))];
        save(eyeSaveName, 'EH', 'EJ', 'EX');
        disp('Eye movement data ready for further analysis'); 
        disp(' '); 
        
% plotting eye data into graphs of time vs. saccade amplitude (x and y)
        %eyedata = dbrede_read_edfsnd('eyeA.asc') - %don't need, in line
        %above
        time = EH.matrix(:,1);
        LXsaccAmp = EH.matrix(:,2); %for lx
        LYsaccAmp = EH.matrix(:,3); %for ly
        RXsaccAmp = EH.matrix(:,5); %for rx
        RYsaccAmp = EH.matrix(:,6); %for ry
        %soundon = EH.matrix(:,9); %eye data retreived when sound is on
            figure(1)
            plot(time,LXsaccAmp);
            figure(2)
            plot(time,LYsaccAmp);
            figure(3)
            plot(time,RXsaccAmp);
            figure(4)
            plot(time,RYsaccAmp);

    end
catch
    % if there is an error in our try batch, this returns the user to
    % MATLAB prompt
    rethrow(lasterror);
    Screen('CloseAll');
    
    if eet
        Eyelink('StopRecording');
        Eyelink('CloseFile');
        Eyelink('ShutDown');
    end
end



%% save
save(matfilename)%this is for mat filename with all variables
