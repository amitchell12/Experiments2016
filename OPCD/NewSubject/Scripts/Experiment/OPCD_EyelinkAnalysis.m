%% AG.MITCHELL - 21.12.15
%% This script will run analysis on Eyelink ASCII file 
% Transforming timesamples into ms timestamps from Eyelink 'SYNCTIME'
% message 
% Transforming X and Y amplitudes for left and right eye from pixels into
% visual angles (in deg)
% Plotting graphs of saccade amplitude for X and Y eye angles against time
% in ms
% Showing '+' when the SOUNDON message is present (when a sound is
% presented to participant instructing them to push eye)

%% Retreving file

% % convert unreadable edf file into readable asc file
% Shouldn't need this but is in analysis file just incase

% [EH, EJ, EX] = dbrede_read_edfsnd('EyeBi.asc');
% % [EH, EJ, EX] = readEyeData('mainr.asc'); % for when using left
% % eye
% datenow(1:6) = fix(clock);
% eyeSaveName = ['EYE'  num2str(datenow(1)), num2str(datenow(2)), num2str(datenow(3)), num2str(datenow(4)), num2str(datenow(5)), num2str(datenow(6))];
% save(eyeSaveName, 'EH', 'EJ', 'EX');
% disp('Eye movement data ready for further analysis'); 
% disp(' '); 

% Data file has to be in same folder as script
ppt = 'test'; %participant identity
filename=uigetfile('EYE*.mat', 'pick up eyepos matrices file'); %get eye-position file
load (filename);
matfilename = sprintf('OP_%s', ppt); %name of mat.file

%% Get screen dimensions and visual deg

sx = 41; %screen width cm
sy = 23; %screen length cm
sd = 60; %distance away from screen cm
%% experiment file doesn't have these which is why they're here
DisplayXSize = 1366; % in pixels - change these depending on computer
DisplayYSize = 768;

%find pixels/cm
vadxcm=DisplayXSize/sx; %pix per 1 cm
vadycm=DisplayYSize/sy;
% number of degrees per pixel
vadx=(atan(1/sd)*180/pi)/vadxcm; % vad in deg visual angle for 1 pixel
vady=(atan(1/sd)*180/pi)/vadycm; 

% formula for pixels to deg
% size_deg = size_pix * deg_pix

%% Get varaibles

%  Cacluating time data surrounding 'sound on'
ms_presound = 500; %ms to analyse before sound
ms_postsound = 4000; %ms to analyse after sound
sample_freq = 250; %frequency of eyelink sampling in Hz
presound = ms_presound*sample_freq/1000; %calculating number of samples before sound
postsound = ms_postsound*sample_freq/1000; %calculating number of samples after sound
nrtrials = length(EH.matrix(:,1)); %number of samples

soundoff_mark = 875; %indicating where in the sound marix the sound comes off
sample_intms = 4; %the sampling interval for the eye tracker in ms
fours = 1126; %the four second mark (row) in the time vector

%% Getting eye-tracking variables
timestamp = EH.matrix(:,1);
LXsaccAmp = EH.matrix(:,2);
LYsaccAmp = EH.matrix(:,3);
RXsaccAmp = EH.matrix(:,5);
RYsaccAmp = EH.matrix(:,6);
sacc = EH.matrix(:,8);
blink = EH.matrix(:,9);
soundon = EH.matrix(:,10);
blockno = EH.matrix(:,11);
trialcounter = EH.matrix(:,12);

% time interval
timenr=1000/sample_freq; %time samples in ms for eye-tracker
trialstart = 0; 

for i = 1:length(EH.matrix(:,1))
    time(i) = (i*timenr)/1000; %time in s
    soundon(soundon==0) = NaN; %converting all 'sound off' values to NaN
    soundon(i) = soundon(i)*-3;
    LXAmp_deg(i) = (LXsaccAmp(i)-683)*vadx;
    LYAmp_deg(i) = (LYsaccAmp(i)-384)*vadx;
    RXAmp_deg(i) = (RXsaccAmp(i)-683)*vadx;
    RYAmp_deg(i) = (RYsaccAmp(i)-384)*vadx;
end

%% Minus saccade amplitude in right eye from saccade amplitude in left eye

for i = 1:length(EH.matrix(:,1))
    XAmp_deg(i) = RXAmp_deg(i)-LXAmp_deg(i);
    YAmp_deg(i) = RYAmp_deg(i)-LYAmp_deg(i);
end


%% Make own matrix

EyeOP = [];
EyeOP(:,1) = time; %time in s
EyeOP(:,2) = soundon; %sound on marker
EyeOP(:,3) = LXAmp_deg; %left eye x amplitudes (deg)
EyeOP(:,4) = LYAmp_deg; %left eye y amplitudes (deg)
EyeOP(:,5) = RXAmp_deg; %right eye x amplitudes (deg)
EyeOP(:,6) = RYAmp_deg; %right eye y amplitudes (deg)
EyeOP(:,7) = XAmp_deg; %both eye x amplitudes (deg)
EyeOP(:,8) = YAmp_deg; %both eye y amplitudes (deg)
EyeOP(:,9) = trialcounter; %to count the number of trials (deg)

%% Plotting graphs for saccade amplitude

%% Plotting variables
xmin = 0; %axis minimum and maximum for plotting
xmax = 40;
ymin = -5;
ymax = 5;

%OP condition - use when analysing OP data (in the dark)
% Left X amplitude
LXampOP = figure(1);
plot(time, LXAmp_deg, 'k');
axis([xmin xmax ymin ymax]);
hold on
scatter(time, soundon, 'r*'), legend('X position', 'Sound On');
title('Saccade amplitude (X position) of left eye in darkness');
xlabel('Time (s)');
ylabel('Eye movement amplitude in degrees');

% Left Y amplitude
LYampOP = figure(2);
plot(time, LYAmp_deg, 'k');
axis([xmin xmax ymin ymax]);
hold on
scatter(time, soundon, 'r*'), legend('Y position', 'Sound On');
title('Saccade amplitude (Y position) of left eye in darkness');
xlabel('Time (s)');
ylabel('Eye movement amplitude in degrees');

% Right X amplitude
RXampOP = figure(3);
plot(time, RXAmp_deg, 'k');
axis([xmin xmax ymin ymax]);
hold on
scatter(time, soundon, 'r*'), legend('X position', 'Sound On');
title('Saccade amplitude (X position) of right eye in darkness');
xlabel('Time (s)');
ylabel('Eye movement amplitude in degrees');

% Right Y amplitude
RYampOP = figure(4);
plot(time, RYAmp_deg, 'k');
axis([xmin xmax ymin ymax]);
hold on
scatter(time, soundon, 'r*'), legend('Y position', 'Sound On');
title('Saccade amplitude (Y position) of right eye in darkness');
xlabel('Time (s)');
ylabel('Eye movement amplitude in degrees');

%% Getting translated plots
% Sampling 4s around 'soundon' (500ms before, 3000ms sound, 500ms after)

LXMat = []; %left and right eye translated matrices for every 'sound on' trial (x and y degrees)
RXMat = [];
LYMat = [];
RYMat = [];

I= find(EyeOP(:,9));%finds the nonzero elements, when sound was presented
I= I(1:end-1);
timems = time*1000; %converting time from s to ms
sound = trialcounter(I-presound:I+postsound); %localising 'sound on' per trial
sound(soundoff_mark,1) = 1; %localising 'sound off' per trial
sound(sound==0) = NaN; %converting all 0s to NaNs so they are not plotted
sound = sound*0.01; %changing value of 1s to fit graphs
soundwindow = 1:sample_intms:timems(1, fours); %the 'sound on' time window (-500ms:sound:3500ms) in ms, for plotting

for i=1:length(I); %indexing
    
    %calculating the mean value 500ms before sound on
    MLXbs(i)=mean(LXAmp_deg(I(i)-presound:I(i))); %left eye x deg
    MRXbs(i)=mean(RXAmp_deg(I(i)-presound:I(i))); %right eye x deg
    MLYbs(i)=mean(LYAmp_deg(I(i)-presound:I(i))); %left eye y deg
    MRYbs(i)=mean(RYAmp_deg(I(i)-presound:I(i))); %right eye y deg
    
    %subtracting mean value from 500ms before soundon + 3500ms after sound
    %on
    lxOP = LXAmp_deg(I(i)-presound:I(i) + postsound); % values for left eye x deg
    rxOP = RXAmp_deg(I(i)-presound:I(i) + postsound); % values for right eye x deg
    lyOP = LYAmp_deg(I(i)-presound:I(i) + postsound); % values for left eye y deg
    ryOP = RYAmp_deg(I(i)-presound:I(i) + postsound); % values for right eye y deg
    
    tlxOP = (lxOP) - MLXbs(i); %translated values for left eye x deg
    trxOP = (rxOP) - MRXbs(i); %translated values for right eye x deg
    tlyOP = (lyOP) - MLYbs(i); %translated values for left eye y deg
    tryOP = (ryOP) - MRYbs(i); %translated values for right eye y deg

    %% PLOTS
    
    %% Plotting variables
    
    xsoundmin = 0;
    xsoundmax = 4500; %time window along x-axis in ms
    % use previous y min and y max for these plots
    
    % plotting the overlapped translated data
    % 1: covered eye x deg, 2: pushed eye x deg, 3: covered eye y deg, 4:
    % pushed eye y deg
    figure(7)
    plot(soundwindow, tlxOP);
    hold on 
    scatter(soundwindow, sound, 'k*');
    hold on
    axis([xsoundmin xsoundmax ymin ymax]);
    xlabel('Time (ms)'); ylabel('Saccade amplitude (deg)');
    title('Covered eye in darkness, X degrees');
    
    figure(8)
    plot(soundwindow, trxOP);
    hold on
    scatter(soundwindow, sound, 'k*');
    hold on
    axis([xsoundmin xsoundmax ymin ymax]);
    xlabel('Time (ms)'); ylabel('Saccade amplitude (deg)');
    title('Pushed eye in darkness, X degrees');
    
    figure(9)
    plot(soundwindow, tlyOP);
    hold on 
    scatter(soundwindow, sound, 'k*');
    hold on
    axis([xsoundmin xsoundmax ymin ymax]);
    xlabel('Time (ms)'); ylabel('Saccade amplitude (deg)');
    title('Covered eye in darkness, Y degrees');
    
    figure(10)
    plot(soundwindow, tryOP);
    hold on
    scatter(soundwindow, sound, 'k*');
    hold on
    axis([xsoundmin xsoundmax ymin ymax]);
    xlabel('Time (ms)'); ylabel('Saccade amplitude (deg)');
    title('Pushed eye in darkness, Y degrees');
    
    %making matrices of translated values so can average these later
    LXMat(:, i) = tlxOP;
    RXMat(:, i) = trxOP;
    LYMat(:, i) = tlyOP;
    RYMat(:, i) = tryOP;
   
end

%% Filtering trials in L and R eye matrices
trialmax = 5; %maximum and minimum eye movement values, so that eye movement does not get in the way of data
trialmin = -5;

% Fitering out trials where means are >5 or <-5 for left and right eye (x
% and y deg)
for i = 1:length(I)
    LXMat(find(mean(LXMat(:,i))>trialmax | mean(LXMat(:,i))<trialmin),i) = NaN;
    LYMat(find(mean(LYMat(:,i))>trialmax | mean(LYMat(:,i))<trialmin),i) = NaN;
    RXMat(find(mean(RXMat(:,i))>trialmax | mean(RXMat(:,i))<trialmin),i) = NaN;
    RYMat(find(mean(RYMat(:,i))>trialmax | mean(RYMat(:,i))<trialmin),i) = NaN;
end

RYMat = RYMat'; %transposing so can filter out rows (old columns) containing NaNs
LXMat = LXMat';
LYMat = LYMat';
RXMat = RXMat';
RYMat = RYMat(find(RYMat(:,1) > 0.0001 | RYMat(:,1) < 0.0001),:); %filtering out rows that contain NaNs (aka: with the mean value >5 or <-5)
LXMat = LXMat(find(LXMat(:,1) > 0.0001 | LXMat(:,1) < 0.0001),:);
LYMat = LYMat(find(LYMat(:,1) > 0.0001 | LYMat(:,1) < 0.0001),:);
RXMat = RXMat(find(RXMat(:,1) > 0.0001 | RXMat(:,1) < 0.0001),:);

%% Getting minimum values for 500ms window after fixation off (0-500ms)
% Compare these to mininmum values from 500ms before fixation is off (500ms - 0)

ms_fixend = 2900;
fixend = ms_fixend*sample_freq/1000; %calculating number of samples for 500ms after fixation comes on
ms_postfix = 1000;
postfix = ms_postfix*sample_freq/1000; %calculating number needed for post fixation on calucation

% Minimum values 500ms before fixation disappears (premin) and after
% (postmin) for the left (covered) eye
for i = 1:length(I);
    LX_pre(i) = min(LXAmp_deg(I(i) + fixend - postfix: I(i) + fixend));
    LX_post(i) = min(LXAmp_deg(I(i) + fixend: I(i) + fixend + postfix));
    LY_pre(i) = min(LYAmp_deg(I(i) + fixend - postfix: I(i) + fixend));
    LY_post(i) = min(LYAmp_deg(I(i) + fixend: I(i) + fixend + postfix));
    RX_pre(i) = min(RXAmp_deg(I(i) + fixend - postfix: I(i) + fixend));
    RX_post(i) = min(RXAmp_deg(I(i) + fixend: I(i) + fixend + postfix));
    RY_pre(i) = min(RYAmp_deg(I(i) + fixend - postfix: I(i) + fixend));
    RY_post(i) = min(RYAmp_deg(I(i) + fixend: I(i) + fixend + postfix));
    
    mLX_pre = mean(LX_pre(i)); % Mean of the mininum values
    mLX_post = mean(LX_post(i));
    mLY_pre = mean(LY_pre(i));
    mLY_post = mean(LY_post(i));
    mRX_pre = mean(RX_pre(i));
    mRX_post = mean(RX_post(i));
    mRY_pre = mean(RY_pre(i));
    mRY_post = mean(RY_post(i));
end

%% Getting averages
% Cumulating translated samples from around 'soundon'
% Need to average each row in LX and RX Mat and then plot average

% First need to transpose back before averaging and plotting
RYMat = RYMat';
LXMat = LXMat';
LYMat = LYMat';
RXMat = RXMat';

for i = 1:length(LXMat);
    av_lxOP(i) = mean(LXMat(i, :));
    av_rxOP(i) = mean(RXMat(i, :));
end
% Do the same for Y values
for i = 1:length(LYMat);
    av_lyOP(i) = mean(LYMat(i, :));
    av_ryOP(i) = mean(RYMat(i, :));
end

%% Plotting averages

%left and right average eye plot for X deg
figure(11)
plot(soundwindow, av_lxOP);
hold on
plot(soundwindow, av_rxOP);
hold on
axis([xsoundmin xsoundmax ymin ymax]);
scatter(soundwindow, sound, 'k*');
xlabel('Time (ms)'); ylabel('Saccade amplitude (deg)');
title('Cumulative eye movement in darkness - X degrees');
legend('Left eye', 'Right eye', 'Fix on and off')

%left and right average eye plot for Y deg
figure(12)
plot(soundwindow, av_lyOP);
hold on
plot(soundwindow, av_ryOP);
hold on
scatter(soundwindow, sound, 'k*');
axis([xsoundmin xsoundmax ymin ymax]);
xlabel('Time (ms)'); ylabel('Saccade amplitude (deg)');
title('Cumulative eye movement in darkness - Y degrees');
legend('Left eye', 'Right eye', 'Fix on and off')

save(matfilename)
