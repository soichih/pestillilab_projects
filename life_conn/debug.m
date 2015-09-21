%% figure out why this sucks - back to a script
% Brent McPherson
% 

%% build the paths

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

fs_subject = '105115';

projPath = '/N/dc2/projects/lifebid/HCP/Brent';

anatPath = fullfile(projPath, 'anatomy');
roiPath = fullfile(projPath, 'anatomy', fs_subject, 'label');
allRois = dir(fullfile(roiPath, '*.mat'));

fbrsPath = fullfile(projPath, '105115', 'fibers');
fbrs = {'dwi_data_b1000_aligned_trilin_csd_lmax10_dwi_data_b1000_aligned_trilin_brainmask_dwi_data_b1000_aligned_trilin_wm_prob-500000.pdb'};

% HAS TO BE SET CORRECTLY BEFORE MATLAB LOADS
fsSubjectDir = getenv('SUBJECTS_DIR');

% pull FS SUBJECTS_DIR directory
if notDefined('annotationFileName')
    annotationFileName = {'aparc.a2009s'};
end

%% generate image files

% Create all the necessary label files
for ia = 1:length(annotationFileName)
    fs_annotationToLabelFiles(fs_subject, annotationFileName{ia}, [], fsSubjectDir);
end

% File all the label ROIs for this subject
labelFileNames   = dir(fullfile(fsSubjectDir,fs_subject,'label','*.label'));

% SUBSET labelFileNames and allRois
labelFileNames = labelFileNames([42:48 178:184]);
allRois = allRois([42:48 178:184]);

labelRoiName     = cell(length(labelFileNames),1);
niftiRoiFullPath = cell(length(labelFileNames),1);
matRoiFullPath  = cell(length(labelFileNames),1);

for il = 1:length(labelFileNames)
    labelRoiName{il}  = labelFileNames(il).name;
    niftiRoiName      = labelRoiName{il};
    niftiRoiName(niftiRoiName=='.') = '_';
    niftiRoiFullPath{il}  = fullfile(fsSubjectDir,fs_subject,'label',  niftiRoiName);
    matRoiFullPath{il}   = [fullfile(fsSubjectDir,fs_subject,'label',  niftiRoiName),'_smooth3mm_ROI.mat'];
end

% generate combos
combinations = nchoosek(1:length(labelFileNames), 2);

% load whole brain fiber group
wbfg = fgRead(fullfile(fbrsPath, fbrs{1}));

combinations = combinations(1:36, :);

lnCombo = size(combinations, 1)

% run the broken loop
for ir = 1:length(combinations)
    
    roi1 = dtiReadRoi(fullfile(roiPath, allRois(combinations(ir, 1)).name));
    roi2 = dtiReadRoi(fullfile(roiPath, allRois(combinations(ir, 2)).name));
    display(['Loaded both tracts for iteration ' ir ' of ' lnCombo]);
    
    % combine the two ROIs into a single ROI
    roi(ir) = roi1;
    roi(ir).coords = [roi1.coords; roi2.coords];
    roi(ir).name   = [roi1.name, '_to_', roi2.name];
    
    % find the edge (tract) between the nodes (rois)
    % check results of this operation, we might need to do something different.
    display(['Running: ' roi(ir).name]);
    [EDGE(ir, :), ~, keep(ir, :), keepID(ir, :)] = dtiIntersectFibersWithRoi([], ['both_endpoints'], [], roi(ir), wbfg);
    EDGE(ir, :).pathwayInfo = [];
    
    % clean the fiber usign tract-core approach 
    % see code I gave to Dan.
    % EDGE = cleaned(EDGE);
    
    ckeep = [];
    [~, ckeep] = mbaComputeFibersOutliers(EDGE(ir, :), 3, 3);
    EDGE_core(ir,:) = fgExtract(EDGE(ir,), find(ckeep), 'keep');
    SLF{ir}.pathwayInfo = [];
    
end

% build paths
fbpath = '/N/dc2/projects/lifebid/HCP/Brent/FP_96dirs_b2000_1p5iso/connectomes/';
fbconn = 'run01_fliprot_aligned_trilin_csd_lmax10_run01_fliprot_aligned_trilin_brainmask_run01_fliprot_aligned_trilin_wm_prob-500000_recomputed_culled.mat';

% load connectome
load(fullfile(fbpath, fbconn), 'fe');

% restructure data for newer code
if ~isfield(fe, 'fit')
    try fe.fit = fe.life.fit;
    catch error('Could not find a fit object for model');
    end
end

w = feGet(fe, 'fiber weights');
% clear w; % if it works

se = feVirtualLesion(fe, keep);
% produces output object w/ Earth Movers Distance in working connectome

% Perform a virtual leasion using LiFE
% (1) load or compute a LiFE model
% Look at the folder for this brain. There shoudl a life


% (2) Perform a virtualLesion

% (3) Extract the KL, EMD or S measures, save them for each pair of
% ROIs

