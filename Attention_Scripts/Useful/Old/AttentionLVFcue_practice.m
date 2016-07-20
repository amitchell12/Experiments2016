%% AG.Mitchell - 01.03.16
%% Left visual field attention task practice
% This script runs 10 practice trials (in a set, randomised order) to test
% VRT thresholds for patients/participants before running the actual
% experiment
% This script can also be used to give patients/participants some practice
% before they start the actual experiment

% This script has exactly the same set up as the AttentionLVFcue_exp
% script, wrt to RT, keypress and VRT, but does not incorporate SMI into
% the script
%% Clear all variables, connections, ...
clear all
clc
warning('off', 'all');

%% environment for the experiment

dummymode=0; %?practice?
sx=31; %cm, xscreen
sy=18; %cm yscreen
sd=57; %cm, dist eye-screen
audio = 0;

ParticipantID = 'AM';
%% Time and space variables
starttime=0.4; %cross
fixtimemax=1; %seconds
fixtimemin=0.1; %seconds
checkerduration=0.06; %length of cue, seconds
checkertimemax=0.09; %seconds, to avoid a saccade that takes 200 ms to prepare
checkertimemin=0.04; %seconds
cuetime = 0.05; %length of temporally predictive cue in seconds

waittimemax=10000;%seconds, second stimulus and a response, 2AFC
letters(1)='a'; %target (key press - 1)
letters(2)='e'; %target (key press - 4)


targettime=0.100; %time of target onset

%% for voice RT
voicetrigger = 0.2; %captures clear voice
% quiet 0.2-0.1
%adjust mic sensibility
maxsecs = 0.01; %10 ms data recording

%% text size variables

textpt=0.0352; %cm for 1 pt
textsizedeg=1; %degrees, visual crowding in fovea under 0.2 deg; 0.35 deg visual angle, size of one letter according to Spinelli 2002
textsizecm=tan(pi*textsizedeg/360)*2*sd; %in cm
textsizept=2*round(textsizecm/textpt); %in pt, for some reason this number needs to be doubled
xcuedeg=9; %deg visual angle from center of screen 
sizecuedeg=6; %deg visual angle size of the precue rectangle

%% sound variables
beepfreq = 1000; %Hz
beepdur = 0.1; %ms
beep = MakeBeep(beepfreq, beepdur); %sound
repetitions = 1; %how many times beep is repeated
%% Trial variables

% read trial variables from an xls file
[Data,Text] = xlsread('AttentionLVFcue_practice'); %different excel file because want different order from actual experiment

Condition =      Data(:, ismember(Text, 'Condition')); %defining condition from xls file (cue/nocue)Condition:    1-no cue, 2-cue
TargetLetter =  Data(:, ismember(Text, 'TargetLetter')); %defining target from xls file (A/H)TargetLetter: 1-A, 2-H
TargetSide = Data(:, ismember(Text, 'TargetSide')); %defining target side (left = 0, right = 1) from xls file

nrtrials = length(Condition); %total number of trials

%% correct response keys
leftKey = KbName('1'); %this is a number that identifies the key; letter A
rightKey = KbName('4'); %letter H
%% OUTPUT
%preallocation of variables, for the output
ActualResponse=[]; 
CorrectResponse=[];
timetargetend=[];
timetargetstart =[];
timekeypress=[];
RT=[];

%prepare correct response lists
for i=1:nrtrials %for all trials run in the sequence
    if TargetLetter(i)==1 %if the target letter = A
        CorrectResponse(i)=leftKey; %this is the code for the key (leftkey = 1)
        Stimulus(i) = 'a';
    end

    if  TargetLetter(i)==2 %if the target letter = H
        CorrectResponse(i)=rightKey; %this is the code for the key (rightkey = 4)
        Stimulus(i) = 'e';
    end

end

%% OUTPUT
% Output file where variables can be saved, and output variables
datenow = clock;
matfilename = sprintf ('AttPrac%d%d%d%d%d.mat', datenow (1), datenow(2), datenow(3), datenow(4), datenow(5)); %name of the output file
perCue=0; %output variables
perNoCue=0;
nrCue=0;
nrNoCue=0;
rtCue=0;
rtNoCue=0;
fpCue = 0;
fpNoCue = 0;

try
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
    ListenChar(2); %disabling keyboard input to Matlab: If your script should abort and your keyboard is dead, press CTRL+C to reenable keyboard input

    [window, rect]= Screen('OpenWindow', screenNumber, backgroundColor); %this is fullscreen for experiment
    t = 1; %for debugging

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
            t = 3;
           
%% CHECKERBOARD (CUE) PRESENTATION

            %%...show the cue
            %recalculate targets for checkerboard - coordinates for rects
            %for the checkerboard
            ltrect1=[DisplayXSize/2-xcue-sizecue/2 DisplayYSize/2-sizecue/2 DisplayXSize/2-xcue DisplayYSize/2];%upper left quadrant
            ltrect2=[DisplayXSize/2-xcue DisplayYSize/2 DisplayXSize/2-xcue+sizecue/2 DisplayYSize/2+sizecue/2];%lower right
            ltrect3=[DisplayXSize/2-xcue DisplayYSize/2-sizecue/2 DisplayXSize/2-xcue+sizecue/2 DisplayYSize/2];%upper right quadrant
            ltrect4=[DisplayXSize/2-xcue-sizecue/2 DisplayYSize/2 DisplayXSize/2-xcue DisplayYSize/2+sizecue/2];%lower 

                if Condition(i) == 2 %cue present LVF checkerboard stimulus
                   
                    % Temporally predictive cue
                    star = '*';
                    Screen('DrawText', window, star, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, foregroundColor); %fixation cross at center of the screen
                    Screen('FillRect', window, foregroundColor, ltrect1);
                    Screen('FillRect', window, foregroundColor, ltrect2); %show checkerboard
                   
                    Screen('Flip', window); %put checker and 'x' on screen
                    timecheckerstarts(i) = GetSecs;
                    a=GetSecs;
                    while (GetSecs-a)<checkerduration-2*frame_duration  %flicker at frame rate
                        Screen('DrawText', window, star, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, foregroundColor);
                        Screen('FillRect', window, foregroundColor, ltrect1);
                        Screen('FillRect', window, foregroundColor, ltrect2); %show checkerboard
                        Screen('Flip', window);
                        WaitSecs(frame_duration);
                        Screen('DrawText', window, star, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, foregroundColor);
                        Screen('FillRect', window, foregroundColor, ltrect3);
                        Screen('FillRect', window, foregroundColor, ltrect4); %show checkerboard
                        Screen('Flip', window);
                        WaitSecs(frame_duration);
                    end
                    Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, foregroundColor); %draw fix cross
                    Screen('Flip', window); % take the checker off of the screen
                    timechckerends(i) = GetSecs;

                    % wait for length of cue (randomised between 100-150ms)
                    WaitSecs(checkerduration);
                    checkertime= -checkerduration + checkertimemin + (checkertimemax-checkertimemin).*rand(1); %random nr in the interval 0.1-0.2 
                    WaitSecs(checkertime); %wait for total time of cue
                    
                else  % Condition ==1, no LVF cue
                    % wait for length of cue (randomised between 100-150ms)
                    Screen('DrawText', window, star, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, foregroundColor); %draw fix cross
                    Screen('Flip', window); % present star and no cue
                    WaitSecs(checkerduration); %wait cue duration
                    checkertime= -checkerduration + checkertimemin + (checkertimemax-checkertimemin).*rand(1); %random nr in the interval 0.1-0.2 
                    WaitSecs(checkertime); %wait for total time of cue
                end
                    
%% TARGET PRESENTATION
                    % prepare the letter (target) stimuli
                    target=Stimulus(i);
                    
                   if TargetSide(i) == 0; %if target is presented on the left
                        widtht=RectWidth(Screen ('TextBounds', window, target)); %width of the target
                        heightt=RectHeight(Screen ('TextBounds', window, target)); %height of the target
                        Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, foregroundColor); %draw fixation cross
                        Screen('DrawText', window, target, DisplayXSize/2-xcue+sizecue/2, DisplayYSize/2-heightt/2, foregroundColor); %draw target
                        Screen('Flip', window); %show my target                   
                        timetargetstart(i)=GetSecs; %get time of target presentation

                   else %target presented on the right (==1)
                        widtht=RectWidth(Screen ('TextBounds', window, target)); %width of the target
                        heightt=RectHeight(Screen ('TextBounds', window, target)); %height of the target
                        Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, foregroundColor); %draw fixation cross
                        Screen('DrawText', window, target, DisplayXSize/2+xcue-sizecue/2, DisplayYSize/2-heightt/2, foregroundColor); %draw target
                        Screen('Flip', window); %show my target                   
                        timetargetstart(i)=GetSecs; %get time of target presentation
                        
                   end
                    
                    PsychPortAudio('Start', pahandle, 0, 0, 1); %start audio reading for the trials
                    WaitSecs(targettime) %wait time of target

                    %flip to blank screen
                    Screen('Flip', window); %show fixation cross

                    t = 4; %for debugging
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
                            idx = min(find(abs(audiodata(1,:)) >= voicetrigger)); %#ok<MXFND>
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
                        % Blank screen after target until keypress
                        Screen('Flip', window); %show fixation cross
                     
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

                        if Condition(i)==1 %condition no cue
                            perNoCue=perNoCue+1;
                            rtNoCue=rtNoCue+RT(i);

                        else %condition cue
                            perCue=perCue+1;
                            rtCue=rtCue+RT(i);
                        end
                    end

                    if any(ismember(KbName(keyCode),KbName(leftKey))) && CorrectResponse(i)==leftKey %this is a hit for the letter 'A'
                        Accuracy(i)=1; %if hit correct key

                        if Condition(i)==1 %condition no cue
                            perNoCue=perNoCue+1;
                            rtNoCue=rtNoCue+RT(i);

                        else %condition cue
                            perCue=perCue+1;
                            rtCue=rtCue+RT(i);

                        end  
                    end

                    if any(ismember(KbName(keyCode),KbName(rightKey))) && CorrectResponse(i)==leftKey %this is a false positive for "A"
                        Accuracy(i)=0; %if hit uncorrect key
                        if Condition(i) == 2 %LHS cue is present
                            fpCue=fpCue+1;

                        else % Condition == 1 and cue isn't present
                            fpNoCue=fpNoCue+1;

                        end
                    end

                    if any(ismember(KbName(keyCode),KbName(leftKey))) && CorrectResponse(i)==rightKey %this is a false positive for "H"
                        Accuracy(i)=0; %if hit uncorrect key
                        if Condition(i) == 2 %LHS cue is present
                            fpCue=fpCue+1;

                        else % Condition == 1 and no cue is present
                            fpNoCue=fpNoCue+1;

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
          
WaitSecs(0.5) %wait a bit so screen doesn't just flash off
       
%% Experiment ends

%% END, CLOSE AND SAY THANKS
        Screen('TextSize', window, 40); %Set text size
        text = 'Thank you for taking part :)'; %message
        width=RectWidth(Screen ('TextBounds', window, text)); %width of message
        Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2, foregroundColor);
        Screen('Flip', window); %display message
        WaitSecs (2); %wait 2 seconds
        sca; %close ptb screen
        PsychPortAudio('Close', pahandle); %close audio drives
        t = 10; %for debugging

%% OUTPUT DATA
        %accuracy during cue and no cue
        if nrCue~=0 %calculating the accuracy during cue and nocue conditions from correct trials and false positives
            perCue=perCue*100/nrCue;
            rtCue=rtCue/nrCue;
            fpl=fpl*100/nrl;
        else
            perCue=0;
        end
        if nrNoCue~=0
            perNoCue=perNoCue*100/nrNoCue;
            fpNoCue=fpNoCue*100/nrr;
            rtNoCue=rtNoCue/nrNoCue;
        else
            perNoCue=0;
        end
        t = 11; %for debugging


catch % If there is an error in our try block, return the user to the MATLAB prompt.
        sca;
        rethrow(lasterror);
        ShowCursor;
        ListenChar(0);
        disp('Disconnect')
        save(matfilename)
end
%% DATA ANALYSIS
VRT = VRT'; %transforming VRT array from horiztonal to vertical
RT =  RT';
RT = RT*1000;
VRT = VRT*1000; %changing RT from s to ms (match VRT)
rts = [VRT RT];
%% Create Matrix for analysis. <- very useful to know
Matrix(:,1)= Condition;
Matrix(:,2)= Accuracy;
Matrix(:,3)= VRT;
Matrix(:,4)= RT;

corrplot(rts);

% Matrix(find(Matrix(:,3)>=1000),3)=NaN; %setting limits on matrix - filtereing VRT trials
% Matrix(find(Matrix(:,3)<=100),3)=NaN;

Valid=(length(find(Matrix(:,3)>=0.001))/nrtrials)*100; %percentage of trials that are valid
Accurate=(length(find(Matrix(:,2)>=0.001))/nrtrials)*100; %percentage of trials that are accurate

Time=toc/60; %timing and length of the experiment
save(matfilename)