function[meanMARSAngle,meanMARSVelocity,meanMARSAcceleration,stdMARSAngle,crashFrequency,meanMagnitudeMARSAngle,meanJoyMag,stdJoyMag,intermitJoy,destabJoystick,anticipJoystick,meanVelJoystick,meanVelMovements,destabJoystickMoves,anticipJoystickMoves, MeanAnticipatoryPhaseAngle]= plotDOB(summaryData, strParticipant, outDir, binCenters, instructionType, saveFile, doDistributionEstimate)

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

butterworthCutoffFrequency = 5;
rawData=trialDataAngles;
deltaT=trialtimepoop(end)-trialtimepoop(1);

samplingFreq=size(trialDataAngles,1)/deltaT;
[b,a] = butter(5, butterworthCutoffFrequency*2/samplingFreq);
filteredData = filtfilt(b,a, rawData); %Filters measured angles
deltaAngle = filteredData(2:end) - filteredData(1:(end-1));
deltaTime=trialtimepoop(2:end)-trialtimepoop(1:end-1);
%
%%CALCULATES VELOCITY%%
calculatedVelocities = deltaAngle./deltaTime;

%%CALCULATES ACCELERATION%%
filteredData=[];    deltaVelocities =[];    accelerationDataReported=[];

filteredData = filtfilt(b,a, velocitypoop); %Filters measured velocities
deltaVelocities = filteredData(2:end) - filteredData(1:(end-1)); %Calculates change in velocity between each time point
accelerationDataReported = deltaVelocities./ deltaTime(1:end); %Calculates accleration: (change in velocity)/(change in time)
%


%%CALCULATES MARS METRICS%%
trialphwcrashes = td(:, dataIndices.indexTrialPhase);%Trial phases including Crashes
[meanMARSAngle(trialIndex),meanMARSVelocity(trialIndex),meanMARSAcceleration(trialIndex),stdMARSAngle(trialIndex),crashFrequency(trialIndex),meanMagnitudeMARSAngle(trialIndex)] = MARS_Performance(trialDataAngles,velocitypoop,accelerationDataReported, trialphwcrashes);
%

%%CALCULATES JOYSTICK METRICS%%
[meanJoyMag(trialIndex),stdJoyMag(trialIndex),intermitJoy(trialIndex)]=Joystick_Control(trialJoystickx,trialph);
%

%%CALCULATES DYNAMIC CONTROL METRICS%%
[destabJoystick(trialIndex),anticipJoystick(trialIndex),meanVelJoystick(trialIndex),meanVelMovements(trialIndex),destabJoystickMoves(trialIndex), anticipJoystickMoves(trialIndex), MeanAnticipatoryPhaseAngle(trialIndex)]=Dynamic_Control(trialDataAngles,trialJoystickx, calculatedVelocities,trialtimepoop, trialph);
%
end
end
