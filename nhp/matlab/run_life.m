%% create and fit life on NHP data
% Brent McPherson
% 20160217
%

%% Build Paths to files

data.path.topdir = '/N/dc2/projects/lifebid/Rockefeller/working';
data.path.subj   = 'michel';
data.path.fibs   = 'mrtrix';
data.file.diff   = 'dwi_b4000_60dirs_v9.nii.gz';
%data.file.anat   = 'ants_bias2dwi_diff.nii.gz';
data.file.anat   = 't2.nii.gz'; % use b0 until registration is ready
% data.file.mrtx   = 'fsl_mrtrix_csd8_curv-1_wholeBrain.tck';
% data.file.fibs   = 'fsl_mrtrix_csd8_curv-1_wholeBrain.mat';
    %%%%%% HERE WE RUN SOME TESTS TO SEE WHICH PARAMETERS WORK BETTER %%%%%
    %%% they're all whole brain 50,000/5000,000 minlength 5 %%%%%%%%%%%%%%%
%     data.file.mrtx   = 'test_prob_c1.tck';
%     data.file.fibs   = 'test_prob_c1.mat';
%     data.file.mrtx   = 'test_det_c1.tck';
%     data.file.fibs   = 'test_det_c1.mat';
%     data.file.mrtx   = 'test_prob_c05.tck';
%     data.file.fibs   = 'test_prob_c05.mat';  
    data.file.mrtx   = 'test_det_c05.tck';
    data.file.fibs   = 'test_det_c05.mat';    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

data.outs.life   = strcat(data.path.subj, '_fit_life_model.mat');

% raw diffusion file
dwiFile    = fullfile(data.path.topdir, data.path.subj, data.file.diff);

% anatomty in diffusion space
t1File     = fullfile(data.path.topdir, data.path.subj, data.file.anat);

% create fiber group - only need to run once
fg = dtiImportFibersMrtrix(fullfile(data.path.topdir, data.path.subj, data.path.fibs, data.file.mrtx));
fgWrite(fg, fullfile(data.path.topdir, data.path.subj, data.path.fibs, data.file.fibs), 'mat');

% load fiber .mat
fgFileName = fullfile(data.path.topdir, data.path.subj, data.path.fibs, data.file.fibs);

% output file name of fit model
feFileName = fullfile(data.path.topdir, data.path.subj, data.outs.life);

%% Run LiFE

% Discretization parameter
N = 360; % or 720

% build fe object
fe_det_c05 = feConnectomeInit(dwiFile, fgFileName, feFileName, [], dwiFile, t1File, N, [1,0], 0);

% fit LiFE
fe_det_c05 = feSet(fe_det_c05,'fit',feFitModel(feGet(fe_det_c05,'model'),feGet(fe_det_c05,'dsigdemeaned'),'bbnnls'));
save('fe_det_c05','fe_det_c05')
save('wrk_fe_det_c05')
%% Run a Virtual Lesion

fef = dtiImportRoiFromNifti('/N/dc2/projects/lifebid/Rockefeller/working/michel/ants_test_FEF.nii.gz', ...
                            '/N/dc2/projects/lifebid/Rockefeller/working/michel/matlab/FEF.mat');

fef = dtiImportRoiFromNifti('/N/dc2/projects/lifebid/Rockefeller/working/michel/ants_test_FEF.nii.gz', ...
                            '/N/dc2/projects/lifebid/Rockefeller/working/michel/matlab/FEF.mat');

fef = dtiImportRoiFromNifti('/N/dc2/projects/lifebid/Rockefeller/working/michel/ants_test_FEF.nii.gz', ...
                            '/N/dc2/projects/lifebid/Rockefeller/working/michel/matlab/FEF.mat');

% load a pair of ROIs in - .mat format?
roi1 = dtiReadRoi('path/to/roi1.mat');
roi2 = dtiReadRoi('path/to/roi2.mat');

% merge into single ROI
roi = roi1;
roi.coords = [roi1.coords; roi2.coords];
roi.name   = [roi1.name '_to_' roi2.name];

% load fiber group - if not already loaded
fg = fgRead('path/to/best/fg.mat');

% find indices of fibers connecting ROIs
[ EDGE, ~, keep, keepID ] = dtiIntersectFibersWithRoi([], ['both_endpoints'], [], roi, fg);

% run virtual lesion to test evidence
se = feVirtualLesion(fe, keep);
 
 