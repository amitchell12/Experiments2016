%% AG.Mitchell - 22.03.16
%% Exogenous attention paradigm relative to cue
%% PRACTICE - ONLY 30 TRIALS
% To pilot timing difference between cue and target 
% Presents a target (A or H) on the left or the right, 8 degrees away from
% fixation cross
% Participants have to identify target letter using their voice
% Some conditions (240/360) a cue is present (either on the left or the
% right), followed by a valie or invalid target
% The timing between the cue (framed rectangle) and the target varies
% between simultanoues presentation, exogenous (200ms) and IOR (850ms)
% The cue and the target are both presented for 100ms
% 240 trials in total, 3 factors: cue condition (invalid/valid/no cue), target side
% (left/right), timing differences (simultaneous, exo, IOR)
% Measures VRT and RT to a keypress from experimenter, and accuracy of
% response
% Variation on the Posner attention task

%% Alex and Daniela 30.11.2015, using Barthel's script from the attention experiment Odoj and Balslev 2015
% Alex: added SMI_REDm eye tracking bits to this code instead of using Eyelink II.
% Code taken from 'RedmExampleCode.m' which is an edited version of
% 'DataStreaming.m', edited by BR.Innes

%% Clear all variables, connections, ...
clear all
clc
warning('off', 'all');
   
connected = 1; %if using smi, test if connected (1-yes, 0-no)
%% environment for the experiment

dummymode=0; %?practice?
smi=0; %SMI REDm camera? 0 - no, 1 - yes
sx=31; %cm, xscreen
sy=18; %cm yscreen
sd=57; %cm, dist eye-screen
eye=2; %number of eyes being recorded
audio = 0;
ParticipantID = 'practice';
%% Time and space variables
starttime=0.4; %cross
fixtimemax=0.25; %seconds
fixtimemin=0.1; %seconds
rectduration=0.1; %length of cue, seconds
recttimemax=0.09; %seconds, to avoid a saccade that takes 200 ms to prepare
recttimemin=0.04; %seconds
startime = 0.05; %length of temporally predictive cue, seconds
IOR = 0.75; %seconds inbetween cue and target for IOR (timing = 2)
exo = 0.1; %seconds inbetween cue and target for exogenous (timing = 1)

waittimemax=10000;%seconds, second stimulus and a response, 2AFC
letters(1)='A'; %target (key press - 1)
letters(2)='H'; %target (key press - 4)

targettime=0.100; %time of target onset

%% for voice RT
voicetrigger = 0.15;
%adjust mic sensibility
maxsecs = 0.01; %10 ms data recording

%% text size variables

textpt=0.0352; %cm for 1 pt
textsizedeg=1; %degrees, visual crowding in fovea under 0.2 deg; 0.35 deg visual angle, size of one letter according to Spinelli 2002
textsizecm=tan(pi*textsizedeg/360)*2*sd; %in cm
textsizept=2*round(textsizecm/textpt); %in pt, for some reason this number needs to be doubled
xcuedeg=8; %deg visual angle from center of screen 
sizecuedeg=3; %deg visual angle size of the cue rectangle
sizetargdeg=2; %deg visual angle of target

%% Trial variables

% read trial variables from an xls file
[Data,Text] = xlsread('TrialCounter_pilotpractice.xlsx');

TargetLetter =  Data(:, ismember(Text, 'TargetLetter')); %defining target from xls file (A/H)TargetLetter: 1-A, 2-H
Cue = Data(:, ismember(Text, 'Cue')); %defining cue on/off and side. 0 -  no cue, 1 - cue left, 2 - cue right
TargetSide = Data(:, ismember(Text, 'TargetSide')); %defining the side of target, 1 - left, 2 - right
Timing = Data(:, ismember(Text, 'Time')); %time between cue and target onset 0 - simultaneous, 1 - exogenous (100ms), 2 - IOR (750ms)

% Conditions:


nrtrials = length(Cue); %trials, total nr
%nrtrials = 20; %for testing
%% correct response keys
leftKey = KbName('1'); %this is a number that identifies the key; letter A
rightKey = KbName('4'); %letter H

%% OUTPUT

%preallocation of variables, for the output
ActualResponse=[]; 
CorrectResponse=[];
timecuestart=[];
timecueend=[];
timetargetend=[];
timetargetstart =[];
timekeypress=[];
VRT = [];
RT=[];

%prepare correct response lists
for i=1:nrtrials %for all trials run in the sequence
    if TargetLetter(i)==1 %if the target letter = A
        CorrectResponse(i)=leftKey; %this is the code for the key (leftkey = 1)
        Stimulus(i) = 'A';
    end

    if  TargetLetter(i)==2 %if the target letter = H
        CorrectResponse(i)=rightKey; %this is the code for the key (rightkey = 4)
        Stimulus(i) = 'H';
    end

end

%% OUTPUT
% Output file where variables can be saved, and output variables
datenow = clock;
matfilename = sprintf ('Attention_practice%d%d%d%d%d.mat', datenow (1), datenow(2), datenow(3), datenow(4), datenow(5)); %name of the output file

perNoCue=0; %output variables
pervalid=0; %divided into valid, no cue and invalid trials
perinvalid=0;
nrvalid=0;
nrinvalid=0;
nrNoCue=0;
rtNoCue=0;
rtvalid=0;
rtinvalid=0;
fpvalid = 0;
fpNoCue = 0;
fpinvalid=0;
%% Load the iViewX API library of functions
% Setting up iViewX for running with the experiment
if smi
    loadlibrary('iViewXAPI.dll', 'iViewXAPI.h'); %loading SMI library


    [pSystemInfoData, pSampleData, pEventData, pAccuracyData, CalibrationData] = InitiViewXAPI();

    CalibrationData.method = int32(9); %set up calibration
    CalibrationData.visualization = int32(1);

    %B: if display device is not zero I find the validation will crash, so be
    %careful 

    CalibrationData.displayDevice = int32(0); %type of display
    CalibrationData.speed = int32(0); %how fast dot travels
    CalibrationData.autoAccept = int32(1); %don't need to press spacebar 
    CalibrationData.foregroundBrightness = int32(250); %brightness of dots
    CalibrationData.backgroundBrightness = int32(230); %brightness of background screen
    CalibrationData.targetShape = int32(2); %shape of calibration target
    CalibrationData.targetSize = int32(20); %size of calibration target
    CalibrationData.targetFilename = int8(''); %filename for saving
    pCalibrationData = libpointer('CalibrationStruct', CalibrationData); %calibration running information


    disp('Define Logger')
    calllib('iViewXAPI', 'iV_SetLogger', int32(1), formatString(256, int8('iViewXSDK_Matlab_AttentionLVFcue_.txt'))); %save calibration here
end
%% Connect iViewXAPI - alter IP addresses

%B: The first IP is the IP of the SMI, the second is that of the laptop
%running this script. You might need to make sure these are properly adjusted.  
% SMI: 192.168.1.1
% Laptop: 192.168.1.2

if smi
    disp('Connect to iViewX') %connecting to eyetracker system
    ret = calllib('iViewXAPI', 'iV_Connect', formatString(16, int8('192.168.1.1')), int32(4444), formatString(16, int8('192.168.1.2')), int32(5555)); %inputing IP addresses and port information so can connect
    switch ret
        case 1
            connected = 1; %if connected
        case 104 %alternative cases if not connected, listing possibilities and what could be done
             msgbox('Could not establish connection. Check if Eye Tracker is running', 'Connection Error', 'modal');
        case 105
             msgbox('Could not establish connection. Check the communication Ports', 'Connection Error', 'modal');
        case 123
             msgbox('Could not establish connection. Another Process is blocking the communication Ports', 'Connection Error', 'modal');
        case 200
             msgbox('Could not establish connection. Check if Eye Tracker is installed and running', 'Connection Error', 'modal');
        otherwise %last resort for failed connection
             msgbox('Could not establish connection', 'Connection Error', 'modal');
    end
end

%if connected %when using smi, only run if connected
        if smi
            disp('Get System Info Data') %get system information before running
            calllib('iViewXAPI', 'iV_GetSystemInfo', pSystemInfoData)
            get(pSystemInfoData, 'Value')
        end

    %    iV_GetEyeImage %use these if you wish to see eye image on monitor
    %    iV_GetTrackingMonitor

    %    iV_ShowEyeImageMonitor
    %    calllib('iViewXAPI', 'iV_ShowEyeImageMonitor');

try
    %% Setup (calibration, validation) of iViewX
    if smi
    %B: This is the function that starts a calibration
        disp('Calibrate iViewX')
        calllib('iViewXAPI', 'iV_SetupCalibration', pCalibrationData)
        calllib('iViewXAPI', 'iV_Calibrate') %run calibration - 9-point grid

    %B: This validates the calibration
        disp('Validate Calibration') %validating calibration (uses smaller 4-point grid)
        calllib('iViewXAPI', 'iV_Validate')

    %B: This gets the calibration accuracy (if I remember right...) 
        disp('Show Accuracy') %show accuracy of validated calibration
        calllib('iViewXAPI', 'iV_GetAccuracy', pAccuracyData, int32(0))
        get(pAccuracyData, 'Value')

    % check calibration. if good, press key:
    % clear recording buffer

        calllib('iViewXAPI', 'iV_ClearRecordingBuffer'); %clear recording buffer before experiment starts

    %% Start iViewX recording
        calllib('iViewXAPI', 'iV_StartRecording'); %start recording eye position data before the experiment
        while KbCheck;
        end %wait for all keys are released
        keyisdown = 0;
        while ~keyisdown
            [keyisdown] = KbCheck;
            WaitSecs(0.001); % delay if key is pressed to prevent CPU hogging
        end
    end
%% PSYCHTOOLBOX VARIABLES
    % Choose a screen
    screenNumber = max(Screen('Screens'));
    Screen('Preference', 'SkipSyncTests', 1); %iverriding sync tests when there are synctime problems with ptb
%     Screen('Preference', 'SuppressAllWarnings', 1);
%     Screen('Preference', 'VisualDebugLevel', 0 );
    small_screen = [0 0 720 400]; %creating coordinates of small screen for testing
    % Get colours
    backgroundColor = BlackIndex(screenNumber); %black
    foregroundColor = WhiteIndex(screenNumber); %white
    penwidth = 10; %width of frame for rectangle

    %[window, rect] = Screen('OpenWindow',screenNumber, backgroundColor, small_screen); %small screen for testing, use this until your happy experiment is up and running
    HideCursor;
    %ListenChar(2); %disabling keyboard input to Matlab: If your script should abort and your keyboard is dead, press CTRL+C to reenable keyboard input

    [window, rect]= Screen('OpenWindow', screenNumber, backgroundColor); %this is fullscreen for experiment

    % find the size of the display
    DisplayXSize = rect(3);
    DisplayYSize = rect(4);
    fullscreen = [0 0 rect(3) rect(4)];

    %and space variables for calibration
    midX = DisplayXSize/2;
    midY = DisplayYSize/2;
    %find pixels/cm
    vadxcm=DisplayXSize/sx; %pix per 1 cm
    vadycm=DisplayYSize/sy;
    %find pixels/degree
    vadx=vadxcm/(atan(1/sd)*180/pi); % vad in pixels for 1 degree visual angle
    vady=vadycm/(atan(1/sd)*180/pi); % vad in pixels for 1 degree visual angle

    % find the refresh rate of the monitor
    frame_duration = Screen ('GetFlipInterval', window);
    frame_rate = 1/frame_duration;
    
    %% Experiment starts
    tic
        % Initialize AudioDevice:
        InitializePsychSound(1); %sound presentation with psychtoolbox
        freq = 44100; %frequency of sound device
        %lat = 0.015; %latency of sound device
        pahandle = PsychPortAudio('Open', [], 2, 0, freq, 2); %open psychportaudio
        % Preallocate an internal audio recording  buffer with a capacity of 10 seconds:
        PsychPortAudio('GetAudioData', pahandle, 10);
        
        %space variables for task
        sizecue=sizecuedeg*vadx; %in pixels, from degrees
        sizetarg=sizetargdeg*vadx; %size of target in pix
        xcue=xcuedeg*vadx; %in pixels
        lrect = [DisplayXSize/2-xcue-sizecue/2 DisplayYSize/2-sizecue/2 DisplayXSize/2-xcue+sizecue/2 DisplayYSize/2+sizecue/2]; %left cue rectangle
        rrect = [DisplayXSize/2+xcue-sizecue/2 DisplayYSize/2-sizecue/2 DisplayXSize/2+xcue+sizecue/2 DisplayYSize/2+sizecue/2]; %right cue rectangle
        % Present starting screen
        Screen('FillRect', window, backgroundColor); %fill screen black
        Screen('TextStyle', window, 0); %normal
        Screen('TextFont', window, 'Lucida Console'); %font
        Screen('TextSize', window, textsizept); %size of text
        text = 'Press any key to start task'; %message
        width=RectWidth(Screen ('TextBounds', window, text)); %width of text
        Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2, foregroundColor);
        Screen('Flip', window); %flip the text to the screen
        
        % Wait for key press
        while KbCheck;
        end %wait for all keys are released
        keyisdown = 0;
        while ~keyisdown
            [keyisdown] = KbCheck;
            WaitSecs(0.001); % delay to prevent CPU hogging
        end

        WrongFixation=0; %to check that the participant are fixating
        t = 2;
%% Start the trials
        for i=1:nrtrials     
            % Show fixation cross
            text = '+';
            width=RectWidth(Screen ('TextBounds', window, text)); %fixation cross width and height
            height=RectHeight(Screen ('TextBounds', window, text));
            Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, foregroundColor); %fixation cross at center of the screen
            Screen('Flip', window); %show fixation cross
            fixtime= starttime+ fixtimemin + (fixtimemax-fixtimemin).*rand(1); %length of fix cross time on screen - 0.4 sec + random nr in the interval 0.1-0.25 
            WaitSecs(fixtime); %wait for length of fixcross time
            Screen('Flip', window); %erase fixation cross
            if smi
                calllib('iViewXAPI', 'iV_SendImageMessage', formatString(256, int8('FIXON'))); %sending iViewX a message 'fixon'
            end
            t = 3;
%% FRAMERECT PRESENTATION - EXO OR IOR

            if Timing(i) == 1 || Timing(i) == 2; %exogenous (200ms) = 1; IOR (850ms) = 2;  
                if Cue(i) == 1; % left frame rect cue
                    Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, foregroundColor); %show fixcross the same time as rect
                    Screen('FrameRect', window, foregroundColor, lrect, penwidth); %show framed rectangle
                    if smi
                        calllib('iViewXAPI', 'iV_SendImageMessage', formatString(256, int8('FRAMEON'))); %sending iViewX a message 'cueon'
                    end
                    Screen('Flip', window); %put checker on screen
                    timecuestart(i) = GetSecs;
                    a=GetSecs;
                    WaitSecs(rectduration)
                elseif Cue(i) == 2; % right frame rect cue
                    Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, foregroundColor); %show fixcross the same time as frame
                    Screen('FrameRect', window, foregroundColor, rrect, penwidth); %show framed rectangle
                    if smi
                        calllib('iViewXAPI', 'iV_SendImageMessage', formatString(256, int8('FRAMEON'))); %sending iViewX a message 'cueon'
                    end             
                    Screen('Flip', window); %put checker on screen
                    timecuestart(i) = GetSecs;
                    a=GetSecs;
                    WaitSecs(rectduration)
                else
                    % wait for length of cue (randomised between 100-150ms)
                    Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, foregroundColor); %draw fix cross
                    Screen('Flip', window); % present fix cross and no cue
                    WaitSecs(rectduration)
                end
                Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, foregroundColor); %show fixcross
                Screen('Flip', window);
                timecueend(i) = GetSecs;
                if Timing(i) == 1;
                    WaitSecs(exo)
                elseif Timing(i) == 2;
                    WaitSecs(IOR) 
                end
                
                %% Target presentation
                % prepare the letter (target) stimuli
                target=Stimulus(i);
                widtht=RectWidth(Screen ('TextBounds', window, target)); %width of the target
                heightt=RectHeight(Screen ('TextBounds', window, target)); %height of the target

                if TargetSide(i) == 2; %if target is presented on the right
                    Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, foregroundColor); %draw fixation cross
                    Screen('DrawText', window, target, DisplayXSize/2+xcue-sizetarg/2, DisplayYSize/2-heightt/2, foregroundColor); %draw target
                    Screen('Flip', window); %show my target                   
                    timetargetstart(i)=GetSecs; %get time of target presentation
                elseif TargetSide(i) == 1; %target presented on the left (==1), at 12 degrees only
                    Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, foregroundColor); %draw fixation cross
                    Screen('DrawText', window, target, DisplayXSize/2-xcue-sizetarg/2, DisplayYSize/2-heightt/2, foregroundColor); %draw target
                    Screen('Flip', window); %show my target                   
                    timetargetstart(i)=GetSecs; %get time of target presentation
                end
            end
                
%% SIMULTANEOUS CUE AND TARGET
            if Timing(i) == 0; %simultaneous target and cue presentation        
                % Target presentation
                % prepare the letter (target) stimuli
                target=Stimulus(i);
                widtht=RectWidth(Screen ('TextBounds', window, target)); %width of the target
                heightt=RectHeight(Screen ('TextBounds', window, target)); %height of the target
                if Cue(i) == 2; %cue on the right
                    if TargetSide(i) == 1;
                        Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, foregroundColor); %draw fixation cross
                        Screen('FrameRect', window, foregroundColor, rrect, penwidth); %show framed rectangle
                        Screen('DrawText', window, target, DisplayXSize/2-xcue-sizetarg/2, DisplayYSize/2-heightt/2, foregroundColor); %draw target
                        Screen('Flip', window); %show my target                   
                        timetargetstart(i)=GetSecs; %get time of target presentation
                        timecuestart(i) = GetSecs;
                        if smi
                            calllib('iViewXAPI', 'iV_SendImageMessage', formatString(256, int8('FRAMEON'))); %sending iViewX a message 'cueon'
                        end
                    else %target side = 2, right
                        Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, foregroundColor); %show fixcross the same time as rect
                        Screen('FrameRect', window, foregroundColor, rrect, penwidth); %draw cue
                        Screen('DrawText', window, target, DisplayXSize/2+xcue-sizetarg/2, DisplayYSize/2-heightt/2, foregroundColor); %draw target
                        Screen('Flip', window); %show my target                   
                        timetargetstart(i)=GetSecs; %get time of target presentation
                        timecuestart(i)=GetSecs; %get time of cue presentation 
                        if smi
                            calllib('iViewXAPI', 'iV_SendImageMessage', formatString(256, int8('FRAMEON'))); %sending iViewX a message 'cueon'
                        end
                    end
                elseif Cue(i) == 1; % left frame rect cue, target presented on the right
                    if TargetSide(i) == 1;
                        Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, foregroundColor); %draw fixation cross
                        Screen('FrameRect', window, foregroundColor, lrect, penwidth); %show framed rectangle
                        Screen('DrawText', window, target, DisplayXSize/2-xcue-sizetarg/2, DisplayYSize/2-heightt/2, foregroundColor); %draw target
                        Screen('Flip', window); %show my target                   
                        timetargetstart(i)=GetSecs; %get time of target presentation
                        timecuestart(i) = GetSecs;
                        if smi
                            calllib('iViewXAPI', 'iV_SendImageMessage', formatString(256, int8('FRAMEON'))); %sending iViewX a message 'cueon'
                        end                        
                    else %target side = 2, right
                        Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, foregroundColor); %show fixcross the same time as rect
                        Screen('FrameRect', window, foregroundColor, rrect, penwidth); %draw cue
                        Screen('DrawText', window, target, DisplayXSize/2+xcue-sizetarg/2, DisplayYSize/2-heightt/2, foregroundColor); %draw target
                        Screen('Flip', window); %show my target                   
                        timetargetstart(i)=GetSecs; %get time of target presentation
                        timecuestart(i)=GetSecs; %get time of cue presentation 
                        if smi
                            calllib('iViewXAPI', 'iV_SendImageMessage', formatString(256, int8('FRAMEON'))); %sending iViewX a message 'cueon'
                        end
                    end
                elseif Cue(i) == 0; %no cue condition, target could be either side
                    if TargetSide(i) == 2; %if the target is on the right
                        Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, foregroundColor); %show fixcross the same time as rect
                        Screen('DrawText', window, target, DisplayXSize/2+xcue-sizetarg/2, DisplayYSize/2-heightt/2, foregroundColor); %draw target
                        Screen('Flip', window); %show my target                   
                        timetargetstart(i)=GetSecs; %get time of target presentation
                    else %target on the left
                        Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, foregroundColor); %show fixcross the same time as rect
                        Screen('DrawText', window, target, DisplayXSize/2-xcue-sizetarg/2, DisplayYSize/2-heightt/2, foregroundColor); %draw target
                        Screen('Flip', window); %show my target 
                        timetargetstart(i) = GetSecs;
                    end
                end
            end
            if smi
               calllib('iViewXAPI', 'iV_SendImageMessage', formatString(256, int8('TARGETON'))); %send iVIewX 'targeton' message
            end           
            PsychPortAudio('Start', pahandle, 0, 0, 1); %start audio reading for the trials             
            %flip to fixation cross on screen
            WaitSecs(targettime) %wait time of target   
            Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, foregroundColor); %draw fix cross
            Screen('Flip', window); 
            timetargetend(i) = GetSecs;

%% Voice trigger coding
            if audio
                if voicetrigger > 0
                % Yes. Fetch audio data and check against threshold:
                level = 0;

                    % Repeat as long as below trigger-threshold:
                    while level < voicetrigger
                        % Fetch current audiodata:
                        [audiodata, offset, overflow, tCaptureStart] = PsychPortAudio('GetAudioData', pahandle);

                        % Compute maximum signal amplitude in this chunk of data:
                        if ~isempty(audiodata)
                            level = max(abs(audiodata(1,:)));
                        else
                            level = 0;
                        end

                        % Below trigger-threshold?
                        if level < voicetrigger
                            % Wait for a millisecond before next scan:
                            WaitSecs(0.0001);
                        end
                    end
                    timereaction(i)=GetSecs;
                    VRT(i)= ((timereaction(i)-timetargetstart(i)));
                    % substract AudioVisual delay tested for this machine
                    % Ok, last fetched chunk was above threshold!
                    % Find exact location of first above threshold sample.
                    idx = min(find(abs(audiodata(1,:)) >= voicetrigger)); %%#ok<MXFND>
                    % Initialize our recordedaudio vector with captured data starting from triggersample:
                    recordedaudio = audiodata(:, idx:end);
                    % For the fun of it, calculate signal onset time in the GetSecs time:
                    % Caution: For accurate and reliable results, you should
                    % PsychPortAudio('Open',...); the device in low-latency mode, as
                    % opposed to the "normal" mode used in this demo! If you fail to do so,
                    % the tCaptureStart timestamp may be inaccurate on some systems, and
                    % therefore this tOnset timestamp may be off! See for example
                    % PsychPortAudioTimingTest and AudioFeedbackLatencyTest for how to
                    % setup low-latency high precision mode.
                    tOnset = tCaptureStart + ((offset + idx - 1) / freq);
                    %fprintf('Estimated signal onset time is %f secs, this is %f msecs after start of capture.\n', tOnset, (tOnset - tCaptureStart)*1000);
                    VoiceRT(i)=((tOnset - tCaptureStart)*1000)-7.6205906; % substract AudioVisual delay tested for this machine
                else
                    % Start with empty sound vector:
                    recordedaudio = [];
                end

                % Two rects after target presentation indicating
                % press key
%                         Screen('FrameRect', window, foregroundColor, lrect, penwidth);
%                         Screen('FrameRect', window, foregroundColor, rrect, penwidth);
                Screen('Flip', window); 

                PsychPortAudio('Stop', pahandle, 0, 0, 1);
            end

 %% Get response and accuracy
            %and now wait for a response for 1250 ms
            time0=GetSecs;
            flag2=0;
            while (GetSecs-time0 < waittimemax)&& flag2==0 %while time0 is smaller than waittime, there is no keypress
                [keyIsDown, secs, keyCode] = KbCheck; %check keyboard
                if keyIsDown %if any keypress
                t=7;
                    if any(ismember(KbName(keyCode),[KbName(leftKey), KbName(rightKey)])) %key press options - leftkey ('1'), rightkey ('4')
                        flag2 = 1;                           
                        timekeypress(i) = GetSecs;     % time for the first key press
                        RT(i) = timekeypress(i)-timetargetstart(i); %RT for the first key press
                        key = KbName(keyCode);   % add the key name for the first key press
                    end
                end
            end
            t = 8; %for debugging

            if flag2==1 %some response
                if any(ismember(KbName(keyCode),KbName(rightKey))) %if they pressed rightkey
                    ActualResponse(i) = rightKey; %this is the code if the key pressed is '4'
                end 
                if any(ismember(KbName(keyCode),KbName(leftKey))) %if they pressed left key
                    ActualResponse(i) = leftKey; %this is the code of the key pressed is '1'
                end

                if any(ismember(KbName(keyCode),KbName(rightKey))) && CorrectResponse(i)==rightKey %this is a hit to the letter H
                    Accuracy(i)=1; %if hit correct key

                    if Cue(i)== TargetSide(i) %valid trials
                        pervalid=pervalid+1;
                        rtvalid=rtvalid+RT(i);

                    elseif Cue(i)== 0; %no cue trials
                        perNoCue=perNoCue+1;
                        rtNoCue=rtNoCue+RT(i);
                    else %invalid trials
                        perinvalid=perinvalid+1;
                        rtinvalid=rtinvalid+RT(i);
                    end
                end

                if any(ismember(KbName(keyCode),KbName(leftKey))) && CorrectResponse(i)==leftKey %this is a hit for the letter 'A'
                    Accuracy(i)=1; %if hit correct key

                    if Cue(i)== TargetSide(i) %valid trials
                        pervalid=pervalid+1;
                        rtvalid=rtvalid+RT(i);

                    elseif Cue(i)== 0; %no cue trials
                        perNoCue=perNoCue+1;
                        rtNoCue=rtNoCue+RT(i);
                    else %invalid trials
                        perinvalid=perinvalid+1;
                        rtinvalid=rtinvalid+RT(i);
                    end

                end

                if any(ismember(KbName(keyCode),KbName(rightKey))) && CorrectResponse(i)==leftKey %this is a false positive for "A"
                    Accuracy(i)=0; %if hit uncorrect key
                    if Cue(i)==TargetSide(i) %validtrials
                        fpvalid=fpvalid+1;

                    elseif Cue(i) == 0; %no cue conditions
                        fpNoCue=fpNoCue+1;

                    else %invalild trials
                        fpinvalid=fpinvalid+1;

                    end
                end

                if any(ismember(KbName(keyCode),KbName(leftKey))) && CorrectResponse(i)==rightKey %this is a false positive for "H"
                    Accuracy(i)=0; %if hit uncorrect key
                    if Cue(i)==TargetSide(i) %validtrials
                        fpvalid=fpvalid+1;

                    elseif Cue(i) == 0; %no cue conditions
                        fpNoCue=fpNoCue+1;

                    else %invalild trials
                        fpinvalid=fpinvalid+1;

                    end
                end
            end

            if flag2==0 %no key press
                ActualResponse(i)=NaN; %record responses as NaN when no key is pressed
                RT(i)=NaN;
                timekeypress(i)=NaN;
                Accuracy(i)=0;
                VRT(i)=NaN;
            end 
            t = 9; %for debugging
            Screen('Flip', window); %get rid of fixation cross
            if smi
                calllib('iViewXAPI', 'iV_SendImageMessage', formatString(256, int8('FIXOFF'))); %send iViewX 'fixoff' message
            end
%% Wait for key press
% Allows patients to take their time, also means RT measure from key press
% 1 or 4 (above) is true measure of patient RT
            while KbCheck;
            end %wait for all keys are released
            keyisdown = 0;
            while ~keyisdown %wait for key press before moving onto next trial
                [keyisdown] = KbCheck;
                WaitSecs(0.001); % delay to prevent CPU hogging
            end
        end
   
       
WaitSecs(0.5)
       
%% Experiment ends

%% END, CLOSE AND SAY THANKS
        Screen('TextSize', window, 40); %Set text size
        text = 'Thank you for taking part :)'; %message
        width=RectWidth(Screen ('TextBounds', window, text)); %width of message
        Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2, foregroundColor);
        Screen('Flip', window); %display message
        WaitSecs (2); %wait 2 seconds
        sca; %close ptb screen
       
        if smi 
            % End iViewX recording
            calllib('iViewXAPI', 'iV_StopRecording')
        end
        PsychPortAudio('Close', pahandle); %close audio drives
        t = 10; %for debugging

%% OUTPUT DATA
        %accuracy during cue and no cue
        if nrinvalid~=0 %calculating the accuracy during cue and nocue conditions from correct trials and false positives
            perNoCue=perNoCue*100/nrinvalid;
            rtNoCue=rtNoCue/nrinvalid;
            fpl=fpl*100/nrl;
        else
            perNoCue=0;
        end
        if nrNoCue~=0
            pervalid=pervalid*100/nrNoCue;
            fpNoCue=fpNoCue*100/nrr;
            rtvalid=rtvalid/nrNoCue;
        else
            pervalid=0;
        end
        t = 11; %for debugging

    %% Save SMI REDm data
    if smi       
        %save iViewX file
        user = formatString(64, int8('AttentionLVFcue')); %Put your own file name in quotes here
        description = formatString(64, int8('Description1')); %Add some description if you like
        ovr = int32(1);
        filename = formatString(256, int8(['D:\iViewXSDK_Matlab_Data_' user '.idf'])); %This shows the pathway for saving - D:\ drive was the one that worked.  
        calllib('iViewXAPI', 'iV_SaveData', filename, description, user, ovr) %Saves the file in pathway abov

        % Disconnect
        calllib('iViewXAPI', 'iV_Disconnect')
        
        % unload iViewX API libraray
        unloadlibrary('iViewXAPI');
    end

catch % If there is an error in our try block, return the user to the MATLAB prompt.
        sca;
        ShowCursor;
        rethrow(lasterror);
        ListenChar(0);
        disp('Disconnect')
        save(matfilename)
        if smi
            %Stop the recording... 
            calllib('iViewXAPI', 'iV_StopRecording')
            %disconnect
            calllib('iViewXAPI', 'iV_Disconnect')
        end
end
%% Save - incase things go wrong with analysis
save(matfilename)

%% DATA ANALYSIS
%VRT = VRT'; %transforming VRT array from horiztonal to vertical
RT =  RT';
RT = RT*1000;
%VRT = VRT*1000; %changing RT from s to ms (match VRT)
%rts = [VRT RT];
%% Create Matrix for analysis. <- very useful to know
Matrix = [];
Matrix(:,1)= Cue;
Matrix(:,2)= Accuracy;
%Matrix(:,3)= VRT;
Matrix(:,4)= RT;
Matrix(:,5) = Timing;

%corrplot(rts);

%Valid=(length(find(Matrix(:,3)>=0.001))/nrtrials)*100; %percentage of trials that are valid
Accurate=(length(find(Matrix(:,2)>=0.001))/nrtrials)*100; %percentage of trials that are accurate

Time=toc/60; %timing and length of the experiment
%% SAVE
save(matfilename)