function t_life_connectome_build()
%%
% t_life_connectome_build()
%
% This is an example of how to build a connectome using LiFE and a
% FreeSrufer parcellation
%
% Inputs:
%  - none
%
% Outputs:
%  - none
%
% Copyright by Franco Pestilli & Brent McPherson Indiana University 2015 

%% parse arguments / define environments / build paths

% If clobber is set to 1 we will delete all files previously created
clobber = false;
fs_subject = '105115';

projPath = '/N/dc2/projects/lifebid/HCP/Brent';

anatPath = fullfile(projPath, 'anatomy');

% CHANGE THIS TO NEW ROIS
roiPath = fullfile(projPath, 'anatomy', fs_subject, 'label');
allRois = dir(fullfile(roiPath, '*.mat'));

fbrsPath = fullfile(projPath, fs_subject, 'fibers');
fbrs = {'dwi_data_b1000_aligned_trilin_csd_lmax10_dwi_data_b1000_aligned_trilin_brainmask_dwi_data_b1000_aligned_trilin_wm_prob-500000.pdb'};

% Initialize the modules and FreeSurfer variables needed for the code
% below:

out = initialize_env;
% HAS TO BE SET CORRECTLY BEFORE MATLAB LOADS
fsSubjectDir = getenv('SUBJECTS_DIR');

%% generate image files

% File all the label ROIs for this subject
labelFileNames   = dir(fullfile(fsSubjectDir, fs_subject, 'label', '*.label'));
labelRoiName     = cell(length(labelFileNames), 1);
niftiRoiFullPath = cell(length(labelFileNames), 1);
matRoiFullPath   = cell(length(labelFileNames), 1);

for il = 1:length(labelFileNames)
    labelRoiName{il}  = labelFileNames(il).name;
    niftiRoiName      = labelRoiName{il};
    niftiRoiName(niftiRoiName=='.') = '_';
    niftiRoiFullPath{il}  = fullfile(fsSubjectDir, fs_subject, 'label',  niftiRoiName);
    matRoiFullPath{il}    = [fullfile(fsSubjectDir, fs_subject, 'label',  niftiRoiName), '_smooth3mm_ROI.mat'];
end

%% generate connectome

% make combination of rROIs
% create all the combinations of the ROIs
combinations = nchoosek(1:length(labelFileNames), 2);

% load whole brain fiber group
wbfg = fgRead(fullfile(fbrsPath, fbrs{1}));

% load each ROI and find the EDGE between them
for ir = 1:length(combinations)

    % read in the ROIs
    roi1 = dtiReadRoi(fullfile(roiPath, allRois(combinations(ir, 1)).name));
    roi2 = dtiReadRoi(fullfile(roiPath, allRois(combinations(ir, 2)).name));
    
    % combine the two ROIs into a single ROI
    roi(ir) = roi1;
    roi(ir).coords = [roi1.coords; roi2.coords];
    roi(ir).name   = [roi1.name, '_to_', roi2.name];
    
    % find the edge (tract) between the nodes (rois)
    % check results of this operation, we might need to do something different.
    [EDGE(ir), ~, keep(ir), keepID(ir)] = dtiIntersectFibersWithRoi([], ['both_endpoints'], [], roi(ir), wbfg);
    
    % clean the fiber usign tract-core approach 
    % see code I gave to Dan.
    % EDGE = cleaned(EDGE);
    
end

end % end main


%% helper functions
%

function FS_SUBJECT = matchSubject2FSSUBJ(subject)
%% identify a FreeSurfer subject
switch subject
    case {'105115'}
        FS_SUBJECT = '105115';
    otherwise
        keyboard
end
end


function out = initialize_env()
%% initialize all the environments variables for analysis

% generate system command list for creating environment
out(1).cmd = 'module load fsl';
out(2).cmd = 'module load freesurfer';
out(3).cmd = 'export SUBJECTS_DIR=/N/dc2/projects/lifebid/HCP/Brent/anatomy/';
out(4).cmd = 'source /N/soft/rhel6/freesurfer/5.3.0/SetUpFreeSurfer.sh';

% run system commands
[out(1).ok, out(1).text] = system(out(1).cmd);
[out(2).ok, out(2).text] = system(out(2).cmd);
[out(3).ok, out(3).text] = system(out(3).cmd);
[out(4).ok, out(4).text] = system(out(4).cmd);

% check over output object to return warnings
for ii = 1:length(out)
    if (out(ii).ok > 0)
       warning('One of the shell comnands (%s) failed%\returning the following error %s',out(ii).cmd, out(ii).text) 
    end
end

end
