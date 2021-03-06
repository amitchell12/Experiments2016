%% AG.Mitchell - 25.05.16
%% Target localisation task
% This script presents targets at 14 different locations on the screen,
% attempting to identify the point of 'neglect' in patients with spatial
% neglect
% Targets (A/H) are randomly presented at 2, 4, 6, 8, 10, 12 and 14 degrees to
% the left or right of fixation (1.5 deg) for 100ms
% Patient/participant has to vocally identify target letter as fast and as
% accurately as possible, voice reaction time from target onset is measured
% The experimenter then presses a key to indicate what letter the
% patient/participant has said ('+' - H, '-' - A), this provides a measure
% of accuracy
% Both accuracy and reaction time are measured
% An output plot of target location vs. accuracy is extracted to identify
% the target location where patients preseneting with neglect respond at
% chance level - This identifies the point in the visual field that
% patients present with negelct
% In healthy patients we expect accuracy levels to remain consistent across
% the entire VF

%% Alex and Daniela 30.11.2015, using Barthel's script from the attention experiment Odoj and Balslev 2015
% Alex: added SMI_REDm eye tracking bits to this code instead of using Eyelink II.
% Code taken from 'RedmExampleCode.m' which is an edited version of
% 'DataStreaming.m', edited by BR.Innes

%% Clear all variables, connections, ...
clear all
clc
warning('off', 'all');

%% environment for the experiment

dummymode=0; %?practice?
smi=1; %SMI REDm camera? 0 - no, 1 - yes
sx=31; %cm, xscreen
sy=18; %cm yscreen
sd=57; %cm, dist eye-screen
eye=2; %number of eyes being recorded
audio = 1;
ParticipantID = 's1';

%% input the cue position for chance perception. We want to show the cue at this location and targets at all set locations to the right of the cue
nrtargets=20;

if practice == 0; %not practice
    trialnr=4; %nr of trials per target
else
    trialnr=2; %nr trials for practice
end

%% Time and space variables
crosstime=1.5; %time between onset of fix cross and target, 500ms to allow patients to saccade back

waittimemax=10000;%seconds, second stimulus and a response, 2AFC
letters(1)='A'; %target (key press - 1)
letters(2)='H'; %target (key press - 4)

targettime=0.100; %time of target onset

%% for voice RT
voicetrigger = 0.1;
%adjust mic sensibility
maxsecs = 0.01; %10 ms data recording

%% text size variables

textpt=0.0352; %cm for 1 pt
textsizedeg=1; %degrees, visual crowding in fovea under 0.2 deg; 0.35 deg visual angle, size of one letter according to Spinelli 2002
textsizecm=tan(pi*textsizedeg/360)*2*57; %in cm
textsizept=2*round(textsizecm/textpt); %in pt, for some reason this number needs to be doubled

%% Degrees of target and cue
sizetargetdeg = 1.5; %size of target in degrees
%how many degrees does the screen cover
screendeg=2*atand(sx/2/sd);
% generate the target array (xtarget in degrees)
targets=((-screendeg+sizetargetdeg/2)/nrtargets)*nrtargets/2:(screendeg-sizetargetdeg/2)/nrtargets:((screendeg-sizetargetdeg/2)/nrtargets)*nrtargets/2;
%generate full array for all trials
targetss=targets;
for i=1:trialnr-1
    targetss=cat(2, targetss, targets);
end;
%permute the array for randomization
targetss=targetss(randperm(length(targetss)));

nrtrials = length(targetss);
%% Trial variables

% read trial variables from an xls file
[Data,Text] = xlsread('TrialCounter_loc3.xlsx');

TargetLetter =  Data(:, ismember(Text, 'TargetLetter')); %defining target from xls file (A/H)TargetLetter: 1-A, 2-H
TargetSide = Data(:, ismember(Text, 'TargetSide')); %defining the side of target, 1 - left, 2 - right

nrtargs = length(TargetLetter); %trials, total nr

%% correct response keys
leftKey = KbName('-'); %this is a number that identifies the key; letter A
rightKey = KbName('+'); %letter H

%% OUTPUT

%preallocation of variables, for the output
ActualResponse=[]; 
CorrectResponse=[];
timefixstart=[];
timetargetend=[];
timetargetstart =[];
timekeypress=[];
VRT = [];
RT=[];


%prepare correct response lists
for i=1:nrtargs %for all trials run in the sequence
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
matfilename = sprintf ('Localiser_3%d%d%d%d%d.mat', datenow (1), datenow(2), datenow(3), datenow(4), datenow(5)); %name of the output file

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
        %xcue=xcuedeg*vadx; % distance of cue in pixels
        sizetarg=sizetargetdeg*vadx; %size of target in pix;
        
%         lrect = [DisplayXSize/2-xcue-sizecue/2 DisplayYSize/2-sizecue/2 DisplayXSize/2-xcue+sizecue/2 DisplayYSize/2+sizecue/2]; %left cue rectangle
%         rrect = [DisplayXSize/2+xcue-sizecue/2 DisplayYSize/2-sizecue/2 DisplayXSize/2+xcue+sizecue/2 DisplayYSize/2+sizecue/2]; %right cue rectangle
        
        % Present starting screen
        Screen('FillRect', window, backgroundColor); %fill screen black
        Screen('TextStyle', window, 0); %normal
        Screen('TextFont', window, 'Lucida Console'); %font
        Screen('TextSize', window, 30); %size of text
        text = 'Tell the experimenter when you are ready to begin'; %message
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
        for i=1:length(targetss)
            targetss(i) = targetss(i)*vadx; %converting to pixels
            %% Marking trials
            if i == round(length(targetss)/4) %quarter of the way through
                Screen('TextSize', window, 30); %size of text
                text = 'You are 1/4 of the way through'; %message
                width=RectWidth(Screen ('TextBounds', window, text)); %width of text
                Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2, foregroundColor);
                Screen('Flip', window); %flip the text to the screen
                WaitSecs(3)
            elseif i == round(length(targetss)/2) %half of the way through
                Screen('TextSize', window, 30); %size of text
                text = 'Congratulations! You are half way! :)'; %message
                width=RectWidth(Screen ('TextBounds', window, text)); %width of text
                Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2, foregroundColor);
                Screen('Flip', window); %flip the text to the screen
                WaitSecs(3)
            elseif i == length(targetss)-9 %10 trials left
                Screen('TextSize', window, 30); %size of text
                text = 'Nearly there, only 10 trials left :)'; %message
                width=RectWidth(Screen ('TextBounds', window, text)); %width of text
                Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2, foregroundColor);
                Screen('Flip', window); %flip the text to the screen
                WaitSecs(3) 
            end              
            % Show fixation cross
            text = '+';
            Screen('TextSize', window, textsizept); %size of text
            width=RectWidth(Screen ('TextBounds', window, text)); %fixation cross width and height
            height=RectHeight(Screen ('TextBounds', window, text));
            Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, foregroundColor); %fixation cross at center of the screen
            Screen('Flip', window); %show fixation cross
            timefixstart(i) = GetSecs;
            if smi
                calllib('iViewXAPI', 'iV_SendImageMessage', formatString(256, int8('FIXON'))); %sending iViewX a message 'fixon'
            end
            WaitSecs(crosstime); %wait length of fixation cross time depending on condition

            t = 3;
            
%% Target Presentation
            target=Stimulus(i);
            widtht=sizetarg; %width of the target
            heightt=sizetarg; %height of the target
            Screen('DrawText', window, target, DisplayXSize/2+targetss(i)-sizetarg/2, DisplayYSize/2-heightt/2, foregroundColor); %draw target
            Screen('Flip', window);
            timetargetstart(i) = GetSecs;
            if smi
               calllib('iViewXAPI', 'iV_SendImageMessage', formatString(256, int8('TARGETON'))); %send iVIewX 'targeton' message
            end           
            PsychPortAudio('Start', pahandle, 0, 0, 1); %start audio reading for the trials             
            %flip to fixation cross on screen
            WaitSecs(targettime) %wait time of target
            timetargetend(i) = GetSecs;
            WaitSecs(0.1);            
            que = '?';
            Screen('DrawText', window, que, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, foregroundColor); %draw fix cross
            Screen('Flip', window); 

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
                end

                if any(ismember(KbName(keyCode),KbName(leftKey))) && CorrectResponse(i)==leftKey %this is a hit for the letter 'A'
                    Accuracy(i)=1; %if hit correct key
                end

                if any(ismember(KbName(keyCode),KbName(rightKey))) && CorrectResponse(i)==leftKey %this is a false positive for "A"
                    Accuracy(i)=0; %if hit uncorrect key
                end

                if any(ismember(KbName(keyCode),KbName(leftKey))) && CorrectResponse(i)==rightKey %this is a false positive for "H"
                    Accuracy(i)=0; %if hit uncorrect key
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
            if smi
                calllib('iViewXAPI', 'iV_SendImageMessage', formatString(256, int8('FIXOFF'))); %send iViewX 'fixoff' message
            end
            Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, foregroundColor); %draw fix cross
            Screen('Flip', window); %show fixation%% Wait for key press
% Allows patients to take their time, also means RT measure from key press
% 1 or 4 (above) is true measure of patient RT
            while KbCheck;
            end %wait for all keys are released
            keyisdown = 0;
            while ~keyisdown %wait for key press before moving onto next trial
                [keyisdown] = KbCheck;
                WaitSecs(0.001); % delay to prevent CPU hogging
            end
            Screen('Flip', window);
            WaitSecs(0.05); % wait 50ms for fixation to eliminate timing variation
            
        end      
WaitSecs(0.5)
       
%% Experiment ends

%% END, CLOSE AND SAY THANKS
        Screen('TextSize', window, 40); %Set text size
        text = 'Thank you :)'; %message
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


    %% Save SMI REDm data
    if smi       
        %save iViewX file
        user = formatString(64, int8('Localiser3')); %Put your own file name in quotes here
        description = formatString(64, int8('Description1')); %Add some description if you like
        ovr = int32(1);
        filename = formatString(256, int8(['D:\iViewXSDK_Matlab_Data_' user '.idf'])); %This shows the pathway for saving - D:\ drive was the one that worked.  
        calllib('iViewXAPI', 'iV_SaveData', filename, description, user, ovr) %Saves the file in pathway abov

        % Disconnect
        calllib('iViewXAPI', 'iV_Disconnect')       
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
VRT = VRT'; %transforming VRT array from horiztonal to vertical
RT =  RT';
RT = RT*1000;
VRT = VRT*1000; %changing RT from s to ms (match VRT)
%% Create Matrix for analysis. <- very useful to know

targloc = [];

VRTmax = 1500;
VRTmin = 250;
RTmax = 1500;
RTmin = 150;

% convert targets back from pixels into degrees
for i = 1:length(targetss);
    targetss(i) = targetss(i)/vadx;
end

%% Finding and averaging accuracy and RT for each target location
% Cannot find equal values of one soft-coded value compared to another, so
% need to find something close to equal by creating a small number
% (episolon) that the targetss value - targets location is not larger than
epsilon = 0.0001;

for i = 1:length(targetss)
    if abs(targetss(i) - (((-screendeg+sizetargetdeg/2)/nrtargets)*nrtargets/2)) < epsilon %finding eaach individual target location to average accuracy later
        targloc(i) = 1;
    elseif abs(targetss(i) - ((((-screendeg+sizetargetdeg/2)/nrtargets)*nrtargets/2)+(screendeg-sizetargetdeg/2)/nrtargets)) < epsilon
        targloc(i) = 2;
    elseif abs(targetss(i) - ((((-screendeg+sizetargetdeg/2)/nrtargets)*nrtargets/2)+2*(screendeg-sizetargetdeg/2)/nrtargets)) < epsilon
        targloc(i) = 3;
    elseif abs(targetss(i) - ((((-screendeg+sizetargetdeg/2)/nrtargets)*nrtargets/2)+3*(screendeg-sizetargetdeg/2)/nrtargets))  < epsilon
        targloc(i) = 4;
    elseif abs(targetss(i) - ((((-screendeg+sizetargetdeg/2)/nrtargets)*nrtargets/2)+4*(screendeg-sizetargetdeg/2)/nrtargets)) < epsilon
        targloc(i) = 5;
    elseif abs(targetss(i) - ((((-screendeg+sizetargetdeg/2)/nrtargets)*nrtargets/2)+5*(screendeg-sizetargetdeg/2)/nrtargets)) < epsilon
        targloc(i) = 6;
    elseif abs(targetss(i) - ((((-screendeg+sizetargetdeg/2)/nrtargets)*nrtargets/2)+6*(screendeg-sizetargetdeg/2)/nrtargets)) < epsilon
        targloc(i) = 7;
    elseif abs(targetss(i) - ((((-screendeg+sizetargetdeg/2)/nrtargets)*nrtargets/2)+7*(screendeg-sizetargetdeg/2)/nrtargets)) < epsilon
        targloc(i) = 8;
    elseif abs(targetss(i) - ((((-screendeg+sizetargetdeg/2)/nrtargets)*nrtargets/2)+8*(screendeg-sizetargetdeg/2)/nrtargets)) < epsilon
        targloc(i) = 9;   
    elseif abs(targetss(i) - ((((-screendeg+sizetargetdeg/2)/nrtargets)*nrtargets/2)+9*(screendeg-sizetargetdeg/2)/nrtargets)) < epsilon
        targloc(i) = 10;
    elseif abs(targetss(i) - ((((-screendeg+sizetargetdeg/2)/nrtargets)*nrtargets/2)+10*(screendeg-sizetargetdeg/2)/nrtargets)) < epsilon
        targloc(i) = 11;
    elseif abs(targetss(i) - ((((-screendeg+sizetargetdeg/2)/nrtargets)*nrtargets/2)+11*(screendeg-sizetargetdeg/2)/nrtargets)) < epsilon
        targloc(i) = 12;
    elseif abs(targetss(i) - ((((-screendeg+sizetargetdeg/2)/nrtargets)*nrtargets/2)+12*(screendeg-sizetargetdeg/2)/nrtargets)) < epsilon
        targloc(i) = 13;
    elseif abs(targetss(i) - ((((-screendeg+sizetargetdeg/2)/nrtargets)*nrtargets/2)+13*(screendeg-sizetargetdeg/2)/nrtargets)) < epsilon
        targloc(i) = 14;
    elseif abs(targetss(i) - ((((-screendeg+sizetargetdeg/2)/nrtargets)*nrtargets/2)+14*(screendeg-sizetargetdeg/2)/nrtargets)) < epsilon
        targloc(i) = 15;        
    elseif abs(targetss(i) - ((((-screendeg+sizetargetdeg/2)/nrtargets)*nrtargets/2)+15*(screendeg-sizetargetdeg/2)/nrtargets)) < epsilon
        targloc(i) = 16;  
    elseif abs(targetss(i) - ((((-screendeg+sizetargetdeg/2)/nrtargets)*nrtargets/2)+16*(screendeg-sizetargetdeg/2)/nrtargets)) < epsilon
        targloc(i) = 17;    
    elseif abs(targetss(i) - ((((-screendeg+sizetargetdeg/2)/nrtargets)*nrtargets/2)+17*(screendeg-sizetargetdeg/2)/nrtargets)) < epsilon
        targloc(i) = 18;    
    elseif abs(targetss(i) - ((((-screendeg+sizetargetdeg/2)/nrtargets)*nrtargets/2)+18*(screendeg-sizetargetdeg/2)/nrtargets)) < epsilon
        targloc(i) = 19; 
    elseif abs(targetss(i) - ((((-screendeg+sizetargetdeg/2)/nrtargets)*nrtargets/2)+19*(screendeg-sizetargetdeg/2)/nrtargets)) < epsilon
        targloc(i) = 20;  
    elseif abs(targetss(i) - ((screendeg-sizetargetdeg/2)/nrtargets)*nrtargets/2) < epsilon
        targloc(i) = 21;       
    end
end   

% Creating a matrix
Matrix3 = [];
Matrix3(:,1)= targetss;
Matrix3(:,2)= Accuracy;
Matrix3(:,3)= VRT;
Matrix3(:,4)= RT;
Matrix3(:,5) = targloc; %marking the target location using a counter

%% SAVE
save(matfilename)