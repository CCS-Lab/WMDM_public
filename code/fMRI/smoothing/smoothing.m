function [] = smoothing(ses)
% Smoothing of preprocessed data by fMRIPrep
% run this code under each subject's parent folder
% e.g., ../sub-0004


smoothing = [8 8 8];  % smoothing 

[path_data ID] = fileparts(pwd); 
path_subj = fullfile(path_data, ID);

path_img = fullfile(path_subj, 'ses-1', 'func');

disp( ['ID = ' ID ] );
disp( ['pwd = ' pwd ]);

%% gunzip all preprocessed nii.gz files first
% find all relevant files first
gunzip(fullfile(path_img, 'sub-*task*gng*preproc_bold.nii.gz'));
disp('All functional image files are unzipped for SPM analysis')

%% Initialise SPM defaults 
spm('defaults', 'FMRI');
spm_jobman('initcfg'); % SPM12

%%
%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%-----------------------------------------------------------------------

% create a directory where data will be saved
%mkdir( fullfile( path_subj, currApproach) )

% delete SPM.mat file if it exists already
%if exist( fullfile( path_subj, currApproach, 'SPM.mat') )
%    fprintf('\n SPM.mat exists in this directory. Overwriting SPM.mat file! \n\n')
%    delete( fullfile( path_subj, currApproach, 'SPM.mat') )
%end


%% smooth files first...
% gng-run1
matlabbatch = [];  % clear matlabbatch..
tmpFiles = dir(fullfile(path_img, 'sub-*task-gng_run-1*preproc_bold.nii'));   % find the file
% Here lines differ for 3D vs. 4D %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is for 4D multiple files
% get herder information to read a 4D file
tmpHdr = spm_vol( fullfile(path_img, tmpFiles.name) );
f_list_length = size(tmpHdr, 1);  % number of 3d volumes
scanFiles = [];
for jx = 1:f_list_length
    scanFiles{jx,1} = [path_img '/' tmpFiles.name ',' num2str(jx) ] ; % add numbers in the end
    % End of difference for 3D vs. 4D %%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
matlabbatch{1}.spm.spatial.smooth.data = scanFiles;
matlabbatch{1}.spm.spatial.smooth.fwhm = smoothing;
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 's';
spm_jobman('run', matlabbatch) 
disp('gng run 1 smoothing is complete')

% gng-run2
matlabbatch = [];  % clear matlabbatch..
tmpFiles = dir(fullfile(path_img, 'sub-*task-gng_run-2*preproc_bold.nii'));   % find the file
% Here lines differ for 3D vs. 4D %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is for 4D multiple files
% get herder information to read a 4D file
tmpHdr = spm_vol( fullfile(path_img, tmpFiles.name) );
f_list_length = size(tmpHdr, 1);  % number of 3d volumes
scanFiles = [];
for jx = 1:f_list_length
    scanFiles{jx,1} = [path_img '/' tmpFiles.name ',' num2str(jx) ] ; % add numbers in the end
    % End of difference for 3D vs. 4D %%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
matlabbatch{1}.spm.spatial.smooth.data = scanFiles;
matlabbatch{1}.spm.spatial.smooth.fwhm = smoothing;
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 's';
spm_jobman('run', matlabbatch) 
disp('gng run 2 smoothing is complete')

% wmgng-run1
matlabbatch = [];  % clear matlabbatch..
tmpFiles = dir(fullfile(path_img, 'sub-*task-wmgng_run-1*preproc_bold.nii'));   % find the file
tmpHdr = spm_vol( fullfile(path_img, tmpFiles.name) );
f_list_length = size(tmpHdr, 1);  % number of 3d volumes
scanFiles = [];
for jx = 1:f_list_length
    scanFiles{jx,1} = [path_img '/' tmpFiles.name ',' num2str(jx) ] ; % add numbers in the end
end
matlabbatch{1}.spm.spatial.smooth.data = scanFiles;
matlabbatch{1}.spm.spatial.smooth.fwhm = smoothing;
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 's';
spm_jobman('run', matlabbatch) 
disp('wmgng run 1 smoothing is complete')

% wmgng-run2
matlabbatch = [];  % clear matlabbatch..
tmpFiles = dir(fullfile(path_img, 'sub-*task-wmgng_run-2*preproc_bold.nii'));   % find the file
tmpHdr = spm_vol( fullfile(path_img, tmpFiles.name) );
f_list_length = size(tmpHdr, 1);  % number of 3d volumes
scanFiles = [];
for jx = 1:f_list_length
    scanFiles{jx,1} = [path_img '/' tmpFiles.name ',' num2str(jx) ] ; % add numbers in the end
end
matlabbatch{1}.spm.spatial.smooth.data = scanFiles;
matlabbatch{1}.spm.spatial.smooth.fwhm = smoothing;
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 's';
spm_jobman('run', matlabbatch) 
disp('wmgng run 2 smoothing is complete')


spm_jobman('run', matlabbatch)

clear all  % clear workspace


