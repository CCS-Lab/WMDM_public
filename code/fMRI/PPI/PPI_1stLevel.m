function [] = PPI_1stLevel(FOLDER_1ST, FOLDER_OUTPUT, subjID, FOLDER_ROI, ROI_NAME,...
    justEstimatePPI, Tasks, Contrasts)
% Function for first-level PPI analysis
%% Initialize SPM
for roiIdx = 1:length(ROI_NAME)
    roiName = ROI_NAME{roiIdx};
    roiFile = fullfile(FOLDER_ROI, roiName);
    
    region_tmp = strsplit(roiName, '.');
    region = region_tmp{1};
    
    if exist(fullfile(FOLDER_OUTPUT, subjID, 'result',['PPI_' region]))
        rmdir(fullfile(FOLDER_OUTPUT, subjID, 'result',['PPI_' region]), 's')
    end
    %% SPM path
        
    P = [];
    P.subject= fullfile(FOLDER_OUTPUT, subjID, '/'); % name of the new SPM file
    if justEstimatePPI
        P.directory = FOLDER_OUTPUT;
    else
        P.directory = FOLDER_1ST; % path to the first-level spm.mat directory
    end
    
    P.VOI= roiFile; 
    P.Region = region;
    P.Estimate = 1;
    P.contrast = 0;
    P.extract = 'eig';
    P.Tasks = Tasks;  % condition (or task..)

    P.Weights=[];  % weight for each task (cond)
    P.analysis='psy';   
    P.method='cond';  % 'trad' or 'cond' (trad: traditional SPM PPI; cond: generalized context-dependent PPI)
    P.outdir = fullfile(FOLDER_OUTPUT, subjID, 'result');
    P.CompContrasts= 1;  % estimate any contrasts?
    P.Weighted = 0;  % weight tasks by number of trials
    P.SPMver = '12';
    %P.ConcatR = 0;
    %P.preservevarcorr = 0;
    P.equalroi = 0; % if 0, it allows unequal sized roi roi
    P.FLmask = 1; % if 1, allow rois to be trimmed y the 1st level mask
    
    %% Contrasts
    for i = 1:length(Contrasts)
        P.Contrasts(i).left = Contrasts(i).left;
        P.Contrasts(i).right = Contrasts(i).right;
        if ~isempty(Contrasts(i).Contrail)
            P.Contrasts(i).Contrail = Contrasts(i).Contrail;
        end
        P.Contrasts(i).STAT = 'T';
        P.Contrasts(i).Weighted = 0;
        P.Contrasts(i).MinEvents = 1;
        P.Contrasts(i).name = Contrasts(i).name;
    end
    
    %%
    PPPI(P)
    
end

