function [] = glm3_1stLevel_odd(ses)
% GLM 3 - model-based fMRI analysis using decision value 
% First-level analysis script
% This code is for the participants with odd ID who did GNG task -> WMGNG task

% Regressors 
% --- gng
% 1: Cue onsets
% 2: Decision values
% 3: Onset of target-Go
% 4: Onset of target-Nogo
% 5: win outcome
% 6: zero outcome
% 7: loss outcome
% 8: Wait

% --- wmgng
% 1: Cue onsets
%   2: Decision values
% 3: Onset of target-Go
% 4: Onset of target-Nogo
% 5: win outcome
% 6: zero outcome
% 7: loss outcome
% ____additional regressors related to N-back task
% 8: Onset of wm(n-back)_target-Resp
% 9: Onset of wm(n-back)_outcome
% 10 : Wait

addpath('PATH/TO/YOUR/SPM')
TR = 1.5;  % TR of the fMRI data
defThres = 0.2;   % default threshold for mthresh
stimDuration = 1;   % default stimulus duration 
currApproach = 'glm3/lev-1st'; % output path

[path_data ID] = fileparts(pwd); % get current file path and ID 
path_subj = fullfile(path_data, ID); % subject data path. 
path_img = fullfile(path_subj,'ses-1', 'func'); % where fMRI data exist

% path for mask
mask_path_gz = fullfile(path_subj, 'ses-1', 'anat', [ID '_' 'ses-1_run-1_space-MNI152NLin2009cAsym_desc-brain_mask.nii.gz']);
gunzip(mask_path_gz);
disp('A mask image is unzipped for SPM analysis')
mask_path = fullfile(path_subj, 'ses-1', 'anat', [ID '_' 'ses-1_run-1_space-MNI152NLin2009cAsym_desc-brain_mask.nii']);

disp( ['ID = ' ID ] );
disp( ['Approach = ' currApproach] );
disp( ['pwd = ' pwd ]);

%% Path containing data
% path for confounding factors
move_path_origin1 = fullfile(path_img, [ID '_ses-1','_task-gng_run-1_desc-confounds_timeseries.tsv'] ); 
move_path_origin2 = fullfile(path_img, [ID '_ses-1','_task-gng_run-2_desc-confounds_timeseries.tsv'] ); 
move_path_origin3 = fullfile(path_img, [ID '_ses-1','_task-wmgng_run-1_desc-confounds_timeseries.tsv'] ); 
move_path_origin4 = fullfile(path_img, [ID '_ses-1','_task-wmgng_run-2_desc-confounds_timeseries.tsv'] );

disp('movement path defined')
%% create "R" variable from movement_regressor matrix and save
% erase motion_loc_full = [motion_loc_path, '/motion_loc.csv']
% erase motion_loc = readtable(motion_loc_full,'ReadRowNames',true)
% gng_run1
[data1, header1, ] = tsvread(move_path_origin1);
trans_x = strmatch('trans_x', header1, 'exact');
trans_y = strmatch('trans_y', header1, 'exact');
trans_z = strmatch('trans_z', header1, 'exact');
rot_x = strmatch('rot_x', header1, 'exact');
rot_y = strmatch('rot_y', header1, 'exact');
rot_z = strmatch('rot_z', header1, 'exact');
R = data1(2:end,[trans_x,trans_y, trans_z,rot_x, rot_y, rot_z]);
tmpFileName = [path_img, filesep, 'movement_regressors_for_epi_01.mat'];
save(tmpFileName, 'R')
move_path_run1 = fullfile(path_img, 'movement_regressors_for_epi_01.mat');

% gng_run2
[data2, header2, ] = tsvread(move_path_origin2);
trans_x = strmatch('trans_x', header2, 'exact');
trans_y = strmatch('trans_y', header2, 'exact');
trans_z = strmatch('trans_z', header2, 'exact');
rot_x = strmatch('rot_x', header2, 'exact');
rot_y = strmatch('rot_y', header2, 'exact');
rot_z = strmatch('rot_z', header2, 'exact');
R = data2(2:end,[trans_x,trans_y, trans_z,rot_x, rot_y, rot_z]);
tmpFileName = [path_img, filesep, 'movement_regressors_for_epi_02.mat'];
save(tmpFileName, 'R')
move_path_run2 = fullfile(path_img, 'movement_regressors_for_epi_02.mat');

% wmgng_run1
[data3, header3, ] = tsvread(move_path_origin3);
trans_x = strmatch('trans_x', header3, 'exact');
trans_y = strmatch('trans_y', header3, 'exact');
trans_z = strmatch('trans_z', header3, 'exact');
rot_x = strmatch('rot_x', header3, 'exact');
rot_y = strmatch('rot_y', header3, 'exact');
rot_z = strmatch('rot_z', header3, 'exact');
R = data3(2:end,[trans_x,trans_y, trans_z,rot_x, rot_y, rot_z]);
tmpFileName = [path_img, filesep, 'movement_regressors_for_epi_03.mat'];
save(tmpFileName, 'R')
move_path_run3 = fullfile(path_img, 'movement_regressors_for_epi_03.mat');

% wmgng_run2
[data4, header4, ] = tsvread(move_path_origin4);
trans_x = strmatch('trans_x', header4, 'exact');
trans_y = strmatch('trans_y', header4, 'exact');
trans_z = strmatch('trans_z', header4, 'exact');
rot_x = strmatch('rot_x', header4, 'exact');
rot_y = strmatch('rot_y', header4, 'exact');
rot_z = strmatch('rot_z', header4, 'exact');
R = data4(2:end,[trans_x,trans_y, trans_z,rot_x, rot_y, rot_z]);
tmpFileName = [path_img, filesep, 'movement_regressors_for_epi_04.mat'];
save(tmpFileName, 'R')
move_path_run4 = fullfile(path_img, 'movement_regressors_for_epi_04.mat');

clear R

%% Load regressors (including model regressors)
event1 = tsvread( fullfile(path_img,[ID, '_ses-1','_task-gng_run-1_events.tsv'] ) );
event2 = tsvread( fullfile(path_img,[ID, '_ses-1','_task-gng_run-2_events.tsv'] ) );
event3 = tsvread( fullfile(path_img,[ID, '_ses-1','_task-wmgng_run-1_events.tsv'] ) );
event4 = tsvread( fullfile(path_img,[ID, '_ses-1','_task-wmgng_run-2_events.tsv'] ) );

disp('Runs 1-4 values loaded')

%% Initialise SPM defaults
spm('defaults', 'FMRI');
spm_jobman('initcfg'); % SPM12
%%
%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%-----------------------------------------------------------------------

% create a directory where data will be saved
save_path = fullfile('PATH/TO/SAVE/GLM/RESULTS', ID, 'ses-1', 'func');
if ~exist( save_path )
    mkdir( save_path )
    disp ( save_path )
end

% delete SPM.mat file if it exists already
if exist( fullfile( save_path, 'SPM.mat') )
    fprintf('\n SPM.mat exists in this directory. Overwriting SPM.mat file! \n\n')
    delete( fullfile( save_path, 'SPM.mat') )
end

matlabbatch = [];  % clear matlabbatch..

%% New model %% For all 4 runs
matlabbatch{1}.spm.stats.fmri_spec.dir = { fullfile( save_path ) };
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

%% gng 
% Add regressors for each run
for n_run = 1:2
    % select data
    if n_run == 1
        event = event1;
        move_path_run = move_path_run1;
    else
        event = event2;
        move_path_run = move_path_run2;
    end

    %% rescan files
    % load smoothed files
    tmpFiles = dir(fullfile(path_img, sprintf('ssub*task-gng_run-%d*preproc_bold.nii', n_run)));   % find the file
    tmpHdr = spm_vol( fullfile(path_img, tmpFiles.name) );
    f_list_length = size(tmpHdr, 1);  % number of 3d volumes
    scanFiles = [];
    for jx = 1:f_list_length
        scanFiles{jx,1} = [path_img '/' tmpFiles.name ',' num2str(jx) ] ; % add numbers in the end
    end
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).scans = scanFiles;    

    % add regressors
    % for onsets, use targetOnset(loc)
    targetGoLoc = find(event.struct.key_pressed ==1 );  
    targetNogoLoc = find(event.struct.key_pressed ==0 );  
    % for onsets, use outcomeOnset(loc)
    winLoc = find(event.struct.outcome > 0);  
    zeroLoc = find(event.struct.outcome == 0);  
    lossLoc = find(event.struct.outcome < 0);  

    %% DV
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(1).name = 'Cue_DV_W';
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(1).onset = event.struct.cueOnset; 
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(1).duration = event.struct.cueRT;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(1).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(1).pmod(1).name = 'DV'; 
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(1).pmod(1).param = event.struct.DV;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(1).pmod(1).poly = 1; 
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(1).orth = 0;
 
    %% targetGo
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(2).name = 'targetGoResp';
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(2).onset = [event.struct.targetOnset(targetGoLoc)];
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(2).duration = event.struct.rt(targetGoLoc);
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(2).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(2).orth = 0; 

    %% targetNoResp
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(3).name = 'targetNogoResp';
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(3).onset = [event.struct.targetOnset(targetNogoLoc)];
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(3).duration = stimDuration;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(3).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(3).orth = 0; 

    %% winOutcome
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(4).name = 'winOutcome';
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(4).onset = [event.struct.fbOnset(winLoc)];
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(4).duration = stimDuration;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(4).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(4).orth = 0; 

    %% zeroOutcome
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(5).name = 'zeroOutcome';
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(5).onset = [event.struct.fbOnset(zeroLoc)];
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(5).duration = stimDuration;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(5).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(5).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(5).orth = 0; 

    %% lossOutcome
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(6).name = 'lossOutcome';
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(6).onset = [event.struct.fbOnset(lossLoc)];
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(6).duration = stimDuration;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(6).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(6).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(6).orth = 0; 

    %% Wait
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(7).name = 'Wait';
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(7).onset = [event.struct.waitOnset];
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(7).duration = event.struct.waitdur;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(7).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(7).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(7).orth = 0; 

    %%
    % Remaining details...
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).multi_reg = {move_path_run};
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).hpf = 128;
end

%% wmgng
for n_run = 3:4

    % select data
    if n_run == 3
        event = event3;
        move_path_run = move_path_run3;
    else
        event = event4;
        move_path_run = move_path_run4;
    end
    
    %% rescan files
    % load smoothed files
    tmpFiles = dir(fullfile(path_img, sprintf('ssub*task-wmgng_run-%d*preproc_bold.nii', n_run-2)));   % find the file
    tmpHdr = spm_vol( fullfile(path_img, tmpFiles.name) );
    f_list_length = size(tmpHdr, 1);  % number of 3d volumes
    scanFiles = [];
    for jx = 1:f_list_length
        scanFiles{jx,1} = [path_img '/' tmpFiles.name ',' num2str(jx) ] ; % add numbers in the end
    end
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).scans = scanFiles;

    % add regressors
    % for onsets, use targetOnset(loc)
    targetGoLoc = find(event.struct.key_pressed == 1);  
    targetNogoLoc = find(event.struct.key_pressed == 0);  
    % for onsets, use outcomeOnset(loc)
    winLoc = find(event.struct.outcome > 0);  
    zeroLoc = find(event.struct.outcome == 0);  
    lossLoc = find(event.struct.outcome < 0);  

    %% DV
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(1).name = 'Cue_DV_W';
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(1).onset = event.struct.cueOnset; 
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(1).duration = event.struct.cueRT;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(1).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(1).pmod(1).name = 'DV';
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(1).pmod(1).param = event.struct.DV;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(1).pmod(1).poly = 1; 
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(1).orth = 0;
    
    %% targetGo
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(2).name = 'targetGoResp';
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(2).onset = [event.struct.targetOnset(targetGoLoc)];
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(2).duration = event.struct.rt(targetGoLoc);
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(2).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(2).orth = 0; 

    %% targetNoResp
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(3).name = 'targetNogoResp';
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(3).onset = [event.struct.targetOnset(targetNogoLoc)];
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(3).duration = stimDuration;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(3).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(3).orth = 0; 

    %% winOutcome
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(4).name = 'winOutcome';
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(4).onset = [event.struct.fbOnset(winLoc)];
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(4).duration = stimDuration;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(4).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(4).orth = 0; 

    %% zeroOutcome
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(5).name = 'zeroOutcome';
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(5).onset = [event.struct.fbOnset(zeroLoc)];
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(5).duration = stimDuration;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(5).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(5).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(5).orth = 0; 

    %% lossOutcome
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(6).name = 'lossOutcome';
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(6).onset = [event.struct.fbOnset(lossLoc)];
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(6).duration = stimDuration;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(6).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(6).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(6).orth = 0; 

    %% target_Resp
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(7).name = 'targetResp';
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(7).onset = [event.struct.nback_targetOnset];
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(7).duration = stimDuration;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(7).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(7).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(7).orth = 0; 

    %% wm_outcome
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(8).name = 'wm_outcome';
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(8).onset = [event.struct.nback_fbOnset];
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(8).duration = stimDuration;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(8).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(8).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(8).orth = 0; 
    
    %% Wait
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(9).name = 'Wait';
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(9).onset = [event.struct.waitOnset];
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(9).duration = event.struct.waitdur;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(9).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(9).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).cond(9).orth = 0; 

    %% Remaining details
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).multi_reg = {move_path_run};
    matlabbatch{1}.spm.stats.fmri_spec.sess(n_run).hpf = 128;
end


%% For all 4 runs %% check!
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.2;
matlabbatch{1}.spm.stats.fmri_spec.mask = {mask_path}; 
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

%% run parametric model specification
spm_jobman('run', matlabbatch) 
disp('parametric model is specified')

%% parametric model estimation
matlabbatch = [];
matlabbatch{1}.spm.stats.fmri_est.spmmat = { fullfile( save_path, 'SPM.mat') };
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
spm_jobman('run', matlabbatch) 
disp('parametric model is estimated')

%% create a contrast
conts = {};
matlabbatch = [];
matlabbatch{1}.spm.stats.con.spmmat = { fullfile(save_path, 'SPM.mat') };


% DV(Wchosen-Wunchosen) WMGNG-GNG
conts{1} = [0 1/2 0 0 0 0 0 0 0 0 0 0 0 0]; %for GNG runs
conts{2} = [0 1/2 0 0 0 0 0 0 0 0 0 0 0 0 0 0]; % for WMGNG runs
matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'DV_wmgng_vs_gng';  
matlabbatch{1}.spm.stats.con.consess{2}.tcon.convec = [-conts{1} -conts{1} conts{2} conts{2}];
matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.delete = 0; % after creating all contrasts

spm_jobman('run', matlabbatch) 
disp([currApproach ' model: contrasts are generated'])


%% Finish
clear all;  % clear workspace

% end of the code

