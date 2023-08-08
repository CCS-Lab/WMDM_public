% Figure 5B
% First-level PPI analysis
clear all; clc;

%% Paths

addpath(genpath('PATH/TO/YOUR/PPI_FUNCTION'))
addpath(genpath('PATH/TO/YOUR/SPM'))
addpath('PATH/TO/YOUR/GIT/project_WMDM_public/code/')
% PPI analysis requires the output of 1st level glm.
%directory containing previously estimated SPM files from univarate GLM
FOLDER_ROOT = 'PATH/TO/SAVE/GLM/RESULTS';
ANALYSIS = 'PPI';
GLM = 'glm';

% path for saving the PPI result
FOLDER_OUTPUT = fullfile(FOLDER_ROOT, ANALYSIS, 'gPPI/lev-1st');
if ~exist(FOLDER_OUTPUT)
    mkdir(FOLDER_OUTPUT);
end

FOLDER_ROI = 'PATH/TO/ROI/FILES';
ROI_NAME = {'seed_striatum_cluster.nii'};

%% PPI parameters
justEstimatePPI = 0;% 1 if estimating just PPI model. 0 if estimating whole SPM + PPI % not for editing.
Tasks = {'0' 'cue_onset', 'targetGoResp', 'targetNogoResp', 'feedback_onset', 'Wait', ...
    'cue_onset_wm', 'targetGoResp_wm', 'targetNogoResp_wm', 'feedback_onset_wm', 'Wait_wm', ...
    'targetResp', 'wm_outcome'};

% make contrasts
Contrasts(1).left = {'cue_onset_wm'};
Contrasts(1).right = {'cue_onset'};
Contrasts(1).Contrail = {};
Contrasts(1).name = 'cue_wmgng_vs_gng';

% subjects
subjIDs_name = {
   'sub-0004', 'sub-0006', 'sub-0011', 'sub-0014', 'sub-0025', 'sub-0028', 'sub-0037', 'sub-0039', 'sub-0044', ...
   'sub-0058', 'sub-0059', 'sub-0060', 'sub-0061', 'sub-0063', 'sub-0064', 'sub-0069', 'sub-0073', 'sub-0074', ...
   'sub-0076', 'sub-0079', 'sub-0086', 'sub-0091', 'sub-0094', 'sub-0095', 'sub-0099', 'sub-0101', 'sub-0102', ...
   'sub-0103', 'sub-0104', 'sub-0105', 'sub-0107', 'sub-0108', 'sub-0109', 'sub-0110', 'sub-0111', 'sub-0112', ...
   'sub-0118', 'sub-0119', 'sub-0121', 'sub-0122', 'sub-0123', 'sub-0125', 'sub-0126', 'sub-0127'
   }

%% 1st-level Analysis
for i = 1:length(subjIDs_name)
    % Subject ID
    subjID = subjIDs_name{i};
    FOLDER_1ST = fullfile(FOLDER_ROOT, ANALYSIS, GLM, 'lev-1st', subjID, 'ses-1', 'func');
    FOLDER_SUB = fullfile(FOLDER_OUTPUT, subjID);
    if ~exist(FOLDER_SUB)
        mkdir(FOLDER_SUB)
    end
    % 1st-level
    cd (FOLDER_SUB)
    PPI_1stLevel(FOLDER_1ST, FOLDER_OUTPUT, subjID, FOLDER_ROI, ROI_NAME, ...
        justEstimatePPI, Tasks, Contrasts) 
end

disp('==========1st-level gPPI analysis done for all subjects.==========');
