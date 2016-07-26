%% AG.Mitchell - 26.07.16
% Script that helps instruct participants on what to do during OPCD
% experiment
% Plays tone to indicate eye push
% Then plays tone to indicate no eye push (control)
% Then gives the participant a chance to practice this eye-push a little
% whilst the experimenter can check, before moving to actual practice trial

%% Starting instruction script...
clear
clc;

%% Experimental environment
dummyMode = 1; %for testing
sx = 41; %xcm screen
sy = 23; %ycm screen
sd = 60; %cm distance from viewer

%% Making beeps
beepfreq = 500; %push beep frequency (Hz)
cbeepfreq = 700; %control beep
beepdur = 3; %duration of beep in s

% Making push beep and control beep
pbeep = MakeBeep(beepfreq, beepdur); %push beep
pbeep = pbeep/3; %reducing sound intensity
cbeep = MakeBeep(cbeepfreq, beepdur); %control beep
cbeep = cbeep/3;

%% Psychtoolbox Variables
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


if dummyMode==1%For debugging use a smaller window
 [window,rect] = Screen('OpenWindow', screenNumber, black,[ RectLeft, RectTop RectLeft+800 RectTop+200]); %for testing    
else
 [window,rect]= Screen('OpenWindow', screenNumber, black); %full screen window
end
[winWidth, winHeight] = WindowSize(window);  
HideCursor;

%% Text
textpt = 0.0352; %cm for 1 pt
textsizedeg = 1.5; %degrees, visual crowding in fovea under 0.2 deg; 0.35 deg visual angle, size of one letter according to Spinelli 2002;
textsizecm = tan(pi*textsizedeg/360)*2*sd; %in cm
textsizept = round(textsizecm/textpt); %in pt, for some reason this number needs to be doubled
Screen('TextSize', window, textsizept);

%% Display dimensions 
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

%% Push tone intro
DrawFormattedText(window, 'You will now hear the push tone', 'center', 'center', white);
Screen('Flip', window);
KbStrokeWait; %wait for keypress
Screen('Flip', window);

% Fixation cross
text = '+';
width=RectWidth(Screen ('TextBounds', window, text));
height=RectHeight(Screen ('TextBounds', window, text));
Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, white); %fixation cross at center
Screen('Flip', window);

% Play push beep
Snd('Play', pbeep); %play 3s beep
WaitSecs(3);
Snd('Quiet'); %quiet
KbStrokeWait; %wait for keypress

%% Control tone intro
DrawFormattedText(window, 'You will now hear the control tone', 'center', 'center', white);
Screen('Flip', window);
KbStrokeWait; %wait for keypress
Screen('Flip', window);

% Fixation cross
Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, white); %fixation cross at center
Screen('Flip', window);

% Play control beep
Snd('Play', cbeep); %play 3s beep
WaitSecs(3);
Snd('Quiet'); %quiet
KbStrokeWait; %wait for keypress

Screen('Flip', window);

%% Small practice loop
% Gives participants a chance to pracitce push and experimenter a chance to
% correct them if wrong

%% Trial matrix
[Data, Text] = xlsread('TrialMatrix_intro');

Cond = Data(:, ismember(Text, 'Cond')); %1 for push, 0 for control
nrtrials = length(Cond);

% Introduction screen
DrawFormattedText(window, 'You can now practice the eye push', 'center', 'center', white);
Screen('Flip', window);
KbStrokeWait; %wait for key press

% Show fixation
Screen('DrawText', window, text, DisplayXSize/2 - width/2, DisplayYSize/2-height/2, white); %fixation cross at center
Screen('Flip', window);

% Loop beeps (alternating push and control)
for i = 1:nrtrials
    WaitSecs(0.5); %wait 500ms
    if Cond(i) == 1; %if condition 1 (push) play lower freq beep
        Snd('Play', pbeep);
        WaitSecs(3);
        Snd('Quiet');
    else %Cond(i) == 0, control condition plays higher frequency beep
        Snd('Play', cbeep);
        WaitSecs(3);
        Snd('Quiet');
    end
    WaitSecs(1) %wait 1s
end

WaitSecs(0.5);
Screen('Flip', window);
sca; %closes screen
%% End