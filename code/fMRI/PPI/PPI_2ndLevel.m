% Figure 5B
% 2nd-level  PPI analysis
clear all; clc;

%% Paths
FOLDER_ROI = 'PATH/TO/ROI/FILES';
allROIs = {'seed_striatum_cluster.nii'};
allConds = {'cue_wmgng_vs_gng'};

NAME_PPI = 'PPI';

%% data path
root_path = 'PATH/TO/GLM/RESULTS';
data_path = fullfile(root_path, NAME_PPI, 'gPPI', 'lev-1st'); % data (1st level SPM.mat) path. DO NOT PUT '/' IN THE END!
output_path = fullfile(root_path, NAME_PPI, 'gPPI', 'lev-2nd');  % output path

% subjects
subjIDs_name = {
   'sub-0004', 'sub-0006', 'sub-0011', 'sub-0014', 'sub-0025', 'sub-0028', 'sub-0037', 'sub-0039', 'sub-0044', ...
   'sub-0058', 'sub-0059', 'sub-0060', 'sub-0061', 'sub-0063', 'sub-0064', 'sub-0069', 'sub-0073', 'sub-0074', ...
   'sub-0076', 'sub-0079', 'sub-0086', 'sub-0091', 'sub-0094', 'sub-0095', 'sub-0099', 'sub-0101', 'sub-0102', ...
   'sub-0103', 'sub-0104', 'sub-0105', 'sub-0107', 'sub-0108', 'sub-0109', 'sub-0110', 'sub-0111', 'sub-0112', ...
   'sub-0118', 'sub-0119', 'sub-0121', 'sub-0122', 'sub-0123', 'sub-0125', 'sub-0126', 'sub-0127'
   }

numSubjs = length(subjIDs_name);  % this will be replaced with newly selected subjects...
%% Covariates
cov = readtable('PATH/TO/COVARIATES.csv', 'ReadVariableNames', true);
cov = sortrows(cov, 'subject');

%get table based on subjID
strSubjID = string(subjIDs_name); %make subjIDs_name to string array
cov.Properties.RowNames = cov.subject; %assign subject column as rownames
covtable = cov(strSubjID, :); %get table we need.

% Check number of subjects
[nrows, ncols] = size(covtable);
if nrows ~= length(subjIDs_name)
    error('Number of subjects does not match.')
end

%convert strings to 1 or 0
covtable.sex = categorical(covtable.sex);
covtable.sex = (covtable.sex == 'M');

%% Initialise SPM defaults
spm('Defaults','fMRI');
spm_jobman('initcfg'); % SPM8 only

%% Run codes
for i = 1:length(allROIs)
    
    ROI = allROIs{i};
    roi_name = strsplit(ROI, '.');
    
    for r = 1:length(allConds)
      
        % contrast number
        cond = allConds{r};
        contrast_num = sprintf('%04d', r); 
        dir_name = [cond '_N' num2str(numSubjs)];


        %% specification
        matlabbatch = [];
        mkdir( fullfile(output_path, roi_name{1}, dir_name) )
        scanFiles = [];
        c = 0;
        for j = 1:numSubjs
            SUBJ = subjIDs_name{j};
            if exist( fullfile(data_path, SUBJ, 'result', ['PPI_', roi_name{1}], ['/con_', contrast_num, '.nii'] ))
                c = c + 1;
                tmp_scanFile1 = fullfile(data_path, SUBJ, 'result', ['PPI_', roi_name{1}], ['/con_', contrast_num, '.nii,1']);  % if using subjIDs_name
                scanFiles{c,1} = tmp_scanFile1;
            else
                disp([SUBJ, 'contrast not exist'])
            end
        end

        matlabbatch{1}.spm.stats.factorial_design.dir = { fullfile(output_path, roi_name{1}, dir_name) };
        matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = scanFiles;
        
        matlabbatch{1}.spm.stats.factorial_design.cov(1).c = double(covtable.age);
        matlabbatch{1}.spm.stats.factorial_design.cov(1).cname = 'age';
        matlabbatch{1}.spm.stats.factorial_design.cov(1).iCC = 1;

        matlabbatch{1}.spm.stats.factorial_design.cov(2).c = double(covtable.sex);
        matlabbatch{1}.spm.stats.factorial_design.cov(2).cname = 'sex';
        matlabbatch{1}.spm.stats.factorial_design.cov(2).iCC = 1;

        matlabbatch{1}.spm.stats.factorial_design.cov(3).c = double(covtable.easy_to_hard);
        matlabbatch{1}.spm.stats.factorial_design.cov(3).cname = 'easy_to_hard';
        matlabbatch{1}.spm.stats.factorial_design.cov(3).iCC = 1;


        matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
        matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
        matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
        matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
        matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
        matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

        if exist(fullfile(output_path, roi_name{1}, dir_name, 'SPM.mat'))
            fprintf('\n SPM.mat exists in this directory. Overwriting SPM.mat file! \n\n')
            delete(fullfile(output_path, roi_name{1}, dir_name, 'SPM.mat'))
        end

        spm_jobman('run', matlabbatch)
        disp(['2nd Level ' NAME_PPI ' model is specified']);

        %% estimation
        matlabbatch = [];
        matlabbatch{1}.spm.stats.fmri_est.spmmat = { fullfile(output_path,roi_name{1}, dir_name, 'SPM.mat') };
        matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
        spm_jobman('run', matlabbatch)

        %% T-contrast (one-step t-test)
        matlabbatch = [];
        matlabbatch{1}.spm.stats.con.spmmat = { fullfile(output_path, roi_name{1}, dir_name, 'SPM.mat') };
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = dir_name;
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.convec = 1;
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.delete = 1;
        spm_jobman('run', matlabbatch)

        disp( [dir_name ' contrast is created'])
    end
end

% end of code

