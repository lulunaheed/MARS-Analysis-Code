function [meanMARSAngle,meanMARSVelocity,meanMARSAcceleration,stdMARSAngle,crashFrequency] = MARS_Performance(trialDataAngles,velocitypoop,accelerationDataReported, trialphwcrashes)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%This function calculates the following metrics for each trial:
%STD of Angular Position, Mean Angular Position, Average Angular Position
%Error, Average Angular Velocity Magnitude, Average Angular Acceleration
%Magnitude, Crash Frequency

%Input: This function requires the following data
%       1. MARS angular position for a given trial
%       2. MARS angular velocity for a given trial (we suggest you use the
%       one that comes from the HULK directly)
%       3. MARS angular acceleration
%       4. MARS condition...this is taken from 
%                td(:,dataIndices.indexTrialPhase)...this is trialph with no
%                crashes removed, you can also make a new variable. 


%%Important Notes%%
%Approximately 50 time steps/second
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%CALCULATES MARS METRICS%%

meanMARSAngle= [];  stdMARSAngle= [];   meanMARSVelocity= [];   meanMARSAcceleration=[]; crashFrequency= [];


meanMARSAngle = mean(trialDataAngles); %Calculates mean MARS angular position
stdMARSAngle = std(trialDataAngles) %Calculates std of MARS angular position
meanMARSVelocity = mean(abs(velocitypoop)); %Calculates mean magnitude of angular velocity
% To calculate the mean magnitude of acceleration, we need to account for
% the huge spike that occurs during a crash. We do this by replacing all
% acceration above 300 to 300.  We don't really use this metric, if you
% decide to publish on this, then think about how to make it more legit. 
        normAccel=[];
        normAccel=abs(accelerationDataReported);
        normAccel(find(normAccel>300))=300;
        
meanMARSAcceleration= mean(abs(normAccel)); %Calculates mean magnitude of angular acceleration

BalanceTime=length(trialDataAngles); %To find the balance time, we get the number of timepoints, with crashes being removed
BalanceTimeSec=BalanceTime/50; %To get this in seconds, we divide by the sample rate of 50 samples/sec
NumCrashes=length(find(trialphwcrashes==4));
crashFrequency= NumCrashes/BalanceTimeSec; %This is now in Hz

end
