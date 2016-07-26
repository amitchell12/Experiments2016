%load calibration file
clear all
close all
% !edf2asc mainr mainr -sp -r
% [EH, EJ, EX]=T1brede_read_edf('mainr.asc');
% save 'eyedata.mat'
filename=uigetfile('eyedata*.mat', 'pick up eyepos matrices file');
load (filename);

filename=uigetfile('Cali*.mat', 'pick up calib file');
load (filename);

filename=uigetfile('AttShift*.mat', 'pick up calib file');
load (filename);

%detrend

 X= polyval(CAL1rx,EH.matrix(:, 2));
 Y= polyval(CAL1ry,EH.matrix(:, 3));
 figure
 plot(X, 'r'); %this is x
 hold on
 plot(Y, 'b'); %this is y
 hold off
 XX= detrend(X);
 YY= detrend(Y);
 figure
 plot(XX, 'r'); %this is x
 hold on
 plot(YY ,'b'); %this is y
 hold off
 
 saccx=EH.matrix(find(EH.matrix(:,5)==1),2);
 saccx=polyval(CAL1rx,saccx);
 saccy=EH.matrix(find(EH.matrix(:,5)==1),3);
 saccy=polyval(CAL1ry,saccy);
 Saccades(:,1)=EH.matrix(find(EH.matrix(:,5)==1),1);
 Saccades(:,2)=saccx;
 Saccades(:,3)=saccy;
 startsacc=zeros(length(find(diff(Saccades(:,1))~=4))+1,1);
 endsacc=zeros(length(find(diff(Saccades(:,1))~=4))+1,1);
 startsacc(1)=1;
 startsacc(2:end)=find(diff(Saccades(:,1))~=4);
 endsacc(1:length(endsacc)-1)=startsacc(2:end)-1;
 endsacc(end)=length(Saccades);
 
 for i=1:length(startsacc)
    NewSacc(i,1)=Saccades(startsacc(i),2);
    NewSacc(i,2)=Saccades(endsacc(i),2);
 end
 SaccAmp=NewSacc(:,1)-NewSacc(:,2);
 SaccAmp=SaccAmp(find(SaccAmp<1&SaccAmp>-1))
 
 SaccLeftAmp=mean(SaccAmp(find(SaccAmp>0)))
 SaccRightAmp=mean(SaccAmp(find(SaccAmp<0)))
 SaccLeftFreq=length(find(SaccAmp>0))
 SaccRightFreq=length(find(SaccAmp<0))
 
 Excel=[SaccLeftAmp SaccRightAmp; SaccLeftFreq SaccRightFreq]
%calculate mean eye position t=.. ms before target presentation and
%construct an array
timeint=200; %ms
timenr=250*timeint/1000;

I= find(EH.matrix(:,9));%finds the nonzero elements, where a target was presented
for i=1:sum(EH.matrix(:,9)) % how many targets
    MX(i)=mean(XX(I(i)-timenr:I(i)));
    M(i)=sqrt(MX(i)^2);
end
  
M(328)=0;
Matrix(:,1)= VRT;
Matrix(:,2)= TargetPosition;
Matrix(:,3)= CuePos;
Matrix(:,4)= Accuracy;
Matrix (:,5)= M';

MatrixAll=Matrix;

save MatrixAll MatrixAll;
% Sort out trials
Matrix(find(Matrix(:,1)>=1500),1)=NaN;
Matrix(find(Matrix(:,1)<=150),1)=NaN;
Matrix(find(Matrix(:,5)>=15),5)=NaN;



Valid=(length(find(Matrix(:,1)>=0.001&Matrix(:,5)>=0.001))/nrtrials)*100
AccurateAll=(length(find(Matrix(:,4)>=0.001))/nrtrials)*100

% Matrix with correct and valid values

Matrix=Matrix(find(Matrix(:,1)>=0.001&Matrix(:,5)>=0.001&Matrix(:,4)>=0.001),:);

%% Sort and mean values for each cue
for i=1:length(Matrix);
    if Matrix(i,3)==1
        Cue11Left(i,1:2)=Matrix(i,1:2);
    end
    if Matrix(i,3)==2
        Cue1Left(i,1:2)=Matrix(i,1:2);
    end
     if Matrix(i,3)==3
        Cue1Right(i,1:2)=Matrix(i,1:2);
    end
    if Matrix(i,3)==4
        Cue11Right(i,1:2)=Matrix(i,1:2);
    end
    if Matrix(i,3)==5
        CueCenter(i,1:2)=Matrix(i,1:2);
    end
    
end

Cue11Left=Cue11Left(find(Cue11Left(:,2)~=0),:);
Cue11Right=Cue11Right(find(Cue11Right(:,2)~=0),:);
Cue1Left=Cue1Left(find(Cue1Left(:,2)~=0),:);
Cue1Right=Cue1Right(find(Cue1Right(:,2)~=0),:);
CueCenter=CueCenter(find(CueCenter(:,2)~=0),:);

for ii=1:7
MeanCue11Left(ii)=nanmean(Cue11Left(find(Cue11Left(:,2)==ii)),1);
end
% MeanCue11Left(8)=nanmean(Cue11Left(find(Cue11Left(:,2)==11)),1);
% MeanCue11Left(9)=nanmean(Cue11Left(find(Cue11Left(:,2)==18)),1);
% MeanCue11Left(10)=nanmean(Cue11Left(find(Cue11Left(:,2)==25)),1);

for ii=8:14
MeanCue1Left(ii)=nanmean(Cue1Left(find(Cue1Left(:,2)==ii)),1);
end
MeanCue1Left=MeanCue1Left(8:end);
% MeanCue1Left(8)=nanmean(Cue1Left(find(Cue1Left(:,2)==4)),1);
% MeanCue1Left(9)=nanmean(Cue1Left(find(Cue1Left(:,2)==25)),1);

for ii=15:21
MeanCue1Right(ii)=nanmean(Cue1Right(find(Cue1Right(:,2)==ii)),1);
end
MeanCue1Right=MeanCue1Right(15:end);
% MeanCue1Right(8)=nanmean(Cue1Right(find(Cue1Right(:,2)==4)),1);
% MeanCue1Right(9)=nanmean(Cue1Right(find(Cue1Right(:,2)==25)),1);

for ii=22:28
MeanCue11Right(ii)=nanmean(Cue11Right(find(Cue11Right(:,2)==ii)),1);
end
MeanCue11Right=MeanCue11Right(22:end);
% MeanCue11Right(8)=nanmean(Cue11Right(find(Cue11Right(:,2)==4)),1);
% MeanCue11Right(9)=nanmean(Cue11Right(find(Cue11Right(:,2)==11)),1);
% MeanCue11Right(10)=nanmean(Cue11Right(find(Cue11Right(:,2)==25)),1);

for ii=1:28
MeanCueCenter(ii)=nanmean(CueCenter(find(CueCenter(:,2)==ii)),1);
end

MeanCueCenter=MeanCueCenter(find(MeanCueCenter>=0.001));


% substract ControlData from CuedData:
Cue11Left=MeanCue11Left-MeanCueCenter(1:7);
Cue1Left=MeanCue1Left-MeanCueCenter(8:14);
Cue1Right=MeanCue1Right-MeanCueCenter(10:16);
Cue11Right=MeanCue11Right-MeanCueCenter(17:end);





%% plot results
figure(1)
plot (Position11Left(1:7), MeanCue11Left(1:7),'*:k')
title('Cue at -11 deg')
xlabel('Target Position')
ylabel('Reaction Time')
axis([-15 15 0 1000])
%hold on
%plot (Position11Left(8:end), MeanCue11Left(8:end),'*b')
%plot (Position11Left(9), MeanCue11Left(9),'*b')

figure (2)
plot (Position1Left(1:7), MeanCue1Left(1:7),'*:k')
title('Cue at -1 deg')
xlabel('Target Position')
ylabel('Reaction Time')
axis([-15 15 0 1000])
%hold on
%plot (Position1Left(8:end), MeanCue1Left(8:end),'*b')
%plot (Position1Left(8), MeanCue1Left(8),'*b')

figure (3)
plot (Position1Right(1:7), MeanCue1Right(1:7),'*:k')
title('Cue at 1 deg')
xlabel('Target Position')
ylabel('Reaction Time')
axis([-15 15 0 1000])
%hold on
%plot (Position1Right(8:end), MeanCue1Right(8:end),'*b')


figure (4)
plot (Position11Right(1:7), MeanCue11Right(1:7),'*:k')
title('Cue at 11 deg')
xlabel('Target Position')
ylabel('Reaction Time')
axis([-15 15 0 1000])
%hold on
%plot (Position11Right(8:end), MeanCue11Right(8:end),'*b')
%plot (Position11Right(9:end), MeanCue11Right(9:end),'*b')

figure (5)
plot (PositionControl, MeanCueCenter,'*:k')
title('Cue at center')
xlabel('Target Position')
ylabel('Reaction Time')
axis([-15 15 0 1000])

figure(11)
plot (Position11Left(1:7), Cue11Left(1:7),'*:k')
title('Cue at -11 deg - corrected')
xlabel('Target Position')
ylabel('Reaction Time')
axis([-15 15 -500 250])
%hold on
%plot (Position11Left(8:end), MeanCue11Left(8:end),'*b')
%plot (Position11Left(9), MeanCue11Left(9),'*b')

figure (12)
plot (Position1Left(1:7), Cue1Left(1:7),'*:k')
title('Cue at -1 deg - corrected')
xlabel('Target Position')
ylabel('Reaction Time')
axis([-15 15 -500 250])
%hold on
%plot (Position1Left(8:end), MeanCue1Left(8:end),'*b')
%plot (Position1Left(8), MeanCue1Left(8),'*b')

figure (13)
plot (Position1Right(1:7), Cue1Right(1:7),'*:k')
title('Cue at 1 deg - corrected')
xlabel('Target Position')
ylabel('Reaction Time')
axis([-15 15 -500 250])
%hold on
%plot (Position1Right(8:end), MeanCue1Right(8:end),'*b')


figure (14)
plot (Position11Right(1:7), Cue11Right(1:7),'*:k')
title('Cue at 11 deg - corrected')
xlabel('Target Position')
ylabel('Reaction Time')
axis([-15 15 -500 250])


