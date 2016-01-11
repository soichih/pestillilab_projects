% This file is an example for ho wto load an ensemble fiber group.
% How to add to it another fiber group.
% 
% And how to build and fit the life model using the combined fiber groups.
%
%
% Franco Pestilli, Shiloh Cooper, Dan Bullock, Indiana University

% We intialize the file path to the FG structures (fiber groups)
basedir = '/N/dc2/projects/lifebid/2t1/HCP/';
subjectID = '105115';
fascicles_folder = 'fibers_new';
et_filename = '105115_HCP_90_b2000_ensemble_fibers.mat';
et_fascicles = fullfile(basedir,subjectID,fascicles_folder,et_filename); 

% We initialize the full path to one vertical tract
basedir_vt = '/N/dc2/projects/lifebid/HCP/Dan/';
vt_folder = 'fibers/vofSLFendSNot10';
vt_filename = 'LH_lateral_IPS_tract.mat';
vt_fullpath = fullfile(basedir,subjectID,fascicles_folder,et_filename);

% Load the fiber groups and merge them (needs vistasoft)
fgWB = fgRead(et_fascicles);
fgVT = fgRead(vt_fullpath);

% Merge 
fgTotal = fgMerge(fgWB, fgVT, 'ET tracking with laterl VT');

% Build FE structure (build the LiFE model, this step requires the life repository fron brain-life)

% first input dwiFile
diffusion_data_dir = 'diffusion_data';
diffusion_data_name = 'dwi_data_b2000_aligned_trilin.nii.gz';
dwiFile = fullfile(basedir,subjectID,diffusion_data_dir, diffusion_data_name);

% Define the file name for the upcoming FE structure
feFileName = 'fe_struc_TEST_built_by_combining_ET_and_VT';

% Define the full path to the directory where we will save the FE structure
savedir = fullfile(basedir_vt,subjectID);

% Full path to the diffusion data.
anatomyFile = fullfile(basedir,subjectID,'anatomy','T1w_acpc_dc_restore_1p25.nii.gz');

% We build a LiFE model
fe = feConnectomeBuildModel(dwiFile,fgTotal,feFileName,savedir,[],anatomyFile);

% We Fit (Optimize the LiFE model) we find the weights for the fascicles.
% 
% M
% dSig,
% fitMethod
M    = feGet(fe,'mfiber');
dsig = feGet(fe,'dsigdemeaned');
fit  = feFitModel(M,dsig,'bbnnls'); % What is the FIT structure generated here?

% Add the FIT structure to the FE structure
fe = feSet(fe, 'fit', fit);

% Save FE structure to disk
fe_save_name = fullfile(savedir,feFileName);
save(fe_save_name,'fe','-v7.3')

% Virtual lesion

% END










