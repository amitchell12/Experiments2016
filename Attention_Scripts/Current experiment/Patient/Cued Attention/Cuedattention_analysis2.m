%% AG.Mitchell - 18.12.15, edited at 24.02.16 by AG.Mitchell
%% This script analyses eye tracking data for the AttentionLVF cue task (SMIREDm with iViewX)
% Lays out important variables (VRT, saccades, cueon, targeton etc) into a
% single matrix for analysis
% Lays out saccade information into readable matrix
% Timestamps fixation from the fixation onset and discards trials where
% participant has saccaded over a certain amount (need to work this out from deg of fixation
% cross) - changes these timestamps to seconds
% Also excludes trials were VRT is too fast (<50ms) or too slow (>1500ms)

%% Files and varaibles
% Data file has to be in same folder as script
% Load participant matfile
session2=uigetfile('Cued_attention2*.mat');
load (session2);

%% Making matrix

targetss = Matrix2(:,1);
Accuracy = Matrix2(:,2);
VRT  = Matrix2(:,3);
RT = Matrix2(:,4);
targloc = Matrix2(:,5);
Abortedtrials = Matrix2(:,6);

VRTmax = 1500;
VRTmin = 350;
RTmax = 1500;
RTmin = 150;
eyemax = 1;

matfilename = sprintf('%s_CuedAttention2', ParticipantID);
save(matfilename)

audio = 1; %is VRT used?

%% Convert to smaller, easier matrix
Matrix2(:,1)= targetss;
Matrix2(:,2)= Accuracy;
Matrix2(:,3)= VRT;
Matrix2(:,4)= RT;
Matrix2(:,5)= targloc;
Matrix2(:,6) = Abortedtrials;

%% Filter trials

if audio
    Matrix2(find(Matrix2(:,3)>=VRTmax),3)=NaN;
    Matrix2(find(Matrix2(:,3)<=VRTmin),3)=NaN;
end
Matrix2(find(Matrix2(:,4)>=RTmax),4)=NaN;
Matrix2(find(Matrix2(:,4)<=RTmin),4)=NaN;

Valid1 =(length(find(Matrix2(:,2)>=0.001&Matrix2(:,6)<0.001))/nrtrials)*100; %percentage valid trials
AccurateAll1 =(length(find(Matrix2(:,3)>=0.001))/nrtrials)*100; %percentage invalid trials

%% Matrix with valid values (and eyemax < 1)

Matrix2=Matrix2(find(Matrix2(:,3)>=0.001&Matrix2(:,6)<0.001),:);

%% Isolate target locations
% Using 'targ loc' to find accuracy and RT values for each target location
% May need to 'comment' some of these depending on location of the xcue

Ltarg10 = Matrix2(find(Matrix2(:,5)==1),:); %left target locations from left -> right 
Ltarg9 = Matrix2(find(Matrix2(:,5)==2),:);
Ltarg8 = Matrix2(find(Matrix2(:,5)==3),:);
Ltarg7 = Matrix2(find(Matrix2(:,5)==4),:);
Ltarg6 = Matrix2(find(Matrix2(:,5)==5),:);
Ltarg5 = Matrix2(find(Matrix2(:,5)==6),:);
Ltarg4 = Matrix2(find(Matrix2(:,5)==7),:);
Ltarg3 = Matrix2(find(Matrix2(:,5)==8),:);
Ltarg2 = Matrix2(find(Matrix2(:,5)==9),:);
Ltarg1 = Matrix2(find(Matrix2(:,5)==10),:);
targ0 = Matrix2(find(Matrix2(:,5)==11),:); %target at location 0
Rtarg1 = Matrix2(find(Matrix2(:,5)==12),:); %right target locations from left -> right
Rtarg2 = Matrix2(find(Matrix2(:,5)==13),:);
Rtarg3 = Matrix2(find(Matrix2(:,5)==14),:);
Rtarg4 = Matrix2(find(Matrix2(:,5)==15),:);
Rtarg5 = Matrix2(find(Matrix2(:,5)==16),:);
Rtarg6 = Matrix2(find(Matrix2(:,5)==17),:);
Rtarg7 = Matrix2(find(Matrix2(:,5)==18),:);
Rtarg8 = Matrix2(find(Matrix2(:,5)==19),:);
Rtarg9 = Matrix2(find(Matrix2(:,5)==20),:);
Rtarg10 = Matrix2(find(Matrix2(:,5)==21),:);

ordered_targets = [Ltarg10; Ltarg9; Ltarg8; Ltarg7; Ltarg6; Ltarg5; Ltarg4; Ltarg3; Ltarg2; Ltarg1; targ0; Rtarg1; Rtarg2; Rtarg3; Rtarg4; Rtarg5; Rtarg6; Rtarg7; Rtarg8; Rtarg9; Rtarg10];
%% Averaging accuracy
% Taking mean accuracy for all target locations

%% Possible solution but unsure...
% I = find(ordered_targets(:,5));
% 
% for i = 1:ordered_targets(end);
%     Macc(i) = mean(acc(I(i)))*100;
% end

%% For now
Macc_Ltarg10 = nanmean(Ltarg10(:,2))*100; %mean accuracy for each target location
Macc_Ltarg9 = nanmean(Ltarg9(:,2))*100;
Macc_Ltarg8 = nanmean(Ltarg8(:,2))*100;
Macc_Ltarg7 = nanmean(Ltarg7(:,2))*100;
Macc_Ltarg6 = nanmean(Ltarg6(:,2))*100;
Macc_Ltarg5 = nanmean(Ltarg5(:,2))*100;
Macc_Ltarg4 = nanmean(Ltarg4(:,2))*100;
Macc_Ltarg3 = nanmean(Ltarg3(:,2))*100;
Macc_Ltarg2 = nanmean(Ltarg2(:,2))*100;
Macc_Ltarg1 = nanmean(Ltarg1(:,2))*100;
Macc_targ0 = nanmean(targ0(:,2))*100;
Macc_Rtarg1 = nanmean(Rtarg1(:,2))*100;
Macc_Rtarg2 = nanmean(Rtarg2(:,2))*100;
Macc_Rtarg3 = nanmean(Rtarg3(:,2))*100;
Macc_Rtarg4 = nanmean(Rtarg4(:,2))*100;
Macc_Rtarg5 = nanmean(Rtarg5(:,2))*100;
Macc_Rtarg6 = nanmean(Rtarg6(:,2))*100;
Macc_Rtarg7 = nanmean(Rtarg7(:,2))*100;
Macc_Rtarg8 = nanmean(Rtarg8(:,2))*100;
Macc_Rtarg9 = nanmean(Rtarg9(:,2))*100;
Macc_Rtarg10 = nanmean(Rtarg10(:,2))*100;

Av_acc2= [Macc_Ltarg10 Macc_Ltarg9 Macc_Ltarg8 Macc_Ltarg7 Macc_Ltarg6 Macc_Ltarg5 Macc_Ltarg4 Macc_Ltarg3 Macc_Ltarg2 Macc_Ltarg1 Macc_targ0 Macc_Rtarg1 Macc_Rtarg2 Macc_Rtarg3 Macc_Rtarg4 Macc_Rtarg5 Macc_Rtarg6 Macc_Rtarg7 Macc_Rtarg8 Macc_Rtarg9 Macc_Rtarg10];

%% Creating new matrix excluding inaccurate trials
Matrix2 = Matrix2(find(Matrix2(:,2)>=0.001),:);

%% Isolate target locations (again, including accuracy filter)
% Using 'targ loc' to find accuracy and RT values for each target location
% May need to 'comment' some of these depending on location of the xcue

Ltarg10 = Matrix2(find(Matrix2(:,5)==1),:); %left target locations from left -> right 
Ltarg9 = Matrix2(find(Matrix2(:,5)==2),:);
Ltarg8 = Matrix2(find(Matrix2(:,5)==3),:);
Ltarg7 = Matrix2(find(Matrix2(:,5)==4),:);
Ltarg6 = Matrix2(find(Matrix2(:,5)==5),:);
Ltarg5 = Matrix2(find(Matrix2(:,5)==6),:);
Ltarg4 = Matrix2(find(Matrix2(:,5)==7),:);
Ltarg3 = Matrix2(find(Matrix2(:,5)==8),:);
Ltarg2 = Matrix2(find(Matrix2(:,5)==9),:);
Ltarg1 = Matrix2(find(Matrix2(:,5)==10),:);
targ0 = Matrix2(find(Matrix2(:,5)==11),:); %target at location 0
Rtarg1 = Matrix2(find(Matrix2(:,5)==12),:); %right target locations from left -> right
Rtarg2 = Matrix2(find(Matrix2(:,5)==13),:);
Rtarg3 = Matrix2(find(Matrix2(:,5)==14),:);
Rtarg4 = Matrix2(find(Matrix2(:,5)==15),:);
Rtarg5 = Matrix2(find(Matrix2(:,5)==16),:);
Rtarg6 = Matrix2(find(Matrix2(:,5)==17),:);
Rtarg7 = Matrix2(find(Matrix2(:,5)==18),:);
Rtarg8 = Matrix2(find(Matrix2(:,5)==19),:);
Rtarg9 = Matrix2(find(Matrix2(:,5)==20),:);
Rtarg10 = Matrix2(find(Matrix2(:,5)==21),:);

%% Averaging VRT
MVRT_Ltarg10 = nanmean(Ltarg10(:,3)); %mean VRT for each target location
MVRT_Ltarg9 = nanmean(Ltarg9(:,3));
MVRT_Ltarg8 = nanmean(Ltarg8(:,3));
MVRT_Ltarg7 = nanmean(Ltarg7(:,3));
MVRT_Ltarg6 = nanmean(Ltarg6(:,3));
MVRT_Ltarg5 = nanmean(Ltarg5(:,3));
MVRT_Ltarg4 = nanmean(Ltarg4(:,3));
MVRT_Ltarg3 = nanmean(Ltarg3(:,3));
MVRT_Ltarg2 = nanmean(Ltarg2(:,3));
MVRT_Ltarg1 = nanmean(Ltarg1(:,3));
MVRT_targ0 = nanmean(targ0(:,3));
MVRT_Rtarg1 = nanmean(Rtarg1(:,3));
MVRT_Rtarg2 = nanmean(Rtarg2(:,3));
MVRT_Rtarg3 = nanmean(Rtarg3(:,3));
MVRT_Rtarg4 = nanmean(Rtarg4(:,3));
MVRT_Rtarg5 = nanmean(Rtarg5(:,3));
MVRT_Rtarg6 = nanmean(Rtarg6(:,3));
MVRT_Rtarg7 = nanmean(Rtarg7(:,3));
MVRT_Rtarg8 = nanmean(Rtarg8(:,3));
MVRT_Rtarg9 = nanmean(Rtarg9(:,3));
MVRT_Rtarg10 = nanmean(Rtarg10(:,3));

Av_VRT2 = [MVRT_Ltarg10 MVRT_Ltarg9 MVRT_Ltarg8 MVRT_Ltarg7 MVRT_Ltarg6 MVRT_Ltarg5 MVRT_Ltarg4 MVRT_Ltarg3 MVRT_Ltarg2 MVRT_Ltarg1 MVRT_targ0 MVRT_Rtarg1 MVRT_Rtarg2 MVRT_Rtarg3 MVRT_Rtarg4 MVRT_Rtarg5 MVRT_Rtarg6 MVRT_Rtarg7 MVRT_Rtarg8 MVRT_Rtarg9 MVRT_Rtarg10];

%% Plots
targets=((-screendeg+sizetargetdeg/2)/nrtargets)*nrtargets/2:(screendeg-sizetargetdeg/2)/nrtargets:((screendeg-sizetargetdeg/2)/nrtargets)*nrtargets/2;
targets = round(targets, 2);

% Average accuracy
figure(1)
hold on; 
plot(targets, Av_acc2, 'b');
ax = gca; 
set(ax, 'Xtick', targets);
axis([min(targets) max(targets) 0 100]);
xlabel('Target location (deg)'); ylabel('Percentage accuracy');
title('Effect of target location on accuracy');

% Average VRT
figure(2)
plot(targets, Av_VRT2, 'r');
ax = gca; 
set(ax, 'Xtick', targets);
axis([min(targets) max(targets) 400 800]);
xlabel('Target location (deg)'); ylabel('Mean VRT(ms)');
title('Effect of target location on response time');

%% Save all data
save(matfilename)