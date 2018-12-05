function [meanJoyMag,stdJoyMag,intermitJoy] = Joystick_Control(trialJoystickx,trialph)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Last Updated May 22, 2018

%Input: 
%  1. trialJoystickx: a list of the joystick deflection for every timepoint
%  in a given trial. 
%  2. trialph: a list for everytime point when the MARS is under user
%  control

%Output: 
%   1. meanJoyMag: average magnitude of joystick deflections
%   2. stdJoyMag: std of joystick deflection
%   3. intermitJoy: The percentage of time the joystick is at zero
%   deflection or within 0.02 of it.  This threshold of 0.02 was obtained
%   by observing the joystick and noticing that often it was within 0.02 of
%   zero when at the center. 
%   4. freqJoy: frequency of joystick deflections, we will discuss and
%   include later on. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%CALCULATES JOYSTICK METRICS%%

BalanceTime=[];

meanJoyMag= mean(abs(trialJoystickx)); %Calculates mean magnitude of joystick deflections
stdJoyMag= std(trialJoystickx); %Calculates standard deviation of joystick deflections

BalanceTime=length(trialJoystickx); %Calculates amount of time subject was in process of balancing MARS
timeNearZero=length(find(trialJoystickx<.02 & trialJoystickx>-.02 & trialph ==3)); %Determines number of time points joystick was near zero
%trialph==3 is when the operator has control over the MARS

intermitJoy= 100*timeNearZero/BalanceTime; %Calculates the percentage of time joystick is at 0 (-0.02 to 0.02 is considered acceptable range)

end

