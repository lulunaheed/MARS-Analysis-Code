function [meanMARSAngle,meanMARSVelocity,meanMARSAcceleration,stdMARSAngle,crashFrequency,meanMagnitudeMARSAngle,stdRate, meanRateDistsV, meanDrifts,stdDists,driftPercent] = MARS_Performance(trialDataAnglesALL, trialDataAngles, velocitypoopALL, velocitypoop, accelerationDataReportedALL, accelerationDataReported, trialphwcrashes,trialIndex,human,calculatedVelocitiesALL, calculatedVelocities, trialJoystickx)

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


%%CALCULATES MARS METRICS%%

meanMARSAngle= [];  stdMARSAngle= [];   meanMARSVelocity= [];   meanMARSAcceleration=[]; crashFrequency= []; meanMagnitudeMARSAngle=[];


meanMARSAngle = mean(trialDataAngles); %Calculates mean MARS angular position
stdMARSAngle = std(trialDataAngles); %Calculates std of MARS angular position
meanMARSVelocity = mean(abs(velocitypoop)); %Calculates mean magnitude of angular velocity
% To calculate the mean magnitude of acceleration, we need to account for
% the huge spike that occurs during a crash. We do this by replacing all
% acceration above 300 to 300.  We don't really use this metric, if you
% decide to publish on this, then think about how to make it more legit.
normAccel=[];
normAccel=abs(accelerationDataReported);
normAccel(find(normAccel>300))=300;

meanMARSAcceleration= mean(abs(normAccel)); %Calculates mean magnitude of angular acceleration
meanMagnitudeMARSAngle= mean(abs(trialDataAngles));

BalanceTime=length(trialDataAngles); %To find the balance time, we get the number of timepoints, with crashes being removed
BalanceTimeSec=BalanceTime/50; %To get this in seconds, we divide by the sample rate of 50 samples/sec
NumCrashes=length(find(trialphwcrashes==4));
crashFrequency= NumCrashes/BalanceTimeSec; %This is now in Hz


%%QUANTIFYING DRIFT USING POLAR PLOTS (MARS VELOCITY AND POSITION)%%
z=[];  v=[];   j=[];  accel=[];

z=trialDataAnglesALL(1:end-1);%Position
vels=calculatedVelocitiesALL; %Velocity
accelerations=accelerationDataReportedALL;

circlevals=[];
pointDis=[];
meanCircleDis=[];
c=0;
n=length(trialDataAnglesALL);

s=1;
p=0;
qoneval=0;
qtwoval=0;
qthreeval=0;
qfourval=0;

dists=[];

loopsStruct=struct;
numCircle=0;

turnval=3; %number of points required to be in each "quadrant" to be considered an "oval/circle"
starts=[]; %Stores position at which loop starts
ends=[]; %Stores position at which loop ends

rateDists=[];

quadorder=[qoneval qfourval qthreeval qtwoval];
crashes=find(trialphwcrashes==4); %Finds indices of crashes in trial
balance=find(trialphwcrashes==3); %Finds indices of balance periods in trial
numcrashes=length(crashes); %Number of crashes ph==4 in entire trial dataset

if numcrashes==0
    crashes=length(vels);
    numcrashes=1;
end

lengthvels=length(vels);
lengthcrashes=numcrashes;
balancesegstart=[]; %Vector that stores start of balance periods

%%%%%STORE START OF BALANCE INDICES BETWEEN CRASH SEGMENTS IN VECTOR%%%%%%%
for l=1:numcrashes 
    
    if l==1 %For the first balance segment
        oneseg=trialphwcrashes(1:crashes(1)); %Segment begins at first data point until first crash
        balanceinds=find(oneseg==3); %Finds balance periods within this first segment
        value=balanceinds(1); %Picks up index of when balance period begins
        balancesegstart(1)=value; %Stores index of when balance period begins in vector
    else %For remainder of segments
        start=crashes(l-1); %
        finish=crashes(l);
        oneseg=trialphwcrashes(start:finish);
        
        balanceinds=find(oneseg==3); %Finds balance periods within this segment
        value=balanceinds(1)+(start-1); %Calculates the start index of the balance segment
        balancesegstart(l)=value; %Stores start of balance segment
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
updateNumRate=0;
updateNumDist=0;

for d=1:numcrashes %Loops through values between crashes
    
    %lengthLastPoints=0;
    s=1;
    balancestart=balancesegstart(d); %Picks up where balancing begins
    balanceend=crashes(d)-1; %Picks up where balancing ends (1 before crash)
    segmentlength=(balanceend-balancestart)+1; %Calculates balance segment length
    v= vels(balancestart:balanceend); %Picks up velocities within balance segment
    a= z(balancestart:balanceend); %Picks up positions within balance segment
    accel= accelerations(balancestart:balanceend); %Picks up accelerations within balance segment
    
    numCircle=0;
    rateDistsV=[];
    distsV=[];
    disp('New Segment')
    
    while s<length(v)
        
        aq1=[]; %Initialize vectors collecting points in each loop "quadrant"
        vq1=[];
        aq2=[];
        vq2=[];
        aq3=[];
        vq3=[];
        aq4=[];
        vq4=[];
        addValaFINAL=[];
        addValvFINAL=[];
        
  %%%FIND POINTS IN THE LOOP BASED ON VELOCITY AN ACCELERATION%%%%%%%%%%%%%     
        while (((qoneval<turnval)||(qtwoval<turnval)||(qthreeval<turnval)||(qfourval<turnval)))&(s<length(v)) %Will continue until there are at least turnval number of points in each loop "quadrant"
            c=c+1;
            
            if (v(s)>0)&&(accel(s)<0) %Finds points in quadrant 1
                qoneval=qoneval+1;
                aq1(c)=a(s);
                vq1(c)=v(s);
                accel1(c)=accel(s);
                addVala=a(s);
                addValv=v(s);
            end
            
            if (v(s)<0)&&(accel(s)<0) %Finds points in quadrant 4
                qfourval=qfourval+1;
                aq4(c)=a(s);
                vq4(c)=v(s);
                accel4(c)=accel(s);
                addVala=a(s);
                addValv=v(s);
            end
            
            if (v(s)<0)&&(accel(s)>0) %Finds points in quadrant 3
                qthreeval=qthreeval+1;
                aq3(c)=a(s);
                vq3(c)=v(s);
                accel3(c)=accel(s);
                addVala=a(s);
                addValv=v(s);
            end
            
            if (v(s)>0)&&(accel(s)>0) %Finds points in quadrant 2
                qtwoval=qtwoval+1;
                aq2(c)=a(s);
                vq2(c)=v(s);
                accel2(c)=accel(s);
                addVala=a(s);
                addValv=v(s);
            end
            
            addValaFINAL(c)=addVala; %Stores position values without zeros
            addValvFINAL(c)=addValv; %Stores velocity values without zeros
            
            s=s+1;
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        orderv=addValvFINAL;
        ordera=addValaFINAL;
        
%%%%%%FINDS INDICES OF WHERE POINTS IN LOOP CROSSED HORIZONTAL AXIS%%%%%%%%
        nep=1;
        ind=[];
        firstSign=sign(orderv(1));  
        for p=1:length(orderv) 
            if sign(orderv(p))~=firstSign
                ind(nep)=p;
                nep=nep+1;
                firstSign=sign(orderv(p));
            end
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%DETERMINE WHERE THE LOOP STARTS AND ENDS ON HORIZONTAL AXIS%%%%%%%%%%%
        lengthind=length(ind); %Calculates number of times loop crossed horizontal axis
       numCircle= numCircle+1;
        if (lengthind>0) %If loop crossed horizontal axis at least once
            
             %Counts number of loops 

            if length(ind)==1 %If the loop only crossed once
               
                xvalFirstPoint=ordera(1);
                signFirstPoint=sign(orderv(1));
                xvalSignChange=ordera(ind(1));
                starts(numCircle)=xvalFirstPoint;
                ends(numCircle)=xvalSignChange;
                lengthLastPoints=length(find(sign(orderv)~=signFirstPoint));
            else %If the loop crossed more than once
               
                length(ordera);
                ind(1);
                xvalFirstPoint=ordera(ind(1));
                xvalSignChange=ordera(ind(end));
                starts(numCircle)=xvalFirstPoint;
                ends(numCircle)=xvalSignChange;
                lengthLastPoints=length(orderv(ind(end):end));
            end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

            [largestV largestVIndex]=max(abs(orderv(1:end-lengthLastPoints)));
            centerV=addValaFINAL(largestVIndex);
            
            figure(1)
            title(['Segment ' num2str(d)]);
            hold on
            plot(xvalFirstPoint,0,'bo');
            
            plot(xvalSignChange,0,'ro');
          centerp1=mean([xvalFirstPoint xvalSignChange]);
            %plot(centerp1,0,'mo-');
            plot(centerV,0,'go-');
            
            plot(aq1,vq1,'.k')
            xlim([-30 30]);
            ylim([-150 150]);
            hold on
            plot(aq4,vq4,'.k');
            plot(aq3,vq3,'.k');
            plot(aq2,vq2,'.k');
            grid on

            s=s-lengthLastPoints; %updates s to remove extra points in the end (last quadrant)
            numBins(numCircle)=s+largestVIndex-1;
%%%%%%%%%RECORD METRICS OF LOOPS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Location of loop center from origin (0,0)
            distsV(numCircle)=centerV;
          
            if numCircle>1
                rateDistsV(numCircle-1)=(distsV(numCircle)-distsV(numCircle-1))/((numBins(numCircle)-numBins(numCircle-1))/50);
            else
                rateDistsP(1)=NaN;
                rateDistsV(1)=NaN;
            end 
        else
            numBins(numCircle)=nan;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        
        end
%         figure(2)
%         plot(numCircle,centerp1,'.m')
%         hold on
%         plot(numCircle,centerV,'*g')
%         grid on
        
        c=0;
        qoneval=0;
        qtwoval=0;
        qthreeval=0;
        qfourval=0;
        
    end
    
    disp('Finished Segment')
        good1=((isnan(rateDistsV)==0)&(isinf(rateDistsV)==0));
        good2=((isnan(distsV)==0)&(isinf(distsV)==0));
        %lenRate=length(rateDistsV(good1));
        lenDist=length(distsV(good2));
        goodBins=numBins(good2);
        %goodBins=1:length(distsV(good2));
        updateNumRate=updateNumRate+1
        if lenDist>1
            g1=fittype('m*x+C');
            lineFit=fit(goodBins',distsV(good2)',g1,'startpoint',[0 0])
            rateDistsV(good1)
            figure(3)
            histogram(rateDistsV(good1),-60:2:60)
            xlim([-70 70])
            hold on
            figure(4)
            histogram(distsV(good2),-60:2:60)%See how close loop distance distribution is to Gaussian distributions
            xlim([-70 70])
            hold on
            G1=g1(lineFit.C,lineFit.m,goodBins');
            SSresiduals=sum((distsV(good2)'-G1).^2);
            SStotal=sum((distsV(good2)'-mean(distsV(good2))).^2);
            Rsqr1=1-SSresiduals/SStotal;
            if Rsqr1>0.5
                %disp('passed!')
                segmentRateDistsV(updateNumRate)= lineFit.m;
                segmentDriftNum(updateNumRate)=1;
            else
                %disp('no pass!')
                segmentRateDistsV(updateNumRate)= lineFit.m; %potentially change to 0
                segmentDriftNum(updateNumRate)=0;
            end
        else
            segmentDriftNum(updateNumRate)=nan;
            segmentRateDistsV(updateNumRate)= nan;
        end
        %segmentRateDistsV((updateNumRate+1):(updateNumRate+lenRate))=rateDistsV(good1);
        segmentDistsV((updateNumDist+1):(updateNumDist+lenDist))=distsV(good2);
        %updateNumRate=updateNumRate+lenRate;
        updateNumDist=updateNumDist+lenDist;

end
segmentRateDistsV
gut=((isnan(segmentRateDistsV)==0)&(isinf(segmentRateDistsV)==0));
segmentRateDistsV=segmentRateDistsV(gut);
segmentDriftNum=segmentDriftNum((isnan(segmentDriftNum)==0)&(isinf(segmentDriftNum)==0));
% good1=((isnan(rateDistsV)==0)&(isinf(rateDistsV)==0));
% rateDistsV=abs(rateDistsV(good1));

% figure()
% redpts=find(segmentDriftNum==0);
% bluepts=find(segmentDriftNum==1);
% plot(redpts,2.*ones(length(redpts)),'or-')
% hold on
% plot(bluepts,abs(segmentRateDistsV),'ob-')
% 
% numRed=length(find(segmentDriftNum==0))
% numBlue=length(find(segmentDriftNum==1))


driftPercent=100.*(sum(segmentDriftNum))/length(segmentDriftNum);

meanRateDistsV=mean(abs(segmentRateDistsV));

meanDrifts=mean(abs(segmentDistsV));

stdRate=std(abs(segmentRateDistsV));

stdDists=std(abs(segmentDistsV));

end









