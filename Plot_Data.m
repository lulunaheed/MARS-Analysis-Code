%Compares Day1 on the Back (BackBack)to Day1 on the Upright (UprightUpright) 
clear
load IncrementalPitch_Day1vDay2_NEWAnalysis


nob=5;   %number of blocks
notib=4;   %number of trials in a block
notib=notib-1;
wantclear=0;
wantmidpoint=0;
%The good:
cutz=[1,2,3,4,5,6,9,12,13,14,17,19];

%MARS PERFORMANCE METRICS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if wantclear==1
alltrial_stdMARSAngle5(:,cutz)=[];% makes blocks
alltrial_stdMARSAngle6(:,cutz)=[];
alltrial_meanMARSAngle5(:,cutz)=[];
alltrial_meanMARSAngle6(:,cutz)=[];
alltrial_crashFrequency5(:,cutz)=[];
alltrial_crashFrequency6(:,cutz)=[];
alltrial_triallength5(:,cutz)=[];
alltrial_triallength6(:,cutz)=[];
end

blockstdz5=[];
bbcounter=1;
for bb=1:nob
    blockstdz5(:,bb)=mean(alltrial_stdMARSAngle5(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end

blockstdz6=[];
bbcounter=1;
for bb=1:nob
    blockstdz6(:,bb)=mean(alltrial_stdMARSAngle6(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end

blockmean5=[];
bbcounter=1;
for bb=1:nob
    blockmean5(:,bb)=mean(alltrial_meanMARSAngle5(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end

blockmean6=[];
bbcounter=1;
for bb=1:nob
    blockmean6(:,bb)=mean(alltrial_meanMARSAngle6(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end

blockmeanmag5=[];
bbcounter=1;
for bb=1:nob
    blockmeanmag5(:,bb)=mean(alltrial_meanMagnitudeMARSAngle5(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end

blockmeanmag6=[];
bbcounter=1;
for bb=1:nob
    blockmeanmag6(:,bb)=mean(alltrial_meanMagnitudeMARSAngle6(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end

blockcrash5=[];
bbcounter=1;
for bb=1:nob
    blockcrash5(:,bb)=mean(alltrial_crashFrequency5(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end

blockcrash6=[];
bbcounter=1;
for bb=1:nob
    blockcrash6(:,bb)=mean(alltrial_crashFrequency6(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end

blockMARSacceleration5=[];
bbcounter=1;
for bb=1:nob
    blockMARSacceleration5(:,bb)=mean(alltrial_meanMARSAcceleration5(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end

blockMARSacceleration6=[];
bbcounter=1;
for bb=1:nob
    blockMARSacceleration6(:,bb)=mean(alltrial_meanMARSAcceleration6(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end

blockMARSvelocity5=[];
bbcounter=1;
for bb=1:nob
    blockMARSvelocity5(:,bb)=mean(alltrial_meanMARSVelocity5(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end

blockMARSvelocity6=[];
bbcounter=1;
for bb=1:nob
    blockMARSvelocity6(:,bb)=mean(alltrial_meanMARSVelocity6(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end


starman1=[]; starman2=[]; starman3=[]; starman4=[]; starman5=[];
[starman1 starman2 starman3 starman4 starman5]=adjustedpppme2(blockstdz5,blockstdz6);

% figure()
% %subplot(1,3,1)
% plot((1:5),blockstdz5','.-c','LineWidth',0.5)
% hold on
% plot((6:10),blockstdz6','.-m','LineWidth',0.5)
% a=plot((1:5),mean(blockstdz5),'+-c','LineWidth',4)
% b=plot((6:10),mean(blockstdz6),'+-m','LineWidth',4)
% legend([a b],{'Day 1', 'Day 2'});
% xlabel('Block Number')
% ylabel('Standard Deviation')
% % xlabel(['[' num2str(starman5) '] ' 'Block Number' ' [' num2str(starman4) ']'])
% % ylabel(['Standard Deviation [' num2str(starman3) ']'])
% title('MARS STD')
% %title(['[' num2str(starman1) '] HULK STD [' num2str(starman2) ']'])
% ylim([0 30])
% set(gca,'fontsize',14)

figure()
valstd=[alltrial_stdMARSAngle5; alltrial_stdMARSAngle6];
plot((1:1:40),valstd,'LineWidth',0.5)
hold on
plot((1:1:40),mean(valstd'),'-b','LineWidth',4)
xlabel('Trial Number')
ylabel('Standard Deviation (deg))')
title('Standard Deviation of MARS Angle')
set(gca,'FontSize', 14)
% 
% std1=mean(blockstdz5);
% std2=mean(blockstdz6);
% valstd1= std1(1);
% valstd2= std2(5);
% 
% figure()
% bar([1 10],[valstd1 valstd2],'r');
% xlabel('Block Number')
% ylabel('Standard Deviation')
% title('MARS STD')

starman1=[]; starman2=[]; starman3=[]; starman4=[]; starman5=[];
[starman1 starman2 starman3 starman4 starman5]=adjustedpppme2(blockmean5,blockmean6);

% figure()
% %subplot(1,3,2)
% plot((1:5),blockmean5','.-c','LineWidth',0.5)
% hold on
% plot((6:10),blockmean6','.-m','LineWidth',0.5)
% a=plot((1:5),mean(blockmean5),'+-c','LineWidth',4)
% b=plot((6:10),mean(blockmean6),'+-m','LineWidth',4)
% legend([a b],{'Day 1', 'Day 2'});
% xlabel('Block Number')
% ylabel('Average')
% % xlabel([ '[' num2str(starman5) '] ' 'Block Number' ' [' num2str(starman4) ']'])
% % ylabel(['Average [' num2str(starman3) ']'])
% title('MARS MEAN')
% %title(['[' num2str(starman1) '] HULK MEAN [' num2str(starman2) ']'])
% set(gca,'fontsize',12)

figure()
valmeanmag=[alltrial_meanMagnitudeMARSAngle5; alltrial_meanMagnitudeMARSAngle6];
plot((1:1:40),valmeanmag,'LineWidth',0.5)
hold on
plot((1:1:40),mean(valmeanmag'),'-b','LineWidth',4)
xlabel('Trial Number')
ylabel('Mean Magnitude of Position (deg))')
title('Average Magnitude of MARS Angular Position')
set(gca,'FontSize', 14)


starman1=[]; starman2=[]; starman3=[]; starman4=[]; starman5=[];
[starman1 starman2 starman3 starman4 starman5]=adjustedpppme2(blockcrash5,blockcrash6);

% figure()
% subplot(1,2,1)
% plot((1:5),blockcrash5','.-c','LineWidth',0.5)
% hold on
% plot((6:10),blockcrash6','.-m','LineWidth',0.5)
% a=plot((1:5),mean(blockcrash5),'+-c','LineWidth',4)
% b=plot((6:10),mean(blockcrash6),'+-m','LineWidth',4)
% legend([a b],{'Day 1', 'Day 2'});
% xlabel('Block Number')
% ylabel('Crashes')
% % xlabel([ '[' num2str(starman5) '] ' 'Block Number' ' [' num2str(starman4) ']'])
% % ylabel(['Crashes [' num2str(starman3) ']'])
% title('MARS CRASHES')
% %title(['[' num2str(starman1) '] HULK CRASHES [' num2str(starman2) ']'])
% %subtitle('Day2: Control(blue) vs Experimental(red) n=7')
% ylim([0 0.25])
% set(gca,'fontsize',12)

figure()
valcrash=[alltrial_crashFrequency5; alltrial_crashFrequency6];
plot((1:1:40),valcrash,'LineWidth',0.5)
hold on
plot((1:1:40),mean(valcrash'),'-b','LineWidth',4)
xlabel('Trial Number')
ylabel('Crash Frequency(#Crashes/Balance Time)')
title('MARS Crash Frequency')
set(gca,'FontSize', 14)

crash1=mean(blockcrash5);
crash2=mean(blockcrash6);
valcrash1= crash1(1);
valcrash2= crash2(5);

figure()
control=[0.2 0.05];
experimental= [valcrash1 valcrash2];
stdexperimental1= std(blockcrash5(:,1))
stdexperimental10=std(blockcrash6(:,5))
stdcontrol1= 0.0564;
stdcontrol10= 0.0197;
err=[stdcontrol1 stdcontrol10 stdexperimental1 stdexperimental10];
y=[control experimental]
x=(1:4);
bar(x,y,'b')
hold on
errorbar(x,y,err,'k','LineStyle','none');

xlabel('Block Number')
ylabel('Crash Frequency (#Crashes/Balance Time)')
title('MARS Crash Frequency')
set(gca,'FontSize', 14)


% figure()
% subplot(1,2,1)
% plot((1:5),blockMARSacceleration5','.-c','LineWidth',0.5)
% hold on
% plot((6:10),blockMARSacceleration6','.-m','LineWidth',0.5)
% a=plot((1:5),mean(blockMARSacceleration5),'+-c','LineWidth',4)
% b=plot((6:10),mean(blockMARSacceleration6),'+-m','LineWidth',4)
% legend([a b],{'Day 1', 'Day 2'});
% xlabel('Block Number')
% ylabel('deg/s^2')
% title('MARS Acceleration')
% xlim([1 10])
% %subtitle('Day2: Control(blue) vs Experimental(red) n=7')
% %xlim([1 20])
% %ylim([0 0.25])
% set(gca,'fontsize',12)

figure()
valaccel=[alltrial_meanMARSAcceleration5; alltrial_meanMARSAcceleration6];
plot((1:1:40),valaccel,'LineWidth',0.5)
hold on
plot((1:1:40),mean(valaccel'),'-b','LineWidth',4)
xlabel('Trial Number')
ylabel('Acceleration (deg/s^2)')
title('MARS Acceleration')
set(gca,'FontSize', 14)

accel1=mean(blockMARSacceleration5);
accel2=mean(blockMARSacceleration6);
valaccel1= accel1(1);
valaccel2= accel2(5);

figure()
control=[81 83];
experimental= [valaccel1 valaccel2];
stdexperimental1= std(blockMARSacceleration5(:,1))
stdexperimental10=std(blockMARSacceleration6(:,5))
stdcontrol1= 28.7386;
stdcontrol10= 67.7298;
err=[stdcontrol1 stdcontrol10 stdexperimental1 stdexperimental10];
y=[control experimental]
x=(1:4);
bar(x,y,'b')
hold on
errorbar(x,y,err,'k','LineStyle','none');

xlabel('Block Number')
ylabel('Acceleration (deg/s^2)')
title('MARS Acceleration')
set(gca,'FontSize', 14)
 
 
 
% subplot(1,2,2)
% plot((1:5),blockMARSvelocity5','.-c','LineWidth',0.5)
% hold on
% plot((6:10),blockMARSvelocity6','.-m','LineWidth',0.5)
% a=plot((1:5),mean(blockMARSvelocity5),'+-c','LineWidth',4)
% b=plot((6:10),mean(blockMARSvelocity6),'+-m','LineWidth',4)
% legend([a b],{'Day 1', 'Day 2'});
% xlabel('Block Number')
% ylabel('deg/s')
% title('MARS Velocity')
% xlim([1 10])
% %subtitle('Day2: Control(blue) vs Experimental(red) n=7')
% %xlim([1 20])
% %ylim([0 0.25])
% set(gca,'fontsize',12)

figure()
valvelocity=[alltrial_meanMARSVelocity5; alltrial_meanMARSVelocity6];
plot((1:1:40),valvelocity,'LineWidth',0.5)
hold on
plot((1:1:40),mean(valvelocity'),'-b','LineWidth',4)
xlabel('Trial Number')
ylabel('Velocity (deg/s)')
title('MARS Velocity')
set(gca,'FontSize', 14)

velocity1=mean(blockMARSvelocity5);
velocity2=mean(blockMARSvelocity6);
valvelocity1= velocity1(1);
valvelocity2= velocity2(5);

figure()
control=[23.9 22.2];
experimental= [valvelocity1 valvelocity2];
stdexperimental1= std(blockMARSvelocity5(:,1))
stdexperimental10=std(blockMARSvelocity6(:,5))
stdcontrol1= 6.2039;
stdcontrol10= 11.8374;
err=[stdcontrol1 stdcontrol10 stdexperimental1 stdexperimental10];
y=[control experimental]
x=(1:4);
bar(x,y,'b')
hold on
errorbar(x,y,err,'k','LineStyle','none');

xlabel('Block Number')
ylabel('Velocity (deg/s)')
title('MARS Velocity')
set(gca,'FontSize', 14)
 

%JOYSTICK CONTROL METRICS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
blockmeanjoy5=[];
bbcounter=1;
for bb=1:nob
    blockmeanjoy5(:,bb)=mean(alltrial_meanJoyMag5(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end

blockmeanjoy6=[];
bbcounter=1;
for bb=1:nob
    blockmeanjoy6(:,bb)=mean(alltrial_meanJoyMag6(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end

blockstdjoy5=[];
bbcounter=1;
for bb=1:nob
    blockstdjoy5(:,bb)=mean(alltrial_stdJoyMag5(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end

blockstdjoy6=[];
bbcounter=1;
for bb=1:nob
    blockstdjoy6(:,bb)=mean(alltrial_stdJoyMag6(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end

blockintermitjoy5=[];
bbcounter=1;
for bb=1:nob
    blockintermitjoy5(:,bb)=mean(alltrial_intermitJoy5(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end

blockintermitjoy6=[];
bbcounter=1;
for bb=1:nob
    blockintermitjoy6(:,bb)=mean(alltrial_intermitJoy6(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end


% figure()
% plot((1:5),blockmeanjoy5','.-c','LineWidth',0.5)
% hold on
% plot((6:10),blockmeanjoy6','.-m','LineWidth',0.5)
% a=plot((1:5),mean(blockmeanjoy5),'+-c','LineWidth',4)
% b=plot((6:10),mean(blockmeanjoy6),'+-m','LineWidth',4)
% legend([a b],{'Day 1','Day 2'})
% xlabel('Block Number')
% ylabel('Magnitude')
% title('Magnitude of Joystick Deflection Points')
% %subtitle('Day2: Control(blue) vs Experimental(red) n=7')
% %xlim([1 20])
% %ylim([0 0.25])
% set(gca,'fontsize',12)

figure()
valjoymag=[alltrial_meanJoyMag5; alltrial_meanJoyMag6];
plot((1:1:40),valjoymag,'LineWidth',0.5)
hold on
plot((1:1:40),mean(valjoymag'),'-b','LineWidth',4)
xlabel('Trial Number')
ylabel('Mean Joystick Magnitude (deg))')
title('Average Magnitude of Joystick Position')
set(gca,'FontSize', 14)
% 
% figure()
% subplot(1,2,1)
% plot((1:5),blockstdjoy5','.-c','LineWidth',0.5)
% hold on
% plot((6:10),blockstdjoy6','.-m','LineWidth',0.5)
% a=plot((1:5),mean(blockstdjoy5),'+-c','LineWidth',4)
% b=plot((6:10),mean(blockstdjoy6),'+-m','LineWidth',4)
% legend([a b],{'Day 1','Day 2'})
% xlim([1 10])
% xlabel('Block Number')
% ylabel('STD')
% title('STD of Joystick Deflection Points')
% %subtitle('Day2: Control(blue) vs Experimental(red) n=7')
% %xlim([1 20])
% %ylim([0 0.25])
% set(gca,'fontsize',12)

figure()
valstdjoy=[alltrial_stdJoyMag5; alltrial_stdJoyMag6];
plot((1:1:40),valstdjoy,'LineWidth',0.5)
hold on
plot((1:1:40),mean(valstdjoy'),'-b','LineWidth',4)
xlabel('Trial Number')
ylabel('Standard Deviation')
title('Standard Deviation of Joystick Position')
set(gca,'FontSize', 14)

figure()
valmeanmag=[alltrial_meanMagnitudeMARSAngle5; alltrial_meanMagnitudeMARSAngle6];
plot((1:1:40),valmeanmag,'LineWidth',0.5)
hold on
plot((1:1:40),mean(valmeanmag'),'-b','LineWidth',4)
xlabel('Trial Number')
ylabel('Mean Magnitude of Position (deg))')
title('Average Magnitude of MARS Angular Position')
set(gca,'FontSize', 14)
% 
% subplot(1,2,2)
% a=plot((1:5),mean(blockintermitjoy5),'+-c','LineWidth',4)
% hold on
% b=plot((6:10),mean(blockintermitjoy6),'+-m','LineWidth',4)
% plot((1:5),blockintermitjoy5','.-c','LineWidth',0.5)
% plot((6:10),blockintermitjoy6','.-m','LineWidth',0.5)
% legend([a b],{'Day 1', 'Day 2'});
% xlabel('Block Number')
% ylabel('Percent')
% title('Joystick Intermittency')
% xlim([1 10])
% %subtitle('Day2: Control(blue) vs Experimental(red) n=7')
% %xlim([1 20])
% %ylim([0 0.25])
% set(gca,'fontsize',12)

figure()
valintermitjoy=[alltrial_intermitJoy5; alltrial_intermitJoy6];
plot((1:1:40),valintermitjoy,'LineWidth',0.5)
hold on
plot((1:1:40),mean(valintermitjoy'),'-b','LineWidth',4)
xlabel('Trial Number')
ylabel('Percentage (%)')
title('Joystick Intermittency')
set(gca,'FontSize', 14)

%JOYSTICK PERFORMANCE METRICS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
blockdestabjoystick5=[];
bbcounter=1;
for bb=1:nob
    blockdestabjoystick5(:,bb)=mean(alltrial_destabJoystick5(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end

blockdestabjoystick6=[];
bbcounter=1;
for bb=1:nob
    blockdestabjoystick6(:,bb)=mean(alltrial_destabJoystick6(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end

blockdestabjoystickmoves5=[];
bbcounter=1;
for bb=1:nob
    blockdestabjoystickmoves5(:,bb)=mean(alltrial_destabJoystickMoves5(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end

blockdestabjoystickmoves6=[];
bbcounter=1;
for bb=1:nob
    blockdestabjoystickmoves6(:,bb)=mean(alltrial_destabJoystickMoves6(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end

blockanticipjoystickmoves5=[];
bbcounter=1;
for bb=1:nob
    blockanticipjoystickmoves5(:,bb)=mean(alltrial_anticipJoystickMoves5(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end

blockanticipjoystickmoves6=[];
bbcounter=1;
for bb=1:nob
    blockanticipjoystickmoves6(:,bb)=mean(alltrial_anticipJoystickMoves6(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end


blockanticipjoystick5=[];
bbcounter=1;
for bb=1:nob
    blockanticipjoystick5(:,bb)=mean(alltrial_anticipJoystick5(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end

blockanticipjoystick6=[];
bbcounter=1;
for bb=1:nob
    blockanticipjoystick6(:,bb)=mean(alltrial_anticipJoystick6(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end

blockmeanveljoystick5=[];
bbcounter=1;
for bb=1:nob
    blockmeanveljoystick5(:,bb)=mean(alltrial_meanVelJoystick5(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end

blockmeanveljoystick6=[];
bbcounter=1;
for bb=1:nob
    blockmeanveljoystick6(:,bb)=mean(alltrial_meanVelJoystick6(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end

blockmeanvelmovements5=[];
bbcounter=1;
for bb=1:nob
    blockmeanvelmovements5(:,bb)=mean(alltrial_meanVelMovements5(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end

blockmeanvelmovements6=[];
bbcounter=1;
for bb=1:nob
    blockmeanvelmovements6(:,bb)=mean(alltrial_meanVelMovements6(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end


blockmeananticipatoryphaseangle5=[];
bbcounter=1;
for bb=1:nob
    blockmeananticipatoryphaseangle5(:,bb)=mean(alltrial_MeanAnticipatoryPhaseAngle5(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end

blockmeananticipatoryphaseangle6=[];
bbcounter=1;
for bb=1:nob
    blockmeananticipatoryphaseangle6(:,bb)=mean(alltrial_MeanAnticipatoryPhaseAngle6(bbcounter:bbcounter+notib,:));
    bbcounter=bbcounter+notib+1;
end

% figure()
% subplot(1,3,1)
% plot((1:5),blockdestabjoystick5','.-c','LineWidth',0.5)
% hold on
% plot((6:10),blockdestabjoystick6','.-m','LineWidth',0.5)
% a=plot((1:5),mean(blockdestabjoystick5),'+-c','LineWidth',4)
% b=plot((6:10),mean(blockdestabjoystick6),'+-m','LineWidth',4)
% legend([a b],{'Day 1','Day 2'})
% xlabel('Block Number')
% ylabel('Percentage')
% title('Percentage of Destabilizing Points in Joystick Dataset')
% xlim([1 10])
% %subtitle('Day2: Control(blue) vs Experimental(red) n=7')
% %xlim([1 20])
% ylim([0 7])
% set(gca,'fontsize',12)

figure()
valdestab=[alltrial_destabJoystick5; alltrial_destabJoystick6];
plot((1:1:40),valdestab,'LineWidth',0.5)
hold on
plot((1:1:40),mean(valdestab'),'-b','LineWidth',4)
xlabel('Trial Number')
ylabel('Percentage (%)')
title('Percentage of Destabilizing Points in Joystick Dataset')
set(gca,'FontSize', 14)

destab1=mean(blockdestabjoystick5);
destab2=mean(blockdestabjoystick6);
valdestab1= destab1(1);
valdestab2= destab2(5);

figure()
control=[3.7 1.6];
experimental= [valdestab1 valdestab2];
stdexperimental1= std(blockdestabjoystick5(:,1))
stdexperimental10=std(blockdestabjoystick6(:,5))
stdcontrol1= 1.9038;
stdcontrol10= 1.8570;
err=[stdcontrol1 stdcontrol10 stdexperimental1 stdexperimental10];
y=[control experimental]
x=(1:4);
bar(x,y,'b')
hold on
errorbar(x,y,err,'k','LineStyle','none');

xlabel('Block Number')
ylabel('Percentage (%)')
title('Percentage of Destabilizing Points in Joystick Dataset')
set(gca,'FontSize', 14)

% subplot(1,3,2)
% plot((1:5),blockanticipjoystick5','.-c','LineWidth',0.5)
% hold on
% plot((6:10),blockanticipjoystick6','.-m','LineWidth',0.5)
% a=plot((1:5),mean(blockanticipjoystick5),'+-c','LineWidth',4)
% b=plot((6:10),mean(blockanticipjoystick6),'+-m','LineWidth',4)
% legend([a b],{'Day 1','Day 2'})
% xlabel('Block Number')
% ylabel('Percentage')
% title('Percentage of Anticipatory Points in Joystick Dataset')
% %subtitle('Day2: Control(blue) vs Experimental(red) n=7')
% %xlim([1 20])
% xlim([1 10])
% ylim([0 7])
% set(gca,'fontsize',12)

figure()
valanticip=[alltrial_anticipJoystick5; alltrial_anticipJoystick6];
plot((1:1:40),valanticip,'LineWidth',0.5)
hold on
plot((1:1:40),mean(valanticip'),'-b','LineWidth',4)
xlabel('Trial Number')
ylabel('Percentage (%)')
title('Percentage of Anticipatory Points in Joystick Dataset')
set(gca,'FontSize', 14)
% 
% subplot(1,3,3)
% a=plot((1:5),mean(blockmeanveljoystick5),'+-c','LineWidth',4)
% hold on
% b=plot((6:10),mean(blockmeanveljoystick6),'+-m','LineWidth',4)
% plot((1:5),blockmeanveljoystick5','.-c','LineWidth',0.5)
% plot((6:10),blockmeanveljoystick6','.-m','LineWidth',0.5)
% legend([a b],{'Day 1', 'Day 2'});
% xlabel('Block Number')
% ylabel('Joystick Velocity')
% title('Average Velocity of Joystick Data Points')
% xlim([1 10])
% %subtitle('Day2: Control(blue) vs Experimental(red) n=7')
% %xlim([1 20])
% %ylim([0 0.25])
% set(gca,'fontsize',12)

figure()
valmeanveljoy=[alltrial_meanVelJoystick5; alltrial_meanVelJoystick6];
plot((1:1:40),valmeanveljoy,'LineWidth',0.5)
hold on
plot((1:1:40),mean(valmeanveljoy'),'-b','LineWidth',4)
xlabel('Trial Number')
ylabel('Joystick Velocity (deg/s)')
title('Average Velocity of Joystick Data Points')
set(gca,'FontSize', 14)

% figure()
% subplot(1,2,1)
% plot((1:5),blockmeanvelmovements5','.-c','LineWidth',0.5)
% hold on
% plot((6:10),blockmeanvelmovements6','.-m','LineWidth',0.5)
% a=plot((1:5),mean(blockmeanvelmovements5),'+-c','LineWidth',4)
% b=plot((6:10),mean(blockmeanvelmovements6),'+-m','LineWidth',4)
% legend([a b],{'Day 1','Day 2'})
% xlabel('Block Number')
% ylabel('Joystick Velocity')
% title('Average Velocity of Joystick Movements')
% xlim([1 10])
% %subtitle('Day2: Control(blue) vs Experimental(red) n=7')
% %xlim([1 20])
% %ylim([0 0.25])
% set(gca,'fontsize',12)
% 
% subplot(1,2,2)
% a=plot((1:5),mean(blockmeananticipatoryphaseangle5),'+-c','LineWidth',4)
% hold on
% b=plot((6:10),mean(blockmeananticipatoryphaseangle6),'+-m','LineWidth',4)
% plot((1:5),blockmeananticipatoryphaseangle5','.-c','LineWidth',0.5)
% plot((6:10),blockmeananticipatoryphaseangle6','.-m','LineWidth',0.5)
% legend([a b],{'Day 1', 'Day 2'});
% xlabel('Block Number')
% ylabel('Velocity')
% title('Average Phase Angles of Anticipatory Joystick')
% xlim([1 10])
% %subtitle('Day2: Control(blue) vs Experimental(red) n=7')
% %xlim([1 20])
% %ylim([0 0.25])
% set(gca,'fontsize',12)
% 
% figure()
% subplot(1,2,1)
% plot((1:5),blockdestabjoystickmoves5','.-c','LineWidth',0.5)
% hold on
% plot((6:10),blockdestabjoystickmoves6','.-m','LineWidth',0.5)
% a=plot((1:5),mean(blockdestabjoystickmoves5),'+-c','LineWidth',4)
% b=plot((6:10),mean(blockdestabjoystickmoves6),'+-m','LineWidth',4)
% legend([a b],{'Day 1','Day 2'})
% xlabel('Block Number')
% ylabel('Percentage')
% title('Percentage of Destabilizing Joystick Movements')
% xlim([1 10])
% %subtitle('Day2: Control(blue) vs Experimental(red) n=7')
% %xlim([1 20])
% %ylim([0 0.25])
% set(gca,'fontsize',12)
% % 
% 
% subplot(1,2,2)
% plot((1:5),blockanticipjoystickmoves5','.-c','LineWidth',0.5)
% hold on
% plot((6:10),blockanticipjoystickmoves6','.-m','LineWidth',0.5)
% a=plot((1:5),mean(blockanticipjoystickmoves5),'+-c','LineWidth',4)
% b=plot((6:10),mean(blockanticipjoystickmoves6),'+-m','LineWidth',4)
% legend([a b],{'Day 1','Day 2'})
% xlabel('Block Number')
% ylabel('Percentage')
% title('Percentage of Anticipatory Joystick Movements')
% xlim([1 10])
% %subtitle('Day2: Control(blue) vs Experimental(red) n=7')
% %xlim([1 20])
% %ylim([0 0.25])
% set(gca,'fontsize',12)
% % 
% 
% 
% 
