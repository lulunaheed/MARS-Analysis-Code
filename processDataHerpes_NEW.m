function [] = processDataHerpes_NEW(programMode, instructionType, protocolFolder, foldersToProcess, outputFolderF, joystickButtonMandatory, savePlots, tDataInclusion, chairFacingWall )

clear data statsData summaryData combinedSummaryData combinedStatsData combinedSRCorrelationStats strParticipant;
close all;

%%%% added by me
otherplotswant=0;
wantfit=0;
wantalldays=0;
blocksize=4;  %1 block = 4 trials.
numberofblocks=5;
wantdiffusionherpes=1;
wantstd=1;
featherversion2=1;
wantProbBarGraphs=0;  %gives 20 bar graphs, one for each trial, showing prob of mistakes
wantblockstd=1;  %if you want a graph for the average std by block
wantdiffusionanalysisgraphs=0; %this gives the graphs for the coefficents for diffusion analysis
vivek=3; %1= UprightUpright 2=UprightBack  3= BackBack  4=BackUpright
viveksave=1;  %if ==1, then save the whole thang
wantsinglesdate=0;  %per-participant summaries with all trials
wantsinglesdateblock=0; %perparticipant by block
%%%%

outputFolder = [outputFolderF filesep];
ensureFolderExists(outputFolder);

csvFolder = [outputFolder filesep 'csv' filesep];
ensureFolderExists(csvFolder);

global debug data dataIndices protocol protocolIndices strParticipant outFolder;
global summaryData histogramBinCenters saveFile combinedSRCorrelationStatsPearson combinedSRCorrelationStatsSpearman statsData combinedStatsData combinedSummaryData doGaussianFitting;

numberSubjects = size(foldersToProcess, 2);
outFolder = outputFolder;

disp([mfilename ': Program mode: ' num2str(programMode)]);
disp([mfilename ': Instruction type: ' num2str(instructionType)]);

inclusionStr = 'All since last time participant lost control';
if(tDataInclusion ~= 0 )
    inclusionStr = ['Last ' num2str(tDataInclusion) ' sec'];
end
disp([mfilename ': Trial data to analyze: ' inclusionStr]);
disp([mfilename ': Output folder: ' outputFolder]);
disp([mfilename ': Number of participants: ' num2str(numberSubjects)]);
joystickStr = 'Yes';
if(joystickButtonMandatory==false)
    joystickStr = 'No';
end
disp([mfilename ': Joystick button press mandatory: ' joystickStr]);

histogramBinCenters = -90:1:90;
interSum=0;
interNum=0;

% process all specified data folders --------------------------------------
for participantCounter = 1 : numberSubjects
    %     close all;
    
    % determine participant data folder, and identifier
    participantDataFolder = [char(foldersToProcess(participantCounter)) filesep];
    
    strParticipant= char(foldersToProcess(participantCounter));
    strParticipant= strParticipant(1+max(findstr(char(foldersToProcess(participantCounter)), filesep)) : end) ;
    disp([mfilename ': Processing participant ' num2str(participantCounter) ', ' strParticipant ]);
    
    participantProtocolFolder = [protocolFolder filesep strParticipant filesep];
    
    % read participant protocols ------------------------------------------
    list_files = dir([participantProtocolFolder filesep '*.csv']);
    %dir goes and finds all the files in participantProtocolFolder and then
    %makes a structure out of it.
    protocol = [];
    day=[];
    human=[];
    
    day=str2num(strParticipant(1));
%     if (strParticipant(end-1)=='P')
%         human=str2num(strParticipant(end));
%     else
%         human=str2num(strParticipant(end))+10;
%     end

if (strParticipant(end-1)=='P')
        human=str2num(strParticipant(end));
    else if (strParticipant(end-1)=='1')
        human=str2num(strParticipant(end))+10;
    else
        human=20;
    end
end
    
    disp([mfilename ': Found ' num2str(size(list_files, 1)) ' protocol(s) in folder: ' participantProtocolFolder]);
    
    for index = 1 : size(list_files, 1)
        %size(list_files,1) finds the number of entries in 'name' which is
        %the number of trials.
        protocolFile = [participantProtocolFolder filesep list_files(index).name];
        %        disp([mfilename ': Reading protocol: ' num2str(index) ', file: ' list_files(index).name]);
        [tmpProtocol protocolIndices] = readProtocol(protocolFile, featherversion2);
        if(chairFacingWall == true)
            for dobConversionIndex = 1:size(tmpProtocol, 1)
                actualDobRoll = tmpProtocol{dobConversionIndex, protocolIndices.indexDOBRoll};
                newDobRoll = actualDobRoll - 180;
                
                actualDobPitch = tmpProtocol{dobConversionIndex, protocolIndices.indexDOBPitch};
                newDobPitch = actualDobPitch - 180;
                
                disp([mfilename ': converting protocol ' list_files(index).name ' DOB of trial number ' num2str(tmpProtocol{dobConversionIndex, protocolIndices.indexTrialNumber}) ' Roll from ' num2str(actualDobRoll) ' to ' num2str(newDobRoll) ' Pitch from ' num2str(actualDobPitch) ' to ' num2str(newDobPitch) ]);
                
                tmpProtocol{dobConversionIndex, protocolIndices.indexDOBRoll} = newDobRoll;
                tmpProtocol{dobConversionIndex, protocolIndices.indexDOBPitch} = newDobPitch;
            end
        end
        protocol = [protocol; tmpProtocol];
    end
    
    % read data and protocol --------------------------------------------------
    [data dataIndices] = readHulkamaniaData(participantDataFolder, chairFacingWall, featherversion2);
    
    
    % Figure out what to do with the data ---------------------------------
    if(size(data, 1) > 0)
        switch programMode
            case {1 4}
                %if programMode is equal to either 1 or 4
                if(programMode == 1)
                    % show the trial inspection ui
                    plotTrialData(1, 0, tDataInclusion);
                    showTrialInspectionUI(size(data,1), tDataInclusion);
                else
                    % plot & save individual trials
                    for index = 1 : size(data,1)
                        plotTrialData(index, 1, tDataInclusion);
                    end
                end;
                
            case {2 5 9}
                saveFile = savePlots;
                
                % create per-participant summary data
                [statsData summaryData] = extractParticipantData(instructionType, strParticipant, histogramBinCenters, joystickButtonMandatory, tDataInclusion);
                if(saveFile == 1)
                    saveStatsDataToFile(strParticipant, csvFolder, statsData, instructionType);
                end
                
                %%%%added by me
                close all
                meanMARSAngle=[]; meanMARSVelocity=[]; meanMARSAcceleration=[];  stdMARSAngle=[];
                crashFrequency=[];  meanJoyMag=[];  stdJoyMag=[]; meanMagnitudeMARSAngle=[]; stdRate=[]; meanRateDistsV=[];meanDrifts=[]; stdDists=[]; driftPercent=[];
                intermitJoy=[]; destabJoystick=[];   anticipJoystick=[];   meanVelJoystick=[]; meanVelMovements= []; destabJoystickMoves= []; anticipJoystickMoves= []; MeanAnticipatoryPhaseAngle= []; startMoveMARSPosition= [];
                [meanMARSAngle,meanMARSVelocity,meanMARSAcceleration,stdMARSAngle,crashFrequency, meanMagnitudeMARSAngle,stdRate,meanRateDistsV,meanDrifts, stdDists, driftPercent, meanJoyMag,stdJoyMag,intermitJoy, destabJoystick,anticipJoystick, meanVelJoystick, meanVelMovements, destabJoystickMoves, anticipJoystickMoves, MeanAnticipatoryPhaseAngle, startMoveMARSPosition]=plotDOB(summaryData, strParticipant, outputFolder, histogramBinCenters, instructionType, saveFile, doGaussianFitting,human);
                
       
                
                if vivek==3 & day==1
                    alltrial_meanMARSAngle5(:,human)=meanMARSAngle;
                    alltrial_meanMARSVelocity5(:,human)=meanMARSVelocity;
                    alltrial_meanMARSAcceleration5(:,human)=meanMARSAcceleration;
                    alltrial_stdMARSAngle5(:,human)=stdMARSAngle;
                    alltrial_crashFrequency5(:,human)=crashFrequency;
                    alltrial_meanMagnitudeMARSAngle5(:,human)=meanMagnitudeMARSAngle;
                    alltrial_stdRate5(:,human)=stdRate;
                    alltrial_meanRateDistsV5(:,human)=meanRateDistsV;
                    alltrial_meanDrifts5(:,human)=meanDrifts;
                    alltrial_stdDists5(:,human)=stdDists;
                    alltrial_driftPercent5(:,human)=driftPercent;
                    alltrial_meanJoyMag5(:,human)=meanJoyMag;
                    alltrial_stdJoyMag5(:,human)=stdJoyMag;
                    alltrial_intermitJoy5(:,human)= intermitJoy;
                    alltrial_destabJoystick5(:,human)=destabJoystick;
                    alltrial_anticipJoystick5(:,human)= anticipJoystick;
                    alltrial_meanVelJoystick5(:,human)=meanVelJoystick;
                    
                    alltrial_meanVelMovements5(:,human)=meanVelMovements;
                    alltrial_destabJoystickMoves5(:,human)=destabJoystickMoves;
                    alltrial_anticipJoystickMoves5(:,human)=anticipJoystickMoves;
                    alltrial_MeanAnticipatoryPhaseAngle5(:,human)=MeanAnticipatoryPhaseAngle;
                    alltrial_startMoveMARSPosition5(:,human)=startMoveMARSPosition;
                end
                
                if vivek==3 & day==2
                   alltrial_meanMARSAngle6(:,human)=meanMARSAngle;
                    alltrial_meanMARSVelocity6(:,human)=meanMARSVelocity;
                    alltrial_meanMARSAcceleration6(:,human)=meanMARSAcceleration;
                    alltrial_stdMARSAngle6(:,human)=stdMARSAngle;
                    alltrial_crashFrequency6(:,human)=crashFrequency;
                    alltrial_meanMagnitudeMARSAngle6(:,human)=meanMagnitudeMARSAngle;
                    alltrial_stdRate6(:,human)=stdRate;
                    alltrial_meanRateDistsV6(:,human)=meanRateDistsV;
                    alltrial_meanDrifts6(:,human)=meanDrifts;
                    alltrial_stdDists6(:,human)=stdDists;
                    alltrial_driftPercent6(:,human)=driftPercent;
                    alltrial_meanJoyMag6(:,human)=meanJoyMag;
                    alltrial_stdJoyMag6(:,human)=stdJoyMag;
                    alltrial_intermitJoy6(:,human)= intermitJoy;
                    alltrial_destabJoystick6(:,human)=destabJoystick;
                    alltrial_anticipJoystick6(:,human)= anticipJoystick;
                    alltrial_meanVelJoystick6(:,human)=meanVelJoystick;
                    
                    alltrial_meanVelMovements6(:,human)=meanVelMovements;
                    alltrial_destabJoystickMoves6(:,human)=destabJoystickMoves;
                    alltrial_anticipJoystickMoves6(:,human)=anticipJoystickMoves;
                    alltrial_MeanAnticipatoryPhaseAngle6(:,human)=MeanAnticipatoryPhaseAngle;
                    alltrial_startMoveMARSPosition6(:,human)=startMoveMARSPosition;
                end
                
        
                
                if (otherplotswant==1)
                    plotDOBAngleAllSummary(summaryData, outputFolder, histogramBinCenters, instructionType, strParticipant, saveFile);
                    
                    plotDOBAngleAllBriefSummary(summaryData, outputFolder, strParticipant, instructionType, saveFile);
                    
                    plotDOBAngleAverageSummary(summaryData, outputFolder, histogramBinCenters, instructionType, strParticipant, saveFile);
                    plotDOBAngleAverageBriefSummary(summaryData, outputFolder, strParticipant, instructionType, saveFile);
                end
                
                % uncomment the following line to plot time series histogram for ALL
                % instruction types, rather than one
                %[dummyData summaryData] = extractParticipantData(-1, strParticipant, outputFolder, saveFile);
                
                if (otherplotswant==1)
                    
                    plotTimeSeriesHist(summaryData, true, outputFolder, strParticipant, saveFile);
                    plotTimeSeriesHist(summaryData, false, outputFolder, strParticipant, saveFile);
                end
                
            case {3 6}
                saveFile=0;
                if(programMode == 6)
                    saveFile=1;
                end;
                % create per-participant summary data
                [statsData summaryData] = extractParticipantData(instructionType, strParticipant, histogramBinCenters, joystickButtonMandatory, tDataInclusion);
                
                % merge data from all participants
                if(participantCounter==1)
                    combinedSummaryData = summaryData;
                    combinedStatsData = statsData;
                else
                    allDOBs = unique(cell2mat(protocol(1:end, protocolIndices.indexDOBRoll)));
                    
                    for sIndex = 1:size(summaryData, 1)
                        DOBRoll = summaryData{sIndex}.DOBRoll;
                        dobIndex = find(allDOBs == DOBRoll);
                        
                        combinedSummaryData{dobIndex}.Participant = horzcat(combinedSummaryData{dobIndex}.Participant, summaryData{dobIndex}.Participant);
                        combinedSummaryData{dobIndex}.RollAngleAverage = [combinedSummaryData{dobIndex}.RollAngleAverage summaryData{dobIndex}.RollAngleAverage];
                        combinedSummaryData{dobIndex}.RollAngleMode = [combinedSummaryData{dobIndex}.RollAngleAverage summaryData{dobIndex}.RollAngleMode];
                        combinedSummaryData{dobIndex}.JoyBtnDownAngleAverage = [combinedSummaryData{dobIndex}.JoyBtnDownAngleAverage summaryData{dobIndex}.JoyBtnDownAngleAverage];
                        combinedSummaryData{dobIndex}.JoyBtnDownAngleMode = [combinedSummaryData{dobIndex}.JoyBtnDownAngleAverage summaryData{dobIndex}.JoyBtnDownAngleMode];
                        combinedSummaryData{dobIndex}.TrialNumbers = [combinedSummaryData{dobIndex}.TrialNumbers summaryData{dobIndex}.TrialNumbers];
                        combinedSummaryData{dobIndex}.JoyBtnDownAngles = [combinedSummaryData{dobIndex}.JoyBtnDownAngles summaryData{dobIndex}.JoyBtnDownAngles];
                        combinedSummaryData{dobIndex}.Trials = [combinedSummaryData{dobIndex}.Trials summaryData{dobIndex}.Trials];
                    end
                    
                    combinedStatsData  = [combinedStatsData; statsData];
                    
                end
                
                
        end
        
    end
    
   disp('Finished!') 
end

if viveksave==1 & vivek==1
    save upright
end
% 
% if viveksave==1 & vivek==2
%     save back
% end
% 
% if viveksave==1 & vivek==3
%     save backback
% end
% 
% 
% if wantalldays==1
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     ISI
%     alltrial_power2collector(:,~any(alltrial_power2collector))=[];   %removes all columns that are all zeros
%     figure()
%     subplot(2,1,1)
%     plot(alltrial_power2collector,'.-')
%     hold on
%     %      plot(mean(alltrial_power2collector,2),'+-k','LineWidth',3)
%     errorbar(1:20,mean(alltrial_power2collector,2),std(alltrial_power2collector,0,2),'+-k','LineWidth',3)
%     title('Frequency from ISI')
%     xlabel('trial number')
%     ylabel('frequency (hz)')
%     xlim([0.5 20.5])
%     
%     ppp=[];
%     for hh=1:20
%         xvm=[]; yvm=[]; h=[]; p=[]; ci=[]; stats=[];
%         xvm=alltrial_power2collector(1,:);
%         yvm=alltrial_power2collector(hh,:);
%         [h p ci stats]=ttest(xvm,yvm);
%         ppp(hh)=p;
%     end
%     subplot(2,1,2)
%     plot(ppp,'.-')
%     hold on
%     plot(1:.01:20,.05,'-r')
%     title('p-values')
%     %%%%%%%%%%%%%%    ISI by block
%     blockisi=[];
%     bbcounter=1;
%     for bb=1:numberofblocks
%         blockisi(:,bb)=mean(alltrial_power2collector(bbcounter:bbcounter+3,:));
%         bbcounter=bbcounter+4;
%     end
%     
%     figure()
%     subplot(2,1,1)
%     plot(blockisi')
%     hold on
%     errorbar(1:5,mean(blockisi),std(blockisi),'+-k','LineWidth',3)
%     title('Frequency from ISI')
%     xlabel('trial number')
%     ylabel('frequency (hz)')
%     xlim([0.5 5.5])
%     
%     ppp=[];
%     for hh=1:5
%         xvm=[]; yvm=[]; h=[]; p=[]; ci=[]; stats=[];
%         xvm=blockisi(:,1);
%         yvm=blockisi(:,hh);
%         [h p ci stats]=ttest(xvm,yvm);
%         ppp(hh)=p;
%     end
%     subplot(2,1,2)
%     plot(ppp,'.-')
%     hold on
%     plot(1:.01:5,.05,'-r')
%     title('p-values')
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     ISI FOR ANGLE
%     alltrial_power3collector(:,~any(alltrial_power3collector))=[];   %removes all columns that are all zeros
%     figure()
%     subplot(2,1,1)
%     plot(alltrial_power3collector,'.-')
%     hold on
%     %      plot(mean(alltrial_power2collector,2),'+-k','LineWidth',3)
%     errorbar(1:20,mean(alltrial_power3collector,2),std(alltrial_power3collector,0,2),'+-k','LineWidth',3)
%     title('Frequency from ISI')
%     xlabel('trial number')
%     ylabel('frequency (hz)')
%     xlim([0.5 20.5])
%     
%     ppp=[];
%     for hh=1:20
%         xvm=[]; yvm=[]; h=[]; p=[]; ci=[]; stats=[];
%         xvm=alltrial_power3collector(1,:);
%         yvm=alltrial_power3collector(hh,:);
%         [h p ci stats]=ttest(xvm,yvm);
%         ppp(hh)=p;
%     end
%     subplot(2,1,2)
%     plot(ppp,'.-')
%     hold on
%     plot(1:.01:20,.05,'-r')
%     title('p-values')
%     %%%%%%%%%%%%%%    ISI by block  FOR ANGLE
%     blockisi3=[];
%     bbcounter=1;
%     for bb=1:numberofblocks
%         blockisi3(:,bb)=mean(alltrial_power3collector(bbcounter:bbcounter+3,:));
%         bbcounter=bbcounter+4;
%     end
%     
%     figure()
%     subplot(2,1,1)
%     plot(blockisi3')
%     hold on
%     errorbar(1:5,mean(blockisi3),std(blockisi3),'+-k','LineWidth',3)
%     title('Frequency from ISI')
%     xlabel('trial number')
%     ylabel('frequency (hz)')
%     xlim([0.5 5.5])
%     
%     ppp=[];
%     for hh=1:5
%         xvm=[]; yvm=[]; h=[]; p=[]; ci=[]; stats=[];
%         xvm=blockisi3(:,1);
%         yvm=blockisi3(:,hh);
%         [h p ci stats]=ttest(xvm,yvm);
%         ppp(hh)=p;
%     end
%     subplot(2,1,2)
%     plot(ppp,'.-')
%     hold on
%     plot(1:.01:5,.05,'-r')
%     title('p-values')
%     
%     % poly2statsman(alltrial_power2collector,'ISI',[0.5 20.5],[0 2.5])
%     % exp2statsman(alltrial_power2collector,'ISI',[0.5 20.5],[0 2.5])
%     % exp2statsman(blockisi','block ISI',[0.5 5.5],[0 2.5])
%     % poly2statsman(blockisi','block ISI',[0.5 5.5],[0 2.5])
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    AREA
%     alltrial_areaman(:,~any(alltrial_areaman))=[];
%     figure()
%     subplot(2,1,1)
%     plot(alltrial_areaman,'.-')
%     hold on
%     %      plot(mean(alltrial_areaman,2),'+-k','LineWidth',3)
%     errorbar(1:20,mean(alltrial_areaman,2),std(alltrial_areaman,0,2),'+-k','LineWidth',3)
%     title('Area underneath joystick')
%     xlabel('trial number')
%     xlim([0.5 20.5])
%     
%     ppp=[];
%     for hh=1:20
%         xvm=[]; yvm=[]; h=[]; p=[]; ci=[]; stats=[];
%         xvm=alltrial_areaman(1,:);
%         yvm=alltrial_areaman(hh,:);
%         [h p ci stats]=ttest(xvm,yvm);
%         ppp(hh)=p;
%     end
%     subplot(2,1,2)
%     plot(ppp,'.-')
%     hold on
%     plot(1:.01:20,.05,'-r')
%     title('p-values')
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   STD
%     
%     
%     alltrial_meanMARSVelocity(:,~any(alltrial_meanMARSVelocity))=[];
%     x=[]; y=[];
%     figure()
%     subplot(2,1,1)
%     plot(alltrial_meanMARSVelocity,'.-')
%     hold on
%     %     plot(mean(alltrial_meanMARSVelocity,2),'+-k','LineWidth',3)
%     errorbar(1:20,mean(alltrial_meanMARSVelocity,2),std(alltrial_meanMARSVelocity,0,2),'+-k','LineWidth',3)
%     x=4.5*ones(1,21);
%     y=0:20;
%     plot(x,y, 'r')
%     
%     x=8.5*ones(1,21);
%     plot(x,y, 'r')
%     
%     x=12.5*ones(1,21);
%     plot(x,y, 'r')
%     
%     x=16.5*ones(1,21);
%     plot(x,y, 'r')
%     title('All participants std')
%     xlabel('trial number')
%     ylabel('std')
%     xlim([0.5 20.5])
%     
%     
%     ppp=[];
%     for hh=1:20
%         xvm=[]; yvm=[]; h=[]; p=[]; ci=[]; stats=[];
%         xvm=alltrial_meanMARSVelocity(1,:);
%         yvm=alltrial_meanMARSVelocity(hh,:);
%         [h p ci stats]=ttest(xvm,yvm);
%         ppp(hh)=p;
%     end
%     subplot(2,1,2)
%     plot(ppp,'.-')
%     hold on
%     plot(1:.01:20,.05,'-r')
%     title('p-values')
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     allblock_meanMARSAcceleration(:,:,any(~any(allblock_meanMARSAcceleration)))=[];
%     figure()
%     mrrogers=mean(allblock_meanMARSAcceleration,3);
%     timeisonmyside=(1:size(blockcorrdumpster,1))*.02;
%     plot(timeisonmyside,mrrogers)
%     title('Diffusion Stabilogram for all participants')
%     xlabel('rough time (sec)')
%     ylabel('mean-squared distance')
%     legend('block1','block2','block3','block4','block5')
%     
%     figure
%     loglog(timeisonmyside,mrrogers)
%     title('Diffusion Stabilogram averaged over All Participants')
%     xlabel('Time (sec)')
%     ylabel('mean-squared angle')
%     legend('block1','block2','block3','block4','block5')
%     
%     if wantdiffusionanalysisgraphs==1
%         for cblock=1:5
%             [cp_allblock(cblock) ds_allblock(cblock) dl_allblock(cblock) hs_allblock(cblock) hl_allblock(cblock)]=stabiloanal(mrrogers(:,cblock));
%             
%         end
%         figure()
%         subplot(5,1,1)
%         plot(cp_allblock,'.-')
%         title('cpfor all participants ')
%         subplot(5,1,2)
%         plot(ds_allblock,'.-')
%         title('ds for all participant ')
%         subplot(5,1,3)
%         plot(dl_allblock,'.-')
%         title('dl for participant ' )
%         subplot(5,1,4)
%         plot(hs_allblock,'.-')
%         title('hs for participant ')
%         subplot(5,1,5)
%         plot(hl_allblock,'.-')
%         title('hl for participant ')
%     end
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ANGLES
%     
%     alltrial_stdMARSAngle(:,~any(alltrial_stdMARSAngle))=[];
%     alltrial_crashFrequency(:,~any(alltrial_crashFrequency))=[];
%     totalanglemanz=[];
%     totalanglemanz=alltrial_stdMARSAngle+alltrial_stdMARSAngle;
%     
%     
%     figure()
%     subplot(2,1,1)
%     plot(totalanglemanz)
%     hold on
%     errorbar(1:20, mean(totalanglemanz,2),std(totalanglemanz,0,2),'+-k','LineWidth',3)
%     xlim([0.5 20.5])
%     title('All participants: When angle and joystickx have the same sign')
%     xlabel('trial number')
%     ylabel('percentage')
%     
%     ppp=[];
%     absbaby=[];
%     for hh=1:20
%         xvm=[]; yvm=[]; h=[]; p=[]; ci=[]; stats=[];
%         xvm=totalanglemanz(1,:);
%         yvm=totalanglemanz(hh,:);
%         [h p ci stats]=ttest(xvm,yvm);
%         ppp(hh)=p;
%         absbaby(:,hh)=ci;
%     end
%     subplot(2,1,2)
%     plot(ppp,'.-')
%     hold on
%     plot(1:.01:20,.05,'-r')
%     title('p-values')
%     
%     figure()
%     errorbar(1:20, mean(totalanglemanz,2),absbaby(1,:)',absbaby(2,:)','+-k','LineWidth',3)
%     
%     figure()
%     plot(alltrial_stdMARSAngle,'b.-')
%     hold on
%     plot(alltrial_crashFrequency,'r.-')
%     plot(mean(alltrial_stdMARSAngle,2),'+-b','LineWidth',3)
%     plot(mean(alltrial_crashFrequency,2),'+-r','LineWidth',3)
%     
%     %%%%%%%%%%%%%%%%  anglejoyvel
%     
%     alltrial_anglejoyvelbad(:,~any(alltrial_anglejoyvelbad))=[];
%     
%     figure()
%     subplot(2,1,1)
%     plot(alltrial_anglejoyvelbad)
%     hold on
%     errorbar(1:20, mean(alltrial_anglejoyvelbad,2),std(alltrial_anglejoyvelbad,0,2),'+-k','LineWidth',3)
%     xlim([0.5 20.5])
%     title('All participants: When angle and joystickx and velocity have the same sign')
%     xlabel('trial number')
%     ylabel('percentage')
%     
%     ppp=[];
%     for hh=1:20
%         xvm=[]; yvm=[]; h=[]; p=[]; ci=[]; stats=[];
%         xvm=alltrial_anglejoyvelbad(1,:);
%         yvm=alltrial_anglejoyvelbad(hh,:);
%         [h p ci stats]=ttest(xvm,yvm);
%         ppp(hh)=p;
%     end
%     subplot(2,1,2)
%     plot(ppp,'.-')
%     hold on
%     plot(1:.01:20,.05,'-r')
%     title('p-values')
%     %%%%%%%%%%%%%%%%
%     
%     alltrial_meanJoyMag(:,~any(alltrial_meanJoyMag))=[];
%     alltrial_stdJoyMag(:,~any(alltrial_stdJoyMag))=[];
%     totalanglemanx=[];
%     totalanglemanx=alltrial_meanJoyMag+alltrial_stdJoyMag;
%     
%     
%     figure()
%     subplot(2,1,1)
%     plot(totalanglemanx)
%     hold on
%     errorbar(1:20, mean(totalanglemanx,2),std(totalanglemanx,0,2),'+-k','LineWidth',3)
%     xlim([0.5 20.5])
%     title('All participants: When accel and joystickx have the same sign')
%     xlabel('trial number')
%     ylabel('percentage')
%     
%     ppp=[];
%     for hh=1:20
%         xvm=[]; yvm=[]; h=[]; p=[]; ci=[]; stats=[];
%         xvm=totalanglemanx(1,:);
%         yvm=totalanglemanx(hh,:);
%         [h p ci stats]=ttest(xvm,yvm);
%         ppp(hh)=p;
%     end
%     subplot(2,1,2)
%     plot(ppp,'.-')
%     hold on
%     plot(1:.01:20,.05,'-r')
%     title('p-values')
%     
%     
%     
%     figure()
%     plot(alltrial_meanJoyMag,'b.-')
%     hold on
%     
%     plot(alltrial_stdJoyMag,'r.-')
%     plot(mean(alltrial_meanJoyMag,2),'+-b','LineWidth',3)
%     plot(mean(alltrial_stdJoyMag,2),'+-r','LineWidth',3)
%     
%     title('All participants: When accel and angle have the same sign')
%     xlabel('trial number')
%     ylabel('percentage')
%     legend('both positive', 'both negative')
%     
%     blockiang=[];
%     bbcounter=1;
%     for bb=1:numberofblocks
%         blockiang(:,bb)=mean(totalanglemanx(bbcounter:bbcounter+3,:));
%         bbcounter=bbcounter+4;
%     end
%     
%     figure()
%     subplot(2,1,1)
%     plot(blockiang')
%     hold on
%     errorbar(1:5,mean(blockiang),std(blockiang),'+-k','LineWidth',3)
%     title('Accel and Angle have the same sign')
%     xlabel('trial number')
%     ylabel('frequency (hz)')
%     xlim([0.5 5.5])
%     
%     ppp=[];
%     for hh=1:5
%         xvm=[]; yvm=[]; h=[]; p=[]; ci=[]; stats=[];
%         xvm=blockiang(:,1);
%         yvm=blockiang(:,hh);
%         [h p ci stats]=ttest(xvm,yvm);
%         ppp(hh)=p;
%     end
%     subplot(2,1,2)
%     plot(ppp,'.-')
%     hold on
%     plot(1:.01:5,.05,'-r')
%     title('p-values')
%     
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%  JOYx and JOYy
%     alltrial_intermitJoy(:,~any(alltrial_intermitJoy))=[];
%     alltrial_destabJoystick(:,~any(alltrial_destabJoystick))=[];
%     
%     figure()
%     subplot(2,1,1)
%     plot(alltrial_intermitJoy,'b.-')
%     hold on
%     
%     plot(alltrial_destabJoystick,'r.-')
%     plot(mean(alltrial_intermitJoy,2),'+-b','LineWidth',3)
%     %     errorbar(1:20,mean(alltrial_intermitJoy,2),std(alltrial_intermitJoy,0,2))
%     plot(mean(alltrial_destabJoystick,2),'+-r','LineWidth',3)
%     title('All participants: Average absolute magnitude of Joyx(red) and Joyy(blue)')
%     xlabel('trial number')
%     
%     ppp=[];
%     for hh=1:20
%         xvm=[]; yvm=[]; h=[]; p=[]; ci=[]; stats=[];
%         xvm=alltrial_intermitJoy(1,:);
%         yvm=alltrial_intermitJoy(hh,:);
%         [h p ci stats]=ttest(xvm,yvm);
%         ppp(hh)=p;
%     end
%     ppp2=[];
%     for hh=1:20
%         xvm=[]; yvm=[]; h=[]; p=[]; ci=[]; stats=[];
%         xvm=alltrial_destabJoystick(1,:);
%         yvm=alltrial_destabJoystick(hh,:);
%         [h p ci stats]=ttest(xvm,yvm);
%         ppp2(hh)=p;
%     end
%     
%     subplot(2,1,2)
%     plot(ppp,'b.-')
%     hold on
%     plot(ppp2,'r.-')
%     plot(1:.01:20,.05,'-k')
%     title('p-values')
%     
%     %%%%%%
%     alltrial_anticipJoystick(:,~any(alltrial_anticipJoystick))=[];
%     alltrial_meanVelJoystick(:,~any(alltrial_meanVelJoystick))=[];
%     
%     figure()
%     plot(alltrial_anticipJoystick,'b.-')
%     hold on
%     
%     plot(alltrial_meanVelJoystick,'r.-')
%     plot(mean(alltrial_anticipJoystick,2),'+-b','LineWidth',3)
%     plot(mean(alltrial_meanVelJoystick,2),'+-r','LineWidth',3)
%     title('All participants: Average std of Joyy and Joyx')
%     xlabel('trial number')
%     legend('joyy','joyx')
%     
%     %%%%%
%     alltrial_intermittentpoopx(:,~any(alltrial_intermittentpoopx))=[];
%     alltrial_intermittentpoopy(:,~any(alltrial_intermittentpoopy))=[];
%     
%     figure()
%     subplot(2,1,1)
%     plot(alltrial_intermittentpoopx,'r.-')
%     hold on
%     plot(alltrial_intermittentpoopy,'b.-')
%     plot(mean(alltrial_intermittentpoopx,2),'+-r','LineWidth',3)
%     plot(mean(alltrial_intermittentpoopy,2),'+-b','LineWidth',3)
%     title('All participants: percentage of time with Joyx(red)and Joyy(blue) near zero')
%     xlabel('trial number')
%     ylabel('percentage')
%     
%     ppp=[];
%     for hh=1:20
%         xvm=[]; yvm=[]; h=[]; p=[]; ci=[]; stats=[];
%         xvm=alltrial_intermittentpoopy(1,:);
%         yvm=alltrial_intermittentpoopy(hh,:);
%         [h p ci stats]=ttest(xvm,yvm);
%         ppp(hh)=p;
%     end
%     ppp2=[];
%     for hh=1:20
%         xvm=[]; yvm=[]; h=[]; p=[]; ci=[]; stats=[];
%         xvm=alltrial_intermittentpoopx(1,:);
%         yvm=alltrial_intermittentpoopx(hh,:);
%         [h p ci stats]=ttest(xvm,yvm);
%         ppp2(hh)=p;
%     end
%     
%     subplot(2,1,2)
%     plot(ppp,'b.-')
%     hold on
%     plot(ppp2,'r.-')
%     plot(1:.01:20,.05,'-k')
%     title('p-values')
%     
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%crashes
%     figure()
%     subplot(2,1,1)
%     % errorbar(1:20,mean(alltrial_freakcollector,2),std(alltrial_freakcollector,0,2))
%     plot(mean(alltrial_freakcollector,2),'.-')
%     hold on
%     plot(mean(alltrial_mistaketocrash,2),'kx-')
%     plot(mean(alltrial_crashcollector,2),'.-r')
%     xlim([0.5 20.5])
%     title('All participant averages')
%     xlabel('trial num')
%     legend('mistakes','mistakes->crash','crash')
%     
%     ppp=[];
%     for hh=1:20
%         xvm=[]; yvm=[]; h=[]; p=[]; ci=[]; stats=[];
%         xvm=alltrial_freakcollector(1,:);
%         yvm=alltrial_freakcollector(hh,:);
%         [h p ci stats]=ttest(xvm,yvm);
%         ppp(hh)=p;
%     end
%     ppp2=[];
%     for hh=1:20
%         xvm=[]; yvm=[]; h=[]; p=[]; ci=[]; stats=[];
%         xvm=alltrial_mistaketocrash(1,:);
%         yvm=alltrial_mistaketocrash(hh,:);
%         [h p ci stats]=ttest(xvm,yvm);
%         ppp2(hh)=p;
%     end
%     ppp3=[];
%     for hh=1:20
%         xvm=[]; yvm=[]; h=[]; p=[]; ci=[]; stats=[];
%         xvm=alltrial_crashcollector(1,:);
%         yvm=alltrial_crashcollector(hh,:);
%         [h p ci stats]=ttest(xvm,yvm);
%         ppp3(hh)=p;
%     end
%     
%     subplot(2,1,2)
%     plot(ppp,'.-')
%     hold on
%     plot(ppp2,'kx-')
%     plot(ppp3,'.-r')
%     plot(1:.01:20,.05,'-r')
%     title('p-values for intermittancy')
%     
%     %%%%%%%%%%%%%%%%%%%%
%     blockmis=[];
%     bbcounter=1;
%     for bb=1:numberofblocks
%         blockmis(:,bb)=mean(alltrial_freakcollector(bbcounter:bbcounter+3,:));
%         bbcounter=bbcounter+4;
%     end
%     
%     figure()
%     subplot(2,1,1)
%     plot(blockmis')
%     hold on
%     errorbar(1:5,mean(blockmis),std(blockmis),'+-k','LineWidth',3)
%     title('mistakes in blocks')
%     xlabel('trial number')
%     
%     xlim([0.5 5.5])
%     
%     ppp=[];
%     for hh=1:5
%         xvm=[]; yvm=[]; h=[]; p=[]; ci=[]; stats=[];
%         xvm=blockmis(:,1);
%         yvm=blockmis(:,hh);
%         [h p ci stats]=ttest(xvm,yvm);
%         ppp(hh)=p;
%     end
%     subplot(2,1,2)
%     plot(ppp,'.-')
%     hold on
%     plot(1:.01:5,.05,'-r')
%     title('p-values')
%     
% end
% 
% if wantProbBarGraphs==1
%     astralprojection=sum(alltrial_destabJoystickMoves,3)./sum(alltrial_meanVelMovements,3);
%     dick=[-50:-50:-500,50:50:500]'.*.02;
%     figure()
%     
%     for(faintedflower=1:8)
%         subplot(2,4,faintedflower)
%         bar(dick,astralprojection(:,faintedflower))
%         set(gca,'XTick',[-500:50:500].*.02)
%         xlim([-15 15])
%         ylim([0 1])
%         title(['Trial# ', num2str(faintedflower)])
%     end
%     suptitle('All participants: SumOfMistakes/NumOfBlackouts')
%     xlabel('rough time(sec)')
%     
%     figure()
%     for(faintedflower=9:16)
%         subplot(2,4,faintedflower-8)
%         bar(dick,astralprojection(:,faintedflower))
%         set(gca,'XTick',[-500:50:500].*.02)
%         xlim([-15 15])
%         ylim([0 1])
%         title(['Trial# ', num2str(faintedflower)])
%     end
%     suptitle('All participants: SumOfMistakes/NumOfBlackouts')
%     xlabel('rough time(sec)')
%     
%     figure()
%     for(faintedflower=17:20)
%         subplot(1,4,faintedflower-16)
%         bar(dick,astralprojection(:,faintedflower))
%         set(gca,'XTick',[-500:50:500].*.02)
%         xlim([-15 15])
%         ylim([0 1])
%         title(['Trial# ', num2str(faintedflower)])
%     end
%     suptitle('All participants: SumOfMistakes/NumOfBlackouts')
%     xlabel('rough time(sec)')
% end
% 
% 
% %%%%
% 
% % print summary information to screen -------------------------------------
% switch programMode
%     case {3 6}
%         if (programMode == 6)
%             saveStatsDataToFile('ALL', csvFolder, combinedStatsData, instructionType);
%             calculatePerParticipantRegressions(combinedSummaryData, instructionType, joystickButtonMandatory, csvFolder, [outputFolder '# Summary plots - all participants']);
%         end;
%         
%         plotDOBAngleAverageSummary(combinedSummaryData, outputFolder, histogramBinCenters, instructionType, 'All', savePlots);
%         plotDOBAngleAverageBriefSummary(combinedSummaryData, outputFolder, 'All', instructionType, savePlots);
%         
%         %    plotEstimatedModes(combinedSummaryData, 'All', outputFolder, histogramBinCenters, instructionType, savePlots);
%         
%         plotDOBAngleAllSummary(combinedSummaryData, outputFolder, histogramBinCenters, instructionType, 'All', savePlots);
%         plotDOBAngleAllBriefSummary(combinedSummaryData, outputFolder, 'All', instructionType, savePlots);
% end
% 
% clear histogramBinCenters index saveFile;
% 

end



