%% ANALYSIS SCRIPT 
%% FIRST READ IN THE FILES 
% clear all; 
% close all; 
clear Mat Fix Sac Blk sx st ds de d Mat matrixSaccadeTrace SaccadeTable SaccadeData ProcessedDataTMS FinalDataTMS LeftSaccadeArrayTMS RightSaccadeArrayTMS; 
% filenameMatlabSession = ['FEF' num2str(stimulationLocation)];
% load(filenameMatlabSession); 
filenameEyeData = [participantInitials 'TMS' num2str(stimulationLocation) ' Samples.txt']; 
filenameEventData = [participantInitials 'TMS' num2str(stimulationLocation) ' Events.txt'];
M = readEyeData(filenameEyeData);
[F, S, B] = readEventData(filenameEventData);
trialCounter = 1; 
Mat = M.matrix; %Eye Data Matrix
Fix = F.matrix; %Fixation Data Matrix
Sac = S.matrix; %Saccade Data Matrix
Blk = B.matrix; %Blink Data Matrix

for i = 1:length(Sac(:, 1))
    sx = Sac(i, 1); %start of saccade
    sy = Sac(i, 2); %end of saccade
    ds = Sac(i, 3); %X position at start 
    de = Sac(i, 5); %X position at end 
    d = de-ds; %Distance moved (pixels) 

        for j = 1:length(Mat(:, 1))
            if Mat(j, 1) >= sx && Mat(j, 1) <= sy %look for the samples between saccade timestamps
                Mat(j, 12) = 1; %put a marker that saccade is happening
                Mat(j, 13) = d; %put a marker for the amplitude of saccade
            end 
        end 
end 

noSamplesTrace = 100; 
matrixSaccadeTrace = zeros(length(Data), noSamplesTrace); 

saccadeTableCount = 1; 
j = 0; 

for i = 1:length(Mat)
    if Mat(i, 11) == 1 %when the arrow comes on
        trialNumber = Mat(i, 10); %note the trial no.
        j = j+1;
        matrixSaccadeTrace(j, :) = Mat(i:i+noSamplesTrace-1, 3)';
        SaccadeTable(saccadeTableCount, 1) = trialNumber; %saccadeTable column 1: trial no.
        SaccadeTable(saccadeTableCount, 2) = Mat(i, 1); %saccadeTable column 2: timestamp of arrow onset
    end
    if Mat(i, 9) == 1 && Mat(i, 12) == 1 %Mat(:, 9) is saccadeWait period / Mat(:, 12) is marker for saccade happening
        SaccadeTable(saccadeTableCount, 3) = Mat(i, 1); %saccadeTable column 3: timestamp of
        SaccadeTable(saccadeTableCount, 4) = Mat(i, 13); %amplitude of saccade (pixels)
        saccadeTableCount = saccadeTableCount+1;
        continue;
    end
end

% j = 0; 
% for i = 1:length(Mat)
%     if Mat(i, 11) == 1
%         j = j+1; 
%         matrixSaccadeTrace(j, :) = Mat(i:i+noSamplesTrace-1, 3)'; 
%     end 
% end 
        
SaccadeData(:, 1) = SaccadeTable(find(SaccadeTable(:,1)~=0),1); %Trial Number
SaccadeData(:, 2) = SaccadeTable(find(SaccadeTable(:,1)~=0),2); %Timestamp start of arrow cue
SaccadeData(:, 3) = SaccadeTable(find(SaccadeTable(:,1)~=0),3); %Timestamp start of first saccade after arrow cue 
SaccadeData(:, 4) = SaccadeTable(find(SaccadeTable(:,1)~=0),4)/vadx; %Size in degrees of saccade (negative = left, positive = right) 
SaccadeData(:, 5) = (SaccadeData(:, 3)/1000) - (SaccadeData(:, 2)/1000); %Latency (time between start of arrow and start of saccade)
for i = 1:length(SaccadeData(:, 1)) 
    indexTrial = SaccadeData(i, 1);
    SaccadeData(i, 7) = trialMatrix(indexTrial, 1); 
    if SaccadeData(i, 4) < 0 %i.e. if the saccade distance is negative
        SaccadeData(i, 6) = 1; %mark direction of saccade made to check (the saccade was to the left)
    else 
        SaccadeData(i, 6) = 2; %saccade was to the right
    end
end 

ProcessedDataTMS = SaccadeData; 
for i = 1:length(ProcessedDataTMS(:, 1))
    if ProcessedDataTMS(i, 6) == ProcessedDataTMS(i, 7) && ProcessedDataTMS(i, 5) > (mean(ProcessedDataTMS(:, 5)))-2*std(ProcessedDataTMS(:, 5)) && ProcessedDataTMS(i, 5) < (mean(ProcessedDataTMS(:, 5)))+2*std(ProcessedDataTMS(:, 5)) %if the direction of arrow and first saccade match
        ProcessedDataTMS(i, 8) = 1; %include it
    else 
        ProcessedDataTMS(i, 8) = NaN; %discard it
    end 
end 

FinalDataTMS = ProcessedDataTMS(find(ProcessedDataTMS(:, 8) == 1), :); 
LeftSaccadeArrayTMS = FinalDataTMS(find(FinalDataTMS(:, 7) == 1), :); 
RightSaccadeArrayTMS = FinalDataTMS(find(FinalDataTMS(:, 7) == 2), :);

TMSTableSMI(SMICount, 1) = SMICount; 
TMSTableSMI(SMICount, 2) = mean(LeftSaccadeArrayTMS(:, 5)); 
TMSTableSMI(SMICount, 3) = std(LeftSaccadeArrayTMS(:, 5)); 
TMSTableSMI(SMICount, 4) = length(LeftSaccadeArrayTMS(:, 1))*10;
TMSTableSMI(SMICount, 5) = mean(RightSaccadeArrayTMS(:, 5)); 
TMSTableSMI(SMICount, 6) = std(RightSaccadeArrayTMS(:, 5)); 
TMSTableSMI(SMICount, 7) = length(RightSaccadeArrayTMS(:, 1))*10;
[h,p,ci] = ttest2(abs(LeftSaccadeArrayTMS(:, 5)), abs(RightSaccadeArrayTMS(:, 5)));
TMSTableSMI(SMICount, 8) = p;


%% TASK OUTPUT

% disp('*****TASK SUMMARY*****'); 
% disp(['Number of Correctly-Executed Left Saccades = ' num2str(length(LeftSaccadeArray(:, 1))) '(' num2str((length(LeftSaccadeArray(:, 1))/(length(Data)/2))*100) '%)']);
% disp(['Number of Correctly-Executed Right Saccades = ' num2str(length(RightSaccadeArray(:, 1))) '(' num2str((length(RightSaccadeArray(:, 1))/(length(Data)/2))*100) '%)']);
% disp(' '); 
% disp(['Mean Left Saccade Latency = ' num2str(abs(mean(LeftSaccadeArray(:, 5)))) 'ms (SD = ' num2str(abs(std(LeftSaccadeArray(:, 5)))) ')']); 
% disp(['Mean Right Saccade Latency = ' num2str(abs(mean(RightSaccadeArray(:, 5)))) 'ms (SD = ' num2str(abs(std(RightSaccadeArray(:, 5)))) ')']);  
% 
% [h,p,ci] = ttest2(abs(LeftSaccadeArray(:, 5)), abs(RightSaccadeArray(:, 5)));
% 
%     if h == 0 
%          disp(['Latencies not significantly different, p = ' num2str(p)]); 
%     else 
%          disp(['Latencies significantly different, p = ' num2str(p)]); 
%     end 
%      
% disp(' '); 
% disp(['Mean Left Saccade Amplitude = ' num2str(abs(mean(LeftSaccadeArray(:, 4)))) ' Degrees (SD = ' num2str(abs(std(LeftSaccadeArray(:, 4)))) ')']); 
% disp(['Mean Right Saccade Amplitude = ' num2str(abs(mean(RightSaccadeArray(:, 4)))) ' Degrees (SD = ' num2str(abs(std(RightSaccadeArray(:, 4)))) ')']); 
% 
% [h2,p2,ci2] = ttest2(abs(LeftSaccadeArray(:, 4)), abs(RightSaccadeArray(:, 4)));
% 
%     if h2 == 0
%          disp(['Amplitude of saccades not significantly different, p = ' num2str(p2)]); 
%     else 
%          disp(['Amplitude of saccades significantly different, p = ' num2str(p2)]);
%     end 
%      
% disp(' '); 

%% SANITY CHECKS & GRAPHS 

% %Plot the amplitude of saccades 
% figure(1)
% hold on
% scatter(FinalDataTMS(:, 1), FinalDataTMS(:, 4));
% refline([0,0]);
% refline([0,-10]);
% refline([0,10]);
% title('Amplitude of Saccades Made Trial-By-Trial');
% xlabel('Trial Number');
% ylabel('Amplitude of Saccade Made (Degrees)');
% ylim([min(FinalDataTMS(:, 4))+0.5, max(FinalDataTMS(:, 4))+0.5]);

% figure(2) 
% scatter(1:length(Data), (fixationStop-fixationStart)*1000);
% title('SANITY CHECK: Fixation Period');
% xlabel('Trial Number');
% ylabel(['Time fixation screen presented (ms); expecting ' num2str(fixationTime*1000) 'ms']);
% ylim([0, 3000]); 

sampleRate = 120;
sampleTime = 1/sampleRate;
saccadeVelocityCriterion = 50; %degrees per second
matrixSaccadeTraceDegrees = (matrixSaccadeTrace-(DisplayXSize/2))/vadx; %creates a matrix with position in degrees for X samples 
velocityMatrixSaccadeTraceDegrees = diff(matrixSaccadeTraceDegrees'); %flip matrix to take the difference in position between samples to work out velocity 
velocityMatrixSaccadeTraceDegrees = velocityMatrixSaccadeTraceDegrees'; %flip the matrix back 
velocityMatrixSaccadeTraceDegrees = [zeros(length(Data), 1), velocityMatrixSaccadeTraceDegrees*sampleRate]; 
samplesMillisecondPlot = (1:noSamplesTrace)*(sampleTime*(1000)); 

figure(runTimesSMI) 
hold on; 
plot(samplesMillisecondPlot, matrixSaccadeTraceDegrees); 
xlim([0, max(samplesMillisecondPlot)]); 
ylim([-20,20]); 
xlabel('Milliseconds After Arrow Onset (ms)'); 
ylabel('Horizontal Eye Position From Fixation (Degrees)'); 

% SaccadeDetection (50/s: Ro et al.) 

noVelocitySamples = 3; 
for j = 1:length(Data); 
    i = 1; 
    if Data(j, 1) == 1
        saccadeVelocityCriterion = -50;
    else 
        saccadeVelocityCriterion = 50;
    end 
    foundSaccade = false; 
    while foundSaccade == false && i < 98 
       currentSample = velocityMatrixSaccadeTraceDegrees(j, i); 
       if Data(j, 1) == 1 
       if abs(currentSample) > saccadeVelocityCriterion
           if mean(abs(velocityMatrixSaccadeTraceDegrees(j, i:(i+noVelocitySamples-1)))) > saccadeVelocityCriterion
               if  isequal(sum(velocityMatrixSaccadeTraceDegrees(j, i:(i+noVelocitySamples-1))>0), noVelocitySamples) == 1 %| isequal(sum(velocityMatrixSaccadeTraceDegrees(j, i:(i+noVelocitySamples-1))<0), noVelocitySamples) == 1
               SaccadeOnsetRo(j) = i-1; %CHECK IF i or i-1 !!!!!!!!!
               foundSaccade = true; 
               elseif isequal(sum(velocityMatrixSaccadeTraceDegrees(j, i:(i+noVelocitySamples-1))<0), noVelocitySamples) == 1
               SaccadeOnsetRo(j) = i-1; 
               foundSaccade = true; 
               else 
                   foundSaccade = false; 
                   i = i+1; 
               end
           else 
               foundSaccade = false; 
               i = i+1;
           end 
       else 
           i = i+1; 
       end 
       else 
           if currentSample > saccadeVelocityCriterion
               if mean(velocityMatrixSaccadeTraceDegrees(j, i:(i+noVelocitySamples-1))) > saccadeVelocityCriterion
                   SaccadeOnsetRo(j) = i; 
                   foundSaccade = true; 
               else 
                   foundSaccade = false; 
               end 
               i = i+1; 
           else 
               i = i+1; 
           end 
       end 
    end 
end 
% 
% for i = 1:length(SaccadeOnsetRo)
%     if SaccadeOnsetRo(i) == 0
%         saccadeLatencyRoMethod(i, :) = [NaN, NaN];
%     else 
%         saccadeLatencyRoMethod(i, :) = [samplesMillisecondPlot(SaccadeOnsetRo(i)), matrixSaccadeTraceDegrees(i, SaccadeOnsetRo(i))]; 
%     end 
% end 
% scatter(saccadeLatencyRoMethod(:, 1), saccadeLatencyRoMethod(:, 2), 'bx');
% 
% % for i = 1:length(SaccadeData) 
% %     saccadeLatencySMI(i, :) = [SaccadeData(i, 5), matrixSaccadeTraceDegrees(SaccadeData(i, 1))]; 
% % end 
% 
% saccadeSMI = NaN(length(Data), 7); 
% saccadeSMI(:, 1) = 1:length(Data); 
% for i = 1:length(saccadeSMI) 
%     for j = 1:length(SaccadeData)
%         if saccadeSMI(i, 1) == SaccadeData(j, 1) 
%             saccadeSMI(i, :) = SaccadeData(j, :); 
%         end
%     end 
% end 
% for i = 1:length(saccadeSMI) 
%     saccadeLatencySMI(i, :) = [saccadeSMI(i, 5), matrixSaccadeTraceDegrees(saccadeSMI(i, 1))]; 
% end 
% 
% % SaccadeDataCount = 1; 
% % for i = 1:length(Data)
% %     if SaccadeData(i, 1) == i 
% %     saccadeLatencySMI(i, :) = [SaccadeData(i, 5), matrixSaccadeTraceDegrees(SaccadeData(i, 1))]; 
% %     SaccadeDataCount = SaccadeDataCount+1; 
% %     else 
% %     saccadeLatencySMI(i, :) = zeros; 
% %     end 
% % end 
% % 
% % figure(4); 
% % hold on; 
% % scatter(1:length(Data), saccadeLatencyRoMethod(:, 1), 'bx');
% % scatter(1:length(Data), saccadeLatencySMI(:, 1), 'gx'); 
% % correlationMethods = corrcoef(saccadeLatencyRoMethod(:, 1), saccadeLatencySMI(:, 1));
% % CORRELATIONTABLE = [saccadeLatencyRoMethod(:, 1), saccadeLatencySMI(:, 1)]; 
% % 
% xlabel('Trial Number'); 
% ylabel('Saccade Latency (ms)'); 
% legend('Ro Method', 'SMI Method'); 
% 
% CompareArrowTimeStamps = [Mat(find(Mat(:, 11) == 1), 1), arrowStart*1000000]; 
% DifferenceArrowTimeStamps = CompareArrowTimeStamps(:, 1) - CompareArrowTimeStamps(:, 2);  
% ArrowSanity = [mean(DifferenceArrowTimeStamps), std(DifferenceArrowTimeStamps)]; 
% 
% % figure(3)
% % hold on
% scatter(FinalData(:, 1), TMSStop-TMSStart);
% title('SANITY CHECK: Timing of TMS Pulse');
% xlabel('Trial Number');
% ylabel('Time taken to complete pulse (ms)');
