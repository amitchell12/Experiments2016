%% AG.Mitchell - 26.05.16
%% Cued attention task (distractor)
% A cue is placed at a previously determined locaction on the LHS and
% presented simultaneously with a target (A/H) for 100ms
% Targets are randomly presented at different, evenly distributed,
% locations to the right of the cue
% The majority of conditions are cued but there are some conditions where
% targets are presented without the presence of a cue
% Patient/participant has to vocally identify target letter as fast and as
% accurately as possible, voice reaction time from target onset is measured
% The experimenter then presses a key to indicate what letter the
% patient/participant has said ('+' - H, '-' - A), this provides a measure
% of accuracy
% Both accuracy and reaction time are measured
% Output matrix provided 

%% Alex and Daniela 30.11.2015, using Barthel's script from the attention experiment Odoj and Balslev 2015
% Alex: added SMI_REDm eye tracking bits to this code instead of using Eyelink II.
% Code taken from 'RedmExampleCode.m' which is an edited version of
% 'DataStreaming.m', edited by BR.Innes

%% Clear all variables, connections, ...
clc
warning('off', 'all');

%% environment for the experiment
dummymode=0; %for testing and coding
practice=0; %for practice
sx=31; %cm, xscreen
sy=18; %cm yscreen
sd=57; %cm, dist eye-screen
audio = 1;
ParticipantID = 'p2';

%% input the cue position for chance perception. We want to show the cue at this location and targets at all set locations to the right of the cue
xcuedeg=-1.48375828686205; % TO INPUT from the graph in the step 1
nrtargets=20;

if practice == 0;
    trialnr=4; %nr of trials per target, change this depending on how far right the cue is (make higher the further right)
else
    trialnr=2;
end

%% Time and space variables
crosstime=1.5; %time between onset of fix cross and target, 500ms to allow patients to saccade back

cuetime=0.1; %length of cue, seconds

waittimemax=10000;%seconds, second stimulus and a response, 2AFC
letters(1)='A'; %target (key press - 1)
letters(2)='H'; %target (key press - 4)

targettime=0.100; %time of target onset

%% for voice RT
voicetrigger = 0.12;
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
%and use only target locations to the right of the cue
targets= targets(find(targets > xcuedeg+((screendeg-sizetargetdeg/2)/nrtargets)));
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
if practice == 0; %if not practice
    [Data,Text] = xlsread('TrialCounter_cue1.xlsx');
else
    [Data,Text] = xlsread('TrialCounter_cueprac.xlsx');
end

TargetLetter =  Data(:, ismember(Text, 'TargetLetter')); %defining target from xls file (A/H)TargetLetter: 1-A, 2-H

%% correct response keys
leftKey = KbName('-'); %this is a number that identifies the key; letter A
rightKey = KbName('+'); %letter H

%% Abort trial key
abortKey = KbName('5'); %press abort key if trial is rendered invalid
otherKey = KbName('space');

%% OUTPUT

%preallocation of variables, for the output
ActualResponse=[]; 
CorrectResponse=[];
timefixstarrt=[];
timecuestart=[];
timecueend=[];
timetargetend=[];
timetargetstart =[];
timekeypress=[];
VRT = [];
RT=[];
Abortedtrials=[];
Othertrials = [];

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

if practice == 0;
    matfilename = sprintf ('Cued_attention1%d%d%d%d%d.mat', datenow (1), datenow(2), datenow(3), datenow(4), datenow(5)); %name of the output file
else
    matfilename = sprintf ('Cued_attentionprac%d%d%d%d%d.mat', datenow (1), datenow(2), datenow(3), datenow(4), datenow(5)); %name of the output file
end

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
        sizetarg=sizetargetdeg*vadx; %size of target in pix;
        xcue=xcuedeg*vadx; % distance of cue in pixels
       
        %rect = [DisplayXSize/2+xcue-sizecue/2 DisplayYSize/2-sizecue/2 DisplayXSize/2+xcue+sizecue/2 DisplayYSize/2+sizecue/2]; %cue rectangle
        
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
            targetss(i) = targetss(i)*vadx;
            %% Marking trials
            if i == round(length(targetss)/4) %quarter of the way through
                Screen('TextSize', window, 30); %size of text
                text = 'You are 1/4 of the way through'; %message
                width=RectWidth(Screen ('TextBounds', window, text)); %width of text
                Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2, foregroundColor);
                Screen('Flip', window); %flip the text to the screen
                while KbCheck; %waif for key press
                end %wait for all keys are released
                keyisdown = 0;
                while ~keyisdown %wait for key press before moving onto next trial
                    [keyisdown] = KbCheck;
                    WaitSecs(0.001); % delay to prevent CPU hogging
                end
            elseif i == round(length(targetss)/2) %half of the way through
                Screen('TextSize', window, 30); %size of text
                text = 'Congratulations! You are half way! :)'; %message
                width=RectWidth(Screen ('TextBounds', window, text)); %width of text
                Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2, foregroundColor);
                Screen('Flip', window); %flip the text to the screen
                while KbCheck; %waif for key press
                end %wait for all keys are released
                keyisdown = 0;
                while ~keyisdown %wait for key press before moving onto next trial
                    [keyisdown] = KbCheck;
                    WaitSecs(0.001); % delay to prevent CPU hogging
                end
            elseif i == length(targetss)-9 %10 trials left
                Screen('TextSize', window, 30); %size of text
                text = 'Nearly there, only 10 trials left :)'; %message
                width=RectWidth(Screen ('TextBounds', window, text)); %width of text
                Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2, foregroundColor);
                Screen('Flip', window); %flip the text to the screen
                while KbCheck; %waif for key press
                end %wait for all keys are released
                keyisdown = 0;
                while ~keyisdown %wait for key press before moving onto next trial
                    [keyisdown] = KbCheck;
                    WaitSecs(0.001); % delay to prevent CPU hogging
                end
            end            
            % Show fixation cross
            text = '+';
            Screen('TextSize', window, textsizept); %size of text
            width=RectWidth(Screen ('TextBounds', window, text)); %fixation cross width and height
            height=RectHeight(Screen ('TextBounds', window, text));
            Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, foregroundColor); %fixation cross at center of the screen
            Screen('Flip', window); %show fixation cross
            timefixstart(i) = GetSecs;
            WaitSecs(crosstime); %wait length of fixation cross time depending on condition
            t = 3;           
            target=Stimulus(i);
            widtht=sizetarg; %width of the target
            heightt=sizetarg; %height of the target
            
%% Cue presentation
            cue = 'S';
            Screen('DrawText', window, cue, DisplayXSize/2+xcue-sizetarg/2, DisplayYSize/2-heightt/2, foregroundColor); %present cue
%% Target Presentation
            Screen('DrawText', window, target, DisplayXSize/2+targetss(i)-sizetarg/2, DisplayYSize/2-heightt/2, foregroundColor); %draw target
            Screen('Flip', window);
            timecuestart(i) = GetSecs;
            timetargetstart(i) = GetSecs;         
            PsychPortAudio('Start', pahandle, 0, 0, 1); %start audio reading for the trials             
            %flip to fixation cross on screen
            WaitSecs(targettime) %wait time of target
            Screen('Flip', window); %take target off
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
                    if any(ismember(KbName(keyCode),[KbName(leftKey), KbName(rightKey), KbName(abortKey), KbName(otherKey)])) %key press options - leftkey ('1'), rightkey ('4')
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
                    Abortedtrials(i) = 0;
                    Otherkey(i) = 0;
                end

                if any(ismember(KbName(keyCode),KbName(leftKey))) && CorrectResponse(i)==leftKey %this is a hit for the letter 'A'
                    Accuracy(i)=1; %if hit correct key
                    Abortedtrials(i) = 0;
                    Otherkey(i) = 0;
                end

                if any(ismember(KbName(keyCode),KbName(rightKey))) && CorrectResponse(i)==leftKey %this is a false positive for "A"
                    Accuracy(i)=0; %if hit uncorrect key
                    Abortedtrials(i) = 0;
                    Otherkey(i) = 0;
                end

                if any(ismember(KbName(keyCode),KbName(leftKey))) && CorrectResponse(i)==rightKey %this is a false positive for "H"
                    Accuracy(i)=0; %if hit uncorrect key
                    Abortedtrials(i) = 0;
                    Otherkey(i) = 0;
                end
                
                if any(ismember(KbName(keyCode), KbName(abortKey)))
                    Accuracy(i) = 0;
                    Abortedtrials(i) = 1;  %if abort key is pressed, trial is marked
                    Otherkey(i) = 0;
                end
                
                if any(ismember(KbName(keyCode), KbName(otherKey)))
                    Accuracy(i) = 0;
                    Abortedtrials(i) = 0;  %if abort key is pressed, trial is marked
                    Otherkey(i) = 1;
                end
            end

            if flag2==0 %no key press
                ActualResponse(i)=NaN; %record responses as NaN when no key is pressed
                RT(i)=NaN;
                timekeypress(i)=NaN;
                Accuracy(i)=0;
                VRT(i)=NaN;
                Abortedtrials(i) = 0;
            end 
            t = 9; %for debugging
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
       
        PsychPortAudio('Close', pahandle); %close audio drives
        t = 10; %for debugging

catch % If there is an error in our try block, return the user to the MATLAB prompt.
        sca;
        ShowCursor;
        rethrow(lasterror);
        ListenChar(0);
        disp('Disconnect')
        save(matfilename)
end
%% Save - incase things go wrong with analysis
save(matfilename)

%% DATA ANALYSIS
VRT = VRT'; %transforming VRT array from horiztonal to vertical
RT =  RT';
RT = RT*1000;
VRT = VRT*1000; %changing RT from s to ms (match VRT)
%rts = [VRT RT];

%% Create Matrix for analysis. <- very useful to know

targloc = [];

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

%% Create Matrix for analysis. <- very useful to know
Matrix1 = [];
Matrix1(:,1)= targetss;
Matrix1(:,2)= Accuracy;
Matrix1(:,3)= VRT;
Matrix1(:,4)= RT;
Matrix1(:,5)= targloc;
Matrix1(:,6)= Abortedtrials;
Matrix1(:,7)= Othertrials;

Valid1=(length(find(Matrix1(:,3)>=0.001))/nrtrials)*100; %percentage of trials that are valid
Accurate1=(length(find(Matrix1(:,2)>=0.001))/nrtrials)*100; %percentage of trials that are accurate

%% SAVE
save(matfilename)