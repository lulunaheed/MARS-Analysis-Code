function [destabJoystick,anticipJoystick,meanVelJoystick,meanVelMovements,destabJoystickMoves,anticipJoystickMoves, MeanAnticipatoryPhaseAngle] = Dynamic_Control(trialDataAngles,trialJoystickx, calculatedVelocities,trialtimepoop, trialph)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Last Updated May 24, 2018

%Input: 
%  1. trialDataAngles: a list of MARS angular position for every timepoint in a trial 
%  2. trialJoystickx: a list of the joystick deflection for every timepoint
%     in a given trial. 
%  3. calculatedVelocities: a list of MARS velocity. This is the velocity that we obtained by differentiating the position,
%     we chose this instead of the velocity that directly comes from the MARS, because that one is slightly delayed. 
%  4. trialtimepoop: The actual time points from the MARS for a given trial
%  5. trialph: The condition that the MARS is in. 

%Output: 
%   1. destabJoystick: the percentage of destabilizing joystick timepoints:
%   that is where the position, velocity and joystick deflection all have
%   the same sign. 
%   2. stdJoyMag: std of joystick deflection
%   3. intermitJoy: The percentage of time the joystick is at zero
%   deflection or within 0.02 of it.  This threshold of 0.02 was obtained
%   by observing the joystick and noticing that often it was within 0.02 of
%   zero when at the center. 
%   4. freqJoy: frequency of joystick deflections, we will discuss and
%   include later on. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%These thresholds have been used in the past and we have published with
%them.  They are somewhat arbitrary and based on observations of plots.  At
%some point, it would be nice to have a more rigorous way of determining the
%thresholds. 
anglepeakthresh= 0.05;
joythres=0.05;
angthres=2;
velthres=2;

BalanceTime= length(find(trialph==3));
%Balance time is where the operator has control of the MARS (ie trialph==3)

%%CALCULATES PERCENTAGE OF DESTABILIZING POINTS IN JOYSTICK DATASET%%
destabPoints=length(find((trialDataAngles(1:end-1)>angthres & -trialJoystickx(1:end-1)>joythres & trialph(1:end-1)==3 & calculatedVelocities>velthres) | (trialDataAngles(1:end-1)<-angthres & -trialJoystickx(1:end-1)<-joythres & trialph(1:end-1)==3 & calculatedVelocities<-velthres)));
destabJoystick = 100*destabPoints/BalanceTime;

%CALCULATES PERCENTAGE OF ANTICIPATORY POINTS IN JOYSTICK DATASET
redpos=length(find(trialDataAngles(1:end-1)>angthres & -trialJoystickx(1:end-1)>joythres & calculatedVelocities <-velthres & trialph(1:end-1)==3));
redneg=length(find(trialDataAngles(1:end-1)<-angthres & -trialJoystickx(1:end-1)<-joythres & calculatedVelocities >velthres & trialph(1:end-1)==3));

anticipJoystick=100*(redpos+redneg)/BalanceTime;

%CALCULATES THE PHASE ANGLE OF ANTICIPATORY POINTS IN JOYSTICK DATASET
beg=1;
fin=length(calculatedVelocities);

a=trialDataAngles(beg:fin);
j=-trialJoystickx(beg:fin);
v=calculatedVelocities(beg:fin);

RedPhaseIV=find(a>angthres & j>joythres & v <-velthres);
AnticipPhaseAngle4=2*pi-abs(atan(v(RedPhaseIV)./a(RedPhaseIV)));
 
RedPhaseII=find(a<-angthres & j<-joythres & v > velthres);
AnticipPhaseAngle2=pi-abs(atan(v(RedPhaseII)./a(RedPhaseII)));

MeanAnticipatoryPhaseAngle=mean([(AnticipPhaseAngle4*180/pi-180) ; (AnticipPhaseAngle2*180/pi)]);



%%CALCULATES JOYSTICK VELOCITY%%
deltaTrialJoystickx= trialJoystickx(2:end) - trialJoystickx(1:(end-1));
deltaTime= trialtimepoop(2:end)-trialtimepoop(1:end-1);
velJoystick= deltaTrialJoystickx./deltaTime;%Calculates velocity of Joystick movements
velJoystickThresh=0.02; %Velocity of Joystick that is considered to be the initiation of a movement
meanVelJoystick=mean(velJoystick);
sizemeanVelJoystick= size(meanVelJoystick)
%

%%CALCULATES PERCENTAGE OF DESTABILIZING JOYSTICK MOVEMENTS%%
n=1;
velMovements=[]; %Vector that contains velocity of joystick movements
startMoves=[]; %Angle of MARS at start of joystick movement
startind=[]; %Movement number
startJoy=[]; %Joystick position value at start of movement
numMoves=1;
    while n<length(velJoystick)
    num=1;
    a=0;
    if (abs(velJoystick(n+a)) > velJoystickThresh)
        changeMovement=velJoystick(n);
    while (n+num)<=length(velJoystick) && (sign(velJoystick(n+num)) == sign(velJoystick(n+a))) && (abs(velJoystick(n+num)) > velJoystickThresh)
        changeMovement=changeMovement + velJoystick(n+num);
        num=num+1;
        a=a+1;
    end
    startind(numMoves)=n;
    startMoves(numMoves)=trialDataAngles(n);
    n= n+num;
    velMovements(numMoves)= changeMovement/num;
    numMoves= numMoves+1;
    else
    n=n+1;
    end
    end
    
meanVelMovements= mean(velMovements);

startMoves=startMoves';

newcalculatedvelocities= calculatedVelocities(startind); %Picks up MARS angular velocity at start of joystick movements
startjoystickpos= trialJoystickx(startind);
destabMoves= length(find((startMoves(1:end)>angthres & -startjoystickpos(1:end)>joythres & newcalculatedvelocities>velthres)|(startMoves(1:end)<-angthres & -startjoystickpos(1:end)<-joythres & newcalculatedvelocities<-velthres)));
destabJoystickMoves= 100*destabMoves/numMoves; %Calculate fraction of destabilizing Joystick movements

%CALCULATES PERCENTAGE OF ANTICIPATORY JOYSTICK MOVES

redposmoves=length(find(startMoves(1:end)>angthres & -startjoystickpos(1:end)>joythres & newcalculatedvelocities <-velthres));
rednegmoves=length(find(startMoves(1:end)<-angthres & -startjoystickpos(1:end)<-joythres & newcalculatedvelocities >velthres));

anticipJoystickMoves=100*(redposmoves+rednegmoves)/numMoves

% newcalculatedvelocities= 2;    
% destabMoves= 2;
% destabJoystickMoves= 2; %Calculate fraction of destabilizing Joystick movements

end

 

