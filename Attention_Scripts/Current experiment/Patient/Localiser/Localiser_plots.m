%% Plotting accuracy and RT for localiser task

%% Files and varaibles
% Data file has to be in same folder as script
% Load participant matfile
session1=uigetfile('Localiser_1*.mat');
load (session1);
session2=uigetfile('Localiser_2*.mat');
load (session2);
session3=uigetfile('Localiser_3*.mat');
load (session3);

% % Or, for data filed with SMI analysis (pilots mostly)
% session1=uigetfile('*_Localiser1.mat');
% load (session1);
% session2=uigetfile('*_Localiser2*.mat');
% load (session2);
% session3=uigetfile('*_Localiser3*.mat');
% load (session3);

Av_acc = [Av_acc1; Av_acc2; Av_acc3];

for i = 1:length(Av_acc)
    Av_allacc(i) = mean(Av_acc(:,i));
end

Av_VRT = [Av_VRT1; Av_VRT2; Av_VRT3];

for i = 1:length(Av_VRT)
    Av_allVRTloc(i) = mean(Av_VRT(:,i));
end

Av_valid = [Valid1; Valid2; Valid3];

for i = 1:length(Av_valid)
    Av_allValid(i) = mean(Av_valid(i));
end

% % only for when eye tracking
Av_valideye = [Valid_eye1; Valid_eye2; Valid_eye3];

for i = 1:length(Av_valideye)
    Av_allValideye(i) = mean(Av_valideye(i));
end

%% Plots

% Average accuracy
figure(1)
plot(targets, Av_allacc, 'b');
axis([-16 16 0 100]);
xlabel('Target location (deg)'); ylabel('Percentage accuracy');
title('Effect of target location on accuracy');

% Average VRT
figure(2)
plot(targets, Av_allVRTloc, 'r');
axis([-16 16 450 850]);
xlabel('Target location (deg)'); ylabel('Mean VRT(ms)');
title('Effect of target location on response time');

matfilename = sprintf('%s_Localiserall', ParticipantID);
save(matfilename)