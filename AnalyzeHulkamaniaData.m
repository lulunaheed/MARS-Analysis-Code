clear all;

wantmenu=0;
wantplots=0;

% Execute startup script --------------------------------------------------
currentpath = cd('..');
addpath(pwd);
startUp;
cd(currentpath);

% initialize main script options ------------------------------------------ 
global debug data dataIndices protocol protocolIndices strParticipant outFolder;
global summaryData histogramBinCenters saveFile combinedSRCorrelationStatsPearson combinedSRCorrelationStatsSpearman combinedSummaryData statsData combinedStatsData strParticipant doGaussianFitting; 

% initialize main script options ------------------------------------------ 
debug = false;              % this bypasses the GUI in favor of hardcoded script options (See below)

doGaussianFitting = false;  % fit gaussian mixture to the trial distribution
                            % !! WARNING !! this is a work in progress and
                            % may not work as expected

tDataInclusion = 0;    % time that specifies the amount of per-trial data to 
                        % be included for analysis. Use 0 to include all 45
                        % sec. Use 15 to include the last 15 sec, and so on
                        
if debug == false 
    [expDb expNames] = getConfiguredExperiments(outputRootFolder, dataRootFolder);
    experimentIndex = menu('Which experiment do you want to analyze?', expNames);
    disp([mfilename ': Analyzing experiment ' expDb{experimentIndex}.name]);
    joystickButtonMandatory = expDb{experimentIndex}.joystickButtonMandatory;
    instructionTypesToProcess = expDb{experimentIndex}.instructionTypesToProcess;
    chairFacingWall = expDb{experimentIndex}.chairFacingWall;
    outputFolder    = expDb{experimentIndex}.outputFolder;
    protocolFolder  = expDb{experimentIndex}.protocolFolder;
    resultFolder    = expDb{experimentIndex}.resultFolder;

    % Ask the user about what s/he wants to do
    % programMode = 1 --> preprocess raw data
    % programMode = 2 --> create per-participant summeries
    % programMode = 3 --> conduct main analysis
    % programMode = 4 --> 1+2+3 -- save all plots, for all instructiontypes
    % programMode = 5 --> 2+3 -- save all plots, for all instructiontypes
    % programMode = 6 --> 1 -- save all plots, for all instructiontypes
    % programMode = 7 --> 2 -- save all plots, for all instructiontypes
    % programMode = 8 --> 3 -- save all plots, for all instructiontypes
    
    programMode=2;
    if wantmenu==1
    menuOptions = { '1. Inspect raw data'; ...
                    '2. Inspect and create per-participant summaries'; ...
                    '3. Inspect and conduct main analysis'; ...
                    '4. 1+2+3 bulk plot generation'; ...
                    '5. 2+3 bulk plot generation'; ...
                    '6. 1 bulk plot generation'; ...
                    '7. 2 bulk plot generation'; ...
                    '8. 3 bulk plot generation'; ...
                    '9. The Vivek Delux';...
                  };
    programMode = menu('Program mode', menuOptions);
    end
 
    % instruction type to process
    instructionType = 0;
    if(programMode == 2 || programMode == 3)
        instructionType = menu('Instruction type', '1', '2', '3', '4');
    end
    
    % saveplots
    savePlots=0;
    if wantplots==1
    savePlots = menu('Save plots', 'Yes', 'No');
    end
    
    foldersToProcess =  uipickfiles('FilterSpec', resultFolder, 'out','ce', 'pro', 'Select folder(s) with participant data');
else
    
    % DEBUG - set some script options
    programMode = 8;
    savePlots = true;
    saveStats = false;
    instructionType = 1;
    
    % DEBUG - set some script options
    [expDb expNames] = getConfiguredExperiments(outputRootFolder, dataRootFolder);
    experimentIndex = 9;
    disp([mfilename ': Analyzing experiment ' expDb{experimentIndex}.name]);
    instructionTypesToProcess = expDb{experimentIndex}.instructionTypesToProcess;
    joystickButtonMandatory = expDb{experimentIndex}.joystickButtonMandatory;
    chairFacingWall = expDb{experimentIndex}.chairFacingWall;
    outputFolder    = expDb{experimentIndex}.outputFolder;
    protocolFolder  = expDb{experimentIndex}.protocolFolder;
    resultFolder    = expDb{experimentIndex}.resultFolder;
    
    % DEBUG - just include all participants
    foldersToProcess = {};

    tmp = dir([resultFolder]);
    tmpnum = size(tmp,1)-2;
    for index=1:tmpnum
        if(tmp(index+2).isdir==1)
            foldersToProcess(end+1) = cellstr([resultFolder '\' tmp(index+2).name]);
        end
    end;
    clear tmp tmpNum;
end

% -------------------------------------------------------------------------
% carry out the analysis that was requested
ensureFolderExists(outputFolder);

diary ([outputFolder filesep 'matlab_script_execution_diary.txt']);

switch programMode
    case 4
        % generate plots for every individual trial (parameter
        % instructionType is ignored)
        processData(4, 0, protocolFolder, foldersToProcess, outputFolder, joystickButtonMandatory, savePlots, tDataInclusion, chairFacingWall);

        % generate per-participant summaries for each instruction type
        for instructionIndex = 1 : size(instructionTypesToProcess, 2)
            processData(5, instructionTypesToProcess(instructionIndex), protocolFolder, foldersToProcess, outputFolder, joystickButtonMandatory, savePlots, tDataInclusion, chairFacingWall);
        end

        % generate final analyses for each instruction type
        for instructionIndex = 1 : size(instructionTypesToProcess, 2)
            processData(6, instructionTypesToProcess(instructionIndex), protocolFolder, foldersToProcess, outputFolder, joystickButtonMandatory, savePlots, tDataInclusion, chairFacingWall);
        end

    case 5
        % generate per-participant summaries for each instruction type
        for instructionIndex = 1 : size(instructionTypesToProcess, 2)
            processData(5, instructionTypesToProcess(instructionIndex), protocolFolder, foldersToProcess, outputFolder, joystickButtonMandatory, savePlots, tDataInclusion, chairFacingWall);
        end
 
        % generate final analyses for each instruction type
        for instructionIndex = 1 : size(instructionTypesToProcess, 2)
            processData(5, instructionTypesToProcess(instructionIndex), protocolFolder, foldersToProcess, outputFolder, joystickButtonMandatory, savePlots, tDataInclusion, chairFacingWall);
        end

    case 6
        % generate plots for every individual trial (parameter instructionType is ignored)
        processData(4, 0, protocolFolder, foldersToProcess, outputFolder, joystickButtonMandatory, savePlots, tDataInclusion, chairFacingWall);
        
    case 7
        % generate final analyses for each instruction type
        for instructionIndex = 1 : size(instructionTypesToProcess, 2)
            processData(5, instructionTypesToProcess(instructionIndex), protocolFolder, foldersToProcess, outputFolder, joystickButtonMandatory, savePlots, tDataInclusion, chairFacingWall);
        end

   case 8
        % generate final analyses for each instruction type
        for instructionIndex = 1 : size(instructionTypesToProcess, 2)
            processData(6, instructionTypesToProcess(instructionIndex), protocolFolder, foldersToProcess, outputFolder, joystickButtonMandatory, savePlots, tDataInclusion, chairFacingWall);
        end


    case {1 2 3}
        %processDataHerpes(programMode, instructionType, protocolFolder, foldersToProcess, outputFolder, joystickButtonMandatory, savePlots, tDataInclusion, chairFacingWall);
        processDataHerpes_NEW(programMode, instructionType, protocolFolder, foldersToProcess, outputFolder, joystickButtonMandatory, savePlots, tDataInclusion, chairFacingWall);
    case {9}
        processDataHerpes(programMode, instructionType, protocolFolder, foldersToProcess, outputFolder, joystickButtonMandatory, savePlots, tDataInclusion, chairFacingWall);

end

diary off;

disp('Done with analyzing Hulkamania data!');
  



