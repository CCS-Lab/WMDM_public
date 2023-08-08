% Figure 5A
% GLM 1 - model-based fMRI analysis using reward prediction error (RPE)
% For running scripts for first-level analysis

clear all;

parpool(8, 'IdleTimeout', 480);

addpath('PATH/TO/YOUR/fMRI/DATA/');
addpath('PATH/TO/YOUR/GIT/project_WMDM_public/code/');
path_data = 'PATH/TO/YOUR/fMRI/DATA/'; % Path for bids-formatted fMRI data

% subjects
subjIDs_name = {
   'sub-0004', 'sub-0006', 'sub-0011', 'sub-0014', 'sub-0025', 'sub-0028', 'sub-0037', 'sub-0039', 'sub-0044', ...
   'sub-0058', 'sub-0059', 'sub-0060', 'sub-0061', 'sub-0063', 'sub-0064', 'sub-0069', 'sub-0073', 'sub-0074', ...
   'sub-0076', 'sub-0079', 'sub-0086', 'sub-0091', 'sub-0094', 'sub-0095', 'sub-0099', 'sub-0101', 'sub-0102', ...
   'sub-0103', 'sub-0104', 'sub-0105', 'sub-0107', 'sub-0108', 'sub-0109', 'sub-0110', 'sub-0111', 'sub-0112', ...
   'sub-0118', 'sub-0119', 'sub-0121', 'sub-0122', 'sub-0123', 'sub-0125', 'sub-0126', 'sub-0127'
   };


parfor i = 1:length(subjIDs_name)
   cd( fullfile(path_data, subjIDs_name{i}) ) 
   ses = 1;
    % check even/odd. 
    % if odd, task order is GNG -> WMGNG
    % if even, task order is WMGNG -> GNG
   if rem(str2double(subjIDs_name{i}(5:8)),2) == 0
      glm1_1stLevel_even(ses)
   else
      glm1_1stLevel_odd(ses)
   end
end
