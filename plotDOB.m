function[meanMARSAngle,meanMARSVelocity,meanMARSAcceleration,stdMARSAngle,crashFrequency,meanMagnitudeMARSAngle,stdRate, meanRateDistsV, meanDrifts, stdDists, driftPercent, meanJoyMag,stdJoyMag,intermitJoy,destabJoystick,anticipJoystick,meanVelJoystick,meanVelMovements,destabJoystickMoves,anticipJoystickMoves, MeanAnticipatoryPhaseAngle, startMoveMARSPosition]= plotDOB(summaryData, strParticipant, outDir, binCenters, instructionType, saveFile, doDistributionEstimate,human)

global protocol protocolIndices dataIndices;

numDOBs = size(summaryData, 1);
dobIndex=1;
dob = summaryData{dobIndex}.DOBRoll;
numTrials = size(summaryData{dobIndex}.Trials, 2);


%%UPLOADS DATA VALUES FROM EXCEL SHEETS AND ORGANIZES INTO MATRICES%% 
for trialIndex = 1 : numTrials
    td = summaryData{dobIndex}.Trials{trialIndex};
    trialDataAngles = td(:, dataIndices.indexCurrentPosRoll); %MARS Angle
    trialJoystickx = td(:, dataIndices.indexJoystickX);
    trialJoysticky = td(:, dataIndices.indexJoystickY);
    trialph = td(:, dataIndices.indexTrialPhase); %Phase value: 4= crash, 3=balancing, 1=automatic movement
    trialJoyBlanked = td(:, dataIndices.indexJoystickBlanked); %?
    trialDataJoystick = summaryData{dobIndex}.JoyBtnDownAngles{trialIndex}; %?
    trialtimepoop=td(:,dataIndices.indexTime); %Time-step
    velocitypoop=td(:,dataIndices.indexCurrentVelRoll); %MARS Velocity    

%
trialDataAnglesALL=trialDataAngles;
trialtimepoopALL=trialtimepoop;
velocitypoopALL=velocitypoop;

%%REMOVES CRASH DATA POINTS%%
ff=find(trialph~=3);%Finds all indices that are not equal to 3 (balance time)
trialDataAngles(ff)=[];%Removes angles that are not during balance time (trialph==3)
trialph(ff)=[]; %Removes phases that are not during balance time (trialph==3)
trialJoystickx(ff) = []; %Removes joystick x position that are not during balance time (trialph==3)
trialJoysticky(ff) = []; %Removes joystick y position that are not during balance time (trialph==3)
trialtimepoop(ff)=[]; %Removes time data that are not during balance time (trialph==3)
velocitypoop(ff)=[]; %Removes velocity data that are not during balance time (trialph==3)
%

triallength(trialIndex)=length(trialDataAngles);%Length of the trial

%%FILTERS MEASURED ANGLES WITH BUTTERWORTH FILTER%%
rawData=[];   deltaT=[];   samplingFreq=[];  b=[];  a=[];  filteredData=[];  deltaAngle=[];
deltaTime=[]; calculatedVelocities=[];  deltaVelocities=[]; accelerationDataReported=[];

rawDataALL=trialDataAnglesALL;
deltaTALL=trialtimepoopALL(end)-trialtimepoopALL(1);

butterworthCutoffFrequency = 5;
rawData=trialDataAngles;
deltaT=trialtimepoop(end)-trialtimepoop(1);

samplingFreqALL=size(trialDataAnglesALL,1)/deltaTALL;
[c,d]=butter(5, butterworthCutoffFrequency*2/samplingFreqALL);
filteredDataALL=filtfilt(c,d, rawDataALL);
deltaAngleALL=filteredDataALL(2:end) - filteredDataALL(1:(end-1));
deltaTimeALL=trialtimepoopALL(2:end)-trialtimepoopALL(1:end-1)

samplingFreq=size(trialDataAngles,1)/deltaT;
[b,a] = butter(5, butterworthCutoffFrequency*2/samplingFreq);
filteredData = filtfilt(b,a, rawData); %Filters measured angles
deltaAngle = filteredData(2:end) - filteredData(1:(end-1));
deltaTime=trialtimepoop(2:end)-trialtimepoop(1:end-1);
%
%%CALCULATES VELOCITY%%
calculatedVelocities = deltaAngle./deltaTime;
calculatedVelocitiesALL=deltaAngleALL./deltaTimeALL;

%%CALCULATES ACCELERATION%%
filteredData=[];    deltaVelocities =[];    accelerationDataReported=[];

filteredDataALL=filtfilt(c,d,velocitypoopALL);
deltaVelocitiesALL= filteredDataALL(2:end) - filteredDataALL(1:(end-1));
accelerationDataReportedALL= deltaVelocitiesALL./ deltaTimeALL(1:end);

filteredData = filtfilt(b,a, velocitypoop); %Filters measured velocities
deltaVelocities = filteredData(2:end) - filteredData(1:(end-1)); %Calculates change in velocity between each time point
accelerationDataReported = deltaVelocities./ deltaTime(1:end); %Calculates accleration: (change in velocity)/(change in time)
%

%%Calculates centers of loops_lilaavi%%
% trialphwcrashes = td(:, dataIndices.indexTrialPhase);%Trial phases including Crashes
% MARS_Performance_lilaavi(trialDataAnglesALL, trialDataAngles, velocitypoopALL, velocitypoop, accelerationDataReportedALL, accelerationDataReported, trialphwcrashes,trialIndex,human,calculatedVelocitiesALL, calculatedVelocities, trialJoystickx)
% pause
%

% %%CALCULATES MARS METRICS%%
trialphwcrashes = td(:, dataIndices.indexTrialPhase);%Trial phases including Crashes
[meanMARSAngle(trialIndex),meanMARSVelocity(trialIndex),meanMARSAcceleration(trialIndex),stdMARSAngle(trialIndex),crashFrequency(trialIndex),meanMagnitudeMARSAngle(trialIndex),stdRate(trialIndex),meanRateDistsV(trialIndex),meanDrifts(trialIndex),stdDists(trialIndex),driftPercent(trialIndex)] = MARS_Performance(trialDataAnglesALL, trialDataAngles, velocitypoopALL, velocitypoop, accelerationDataReportedALL, accelerationDataReported, trialphwcrashes,trialIndex,human,calculatedVelocitiesALL, calculatedVelocities, trialJoystickx);
% %

%%CALCULATES JOYSTICK METRICS%%
[meanJoyMag(trialIndex),stdJoyMag(trialIndex),intermitJoy(trialIndex)]=Joystick_Control(trialJoystickx,trialph);
%

%%CALCULATES DYNAMIC CONTROL METRICS%%
[destabJoystick(trialIndex),anticipJoystick(trialIndex),meanVelJoystick(trialIndex),meanVelMovements(trialIndex),destabJoystickMoves(trialIndex), anticipJoystickMoves(trialIndex), MeanAnticipatoryPhaseAngle(trialIndex), startMoveMARSPosition(trialIndex)]=Dynamic_Control(trialDataAngles,trialJoystickx, calculatedVelocities,trialtimepoop, trialph);
%
end
end
