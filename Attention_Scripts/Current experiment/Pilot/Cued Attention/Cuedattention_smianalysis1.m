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
session1=uigetfile('Cued_attention1*.mat');
load (session1);

%% Making matrix

targetss = Matrix1(:,1);
Accuracy = Matrix1(:,2);
VRT  = Matrix1(:,3);
RT = Matrix1(:,4);
targloc = Matrix1(:,5);

VRTmax = 1500;
VRTmin = 350;
RTmax = 2500;
RTmin = 150;
eyemax = 1;

matfilename = sprintf('%s_CuedAttention1', ParticipantID);
save(matfilename)

%% Get eye data files
M1 = [];
M1 = Atten_readEyeData('iViewXSDK_Matlab_Data_1CuedAttention Samples.txt');
%[F, S, B] = Atten_readEventData('iViewXSDK_Matlab_Data_AttentionLVFcue Events.txt');

%Eye data matrix
Mat = M1.matrix;

audio = 1; %is VRT used?

%% Get raw data

% Inidividual samples from Mat matrix
nrsamples = length(Mat(:,1)); %number of samples
timestamp = Mat(:,1); %timing
lx = Mat(:,3); 
ly = Mat(:,4);
rx = Mat(:,5);
ry = Mat(:,6);
fixon = Mat(:,7);
cueon = Mat(:,8);
targeton = Mat(:,9);
trialno = Mat(:,10);
trialcounter = Mat(:,11);

%% Alter variables
% Changing timestamp to ms (recorded every 8ms) and eye amplitude to visual
% deg, not pixels
% time interval
frequencysample = 120; %sample frequency of SMI in Hz, (0.008s)
timeint=200; % time before a target for sampling eye position, in ms
timenr=1000/frequencysample; %ms
pretrial = frequencysample*timeint/1000; 

% number of degrees per pixel
vadx=(atan(1/sd)*180/pi)/vadxcm; % vad in deg visual angle for 1 pixel
vady=(atan(1/sd)*180/pi)/vadycm; 
halfpixx = DisplayXSize/2;
halfpixy = DisplayYSize/2;

% formula for pixels to deg
% size_deg = size_pix * deg_pix

% Samples matrix
for i = 1:length(Mat(:,1))
    times(i) = (i*timenr)/1000; %timestamp in s
    lx_deg(i) = (lx(i)-halfpixx)*vadx;
    ly_deg(i) = (ly(i)-halfpixy)*vadx;
    rx_deg(i) = (rx(i)-halfpixx)*vadx;
    ry_deg(i) = (ry(i)-halfpixy)*vadx;
end

%% Make own Matrix of relevant info
% Include VRT, RT and accuracy data
TotMat = [];
TotMat(:,1) = times;
TotMat(:,2) = fixon;
TotMat(:,3) = cueon;
TotMat(:,4) = targeton;
TotMat(:,5) = lx_deg;
TotMat(:,6) = ly_deg;
TotMat(:,7) = rx_deg;
TotMat(:,8) = ry_deg;
TotMat(:,9) = trialno;
TotMat(:,10) = trialcounter;

%% Plotting data
% To check for drift

% Left eye X
figure(1)
plot(times, lx_deg, 'b');
% hold on;
% scatter(times, targeton, '*r')
axis([0 TotMat(end,1) min(TotMat(:,5)) max(TotMat(:,5))]);
xlabel('Time in s');
ylabel('X amplitude of left eye (degrees)');
title('Movement of the left eye');

% Right eye X
figure(2)
plot(times, rx_deg, 'b');
% hold on;
% scatter(times, targeton, '*r')
axis([0 TotMat(end,1) min(TotMat(:,7)) max(TotMat(:,7))]);
xlabel('Time in s');
ylabel('X amplitude of right eye (degrees)');
title('Movement of the right eye');

%% Starting analysis from fixation onset

I= find(TotMat(:,10));%finds the nonzero elements, when fixation was presented
for i=1:sum(TotMat(:,10))
    MLX(i)=mean(lx_deg(I(i)-pretrial:I(i)));
    ML(i)=sqrt(MLX(i)^2);
    MRX(i)=mean(rx_deg(I(i)-pretrial:I(i)));
    MR(i)=sqrt(MRX(i)^2);
end

%% Convert to smaller, easier matrix
Matrix1(:,1)= targetss;
Matrix1(:,2)= Accuracy;
Matrix1(:,3)= VRT;
Matrix1(:,4)= RT;
Matrix1(:,5)= targloc;
Matrix1 (:,6)= ML;
Matrix1(:,7) = MR;

%% Filter trials

if audio
    Matrix1(find(Matrix1(:,3)>=VRTmax),3)=NaN;
    Matrix1(find(Matrix1(:,3)<=VRTmin),3)=NaN;
end
Matrix1(find(Matrix1(:,4)>=RTmax),4)=NaN;
Matrix1(find(Matrix1(:,4)<=RTmin),4)=NaN;
Matrix1(find(Matrix1(:,6)>=eyemax),6)=NaN;
Matrix1(find(Matrix1(:,7)>=eyemax),7)=NaN;% What is a suitable degree to filter out of this trial?

Valid1 =(length(find(Matrix1(:,2)>=0.001&Matrix1(:,3)>=0.001&Matrix1(:,6)>=0.001&Matrix1(:,7)>=0.001))/nrtrials)*100; %percentage valid trials
AccurateAll1 =(length(find(Matrix1(:,3)>=0.001))/nrtrials)*100; %percentage invalid trials
Valid_eye1 = (length(find(Matrix1(:,6)>=0.001&Matrix1(:,7)>=0.001))/nrtrials)*100; %valid trials for eye movements only

%% Matrix with valid values (and eyemax < 1)

Matrix1=Matrix1(find(Matrix1(:,3)>=0.001&Matrix1(:,6)>=0.001&Matrix1(:,7)>=0.001),:);

%% Isolate target locations
% Using 'targ loc' to find accuracy and RT values for each target location
% May need to 'comment' some of these depending on location of the xcue

Ltarg10 = Matrix1(find(Matrix1(:,5)==1),:); %left target locations from left -> right 
Ltarg9 = Matrix1(find(Matrix1(:,5)==2),:);
Ltarg8 = Matrix1(find(Matrix1(:,5)==3),:);
Ltarg7 = Matrix1(find(Matrix1(:,5)==4),:);
Ltarg6 = Matrix1(find(Matrix1(:,5)==5),:);
Ltarg5 = Matrix1(find(Matrix1(:,5)==6),:);
Ltarg4 = Matrix1(find(Matrix1(:,5)==7),:);
Ltarg3 = Matrix1(find(Matrix1(:,5)==8),:);
Ltarg2 = Matrix1(find(Matrix1(:,5)==9),:);
Ltarg1 = Matrix1(find(Matrix1(:,5)==10),:);
targ0 = Matrix1(find(Matrix1(:,5)==11),:); %target at location 0
Rtarg1 = Matrix1(find(Matrix1(:,5)==12),:); %right target locations from left -> right
Rtarg2 = Matrix1(find(Matrix1(:,5)==13),:);
Rtarg3 = Matrix1(find(Matrix1(:,5)==14),:);
Rtarg4 = Matrix1(find(Matrix1(:,5)==15),:);
Rtarg5 = Matrix1(find(Matrix1(:,5)==16),:);
Rtarg6 = Matrix1(find(Matrix1(:,5)==17),:);
Rtarg7 = Matrix1(find(Matrix1(:,5)==18),:);
Rtarg8 = Matrix1(find(Matrix1(:,5)==19),:);
Rtarg9 = Matrix1(find(Matrix1(:,5)==20),:);
Rtarg10 = Matrix1(find(Matrix1(:,5)==21),:);

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

Av_acc1= [Macc_Ltarg10 Macc_Ltarg9 Macc_Ltarg8 Macc_Ltarg7 Macc_Ltarg6 Macc_Ltarg5 Macc_Ltarg4 Macc_Ltarg3 Macc_Ltarg2 Macc_Ltarg1 Macc_targ0 Macc_Rtarg1 Macc_Rtarg2 Macc_Rtarg3 Macc_Rtarg4 Macc_Rtarg5 Macc_Rtarg6 Macc_Rtarg7 Macc_Rtarg8 Macc_Rtarg9 Macc_Rtarg10];

%% Creating new matrix excluding inaccurate trials
Matrix1 = Matrix1(find(Matrix1(:,2)>=0.001),:);

%% Isolate target locations (again, including accuracy filter)
% Using 'targ loc' to find accuracy and RT values for each target location
% May need to 'comment' some of these depending on location of the xcue

Ltarg10 = Matrix1(find(Matrix1(:,5)==1),:); %left target locations from left -> right 
Ltarg9 = Matrix1(find(Matrix1(:,5)==2),:);
Ltarg8 = Matrix1(find(Matrix1(:,5)==3),:);
Ltarg7 = Matrix1(find(Matrix1(:,5)==4),:);
Ltarg6 = Matrix1(find(Matrix1(:,5)==5),:);
Ltarg5 = Matrix1(find(Matrix1(:,5)==6),:);
Ltarg4 = Matrix1(find(Matrix1(:,5)==7),:);
Ltarg3 = Matrix1(find(Matrix1(:,5)==8),:);
Ltarg2 = Matrix1(find(Matrix1(:,5)==9),:);
Ltarg1 = Matrix1(find(Matrix1(:,5)==10),:);
targ0 = Matrix1(find(Matrix1(:,5)==11),:); %target at location 0
Rtarg1 = Matrix1(find(Matrix1(:,5)==12),:); %right target locations from left -> right
Rtarg2 = Matrix1(find(Matrix1(:,5)==13),:);
Rtarg3 = Matrix1(find(Matrix1(:,5)==14),:);
Rtarg4 = Matrix1(find(Matrix1(:,5)==15),:);
Rtarg5 = Matrix1(find(Matrix1(:,5)==16),:);
Rtarg6 = Matrix1(find(Matrix1(:,5)==17),:);
Rtarg7 = Matrix1(find(Matrix1(:,5)==18),:);
Rtarg8 = Matrix1(find(Matrix1(:,5)==19),:);
Rtarg9 = Matrix1(find(Matrix1(:,5)==20),:);
Rtarg10 = Matrix1(find(Matrix1(:,5)==21),:);

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

Av_VRT1 = [MVRT_Ltarg10 MVRT_Ltarg9 MVRT_Ltarg8 MVRT_Ltarg7 MVRT_Ltarg6 MVRT_Ltarg5 MVRT_Ltarg4 MVRT_Ltarg3 MVRT_Ltarg2 MVRT_Ltarg1 MVRT_targ0 MVRT_Rtarg1 MVRT_Rtarg2 MVRT_Rtarg3 MVRT_Rtarg4 MVRT_Rtarg5 MVRT_Rtarg6 MVRT_Rtarg7 MVRT_Rtarg8 MVRT_Rtarg9 MVRT_Rtarg10];

%% SAVE
save(matfilename)