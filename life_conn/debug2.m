%% figure out why this sucks - back to a script
% Brent McPherson
% 

%% Load FreeSurfer ROIs
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

% HAS TO BE SET CORRECTLY BEFORE MATLAB LOADS
fsSubjectDir = getenv('SUBJECTS_DIR');

% pull FS SUBJECTS_DIR directory
if notDefined('annotationFileName')
    annotationFileName = {'aparc.a2009s'};
end

%% load precomputed connectome
fbpath = '/N/dc2/projects/lifebid/HCP/Brent/FP_96dirs_b2000_1p5iso/connectomes/';
fbconn = 'run01_fliprot_aligned_trilin_csd_lmax10_run01_fliprot_aligned_trilin_brainmask_run01_fliprot_aligned_trilin_wm_prob-500000_recomputed_culled.mat';
load(fullfile(fbpath, fbconn), 'fe');

% old fe strucure had fe.life.fit, newer ones fe.fit. Check which one ti is
% a fix the older one. New code expects fe.fit
if isfield(fe,'life')
    fnames = fieldnames(fe.life);
    for ifield = 1:length(fnames)
        fe.(fnames{ifield}) = fe.life.(fnames{ifield});
    end
    fe = rmfield(fe,'life');
else
    error('Could not find a fit object for model');
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

%% generate combinatios of paris of ROis to build x and y of the connectome matrix
combinations = nchoosek(1:length(labelFileNames), 2);
lnCombo = size(combinations, 1);

% load whole brain fiber group
wbfg = feGet(fe,'fibers acpc');
wbfg.pathwayInfo = [];

% load two ROI, find the fibers touching them, find the core fibers and
% perform a virtual lesion
for ir = 1:length(combinations)
    
    tic
    roi1 = dtiReadRoi(fullfile(roiPath, allRois(combinations(ir, 1)).name));
    roi2 = dtiReadRoi(fullfile(roiPath, allRois(combinations(ir, 2)).name));
    display(['Loaded two nodes for pair comparison ' num2str(ir) ' of ' num2str(lnCombo)]);
    fprintf('Time taken to load Nodes %2.2f \n', toc);

    % combine the two ROIs into a single ROI
    roi(ir) = roi1;
    roi(ir).coords = [roi1.coords; roi2.coords];
    roi(ir).name   = [roi1.name '_to_' roi2.name];
    
    tic
    
    % find the edge (tract) between the nodes (rois)
    % check results of this operation, we might need to do something different.
    display(['Running: ' roi(ir).name]);
    
    % [ EDGE(ir, :), ~, keep{ir}, keepID{ir} ] = dtiIntersectFibersWithRoi([], ['both_endpoints'], [], roi(ir), wbfg);
    [ EDGE{ir}, ~, keep{ir}, keepID{ir} ] = dtiIntersectFibersWithRoi([], ['both_endpoints'], [], roi(ir), wbfg);
    
    % EDGE(ir, :).pathwayInfo = [];
    EDGE{ir}.pathwayInfo = [];
    
    fprintf('Time taken to find EDGE %2.2f \n', toc);
    
%     % Find the core of the EDGE conencting two nodes
%     ckeep = [];
%     [~, ckeep] = mbaComputeFibersOutliers(EDGE(ir, :), 3, 3);
%     EDGE_core(ir,:) = fgExtract(EDGE(ir,), find(ckeep), 'keep');
%     SLF{ir}.pathwayInfo = [];
%     keyboard
    
    % Perform a virtual lesion to extract EMD
    tic
    S{ir} = feVirtualLesion(fe, (keep{ir}));
    fprintf('Time taken to perform virtual lesion %2.2f \n', toc)
    
end

%% Extract and convert Earth Mover's Distance to matrix form

% the names of the regions
labelRoiName

em = zeros(14, 14);

for ii = 1:length(S)
    % display(EDGE{ii}.name);
    % display([labelRoiName(combinations(ii, 1)) '_to_' labelRoiName(combinations(ii, 2))]);
    em(combinations(ii, 1), combinations(ii, 2)) = S{ii}.em.mean;
    em(combinations(ii, 2), combinations(ii, 1)) = S{ii}.em.mean;
end

% write out data as columns instead of a matrix
emrow = cell(91, 3);
for jj = 1:length(S)
    emrow{jj, 1} = labelRoiName(combinations(jj, 1));
    emrow{jj, 2} = labelRoiName(combinations(jj, 2));
    tmp = S{jj}.em.mean;
    tmp = num2str(tmp);
    emrow{jj, 3} = tmp;
end

% save output
dlmwrite('em.csv', em);
dlmwrite('em_labels.csv', labelRoiName'); % does it wrong, fixed by hand b/c not worth the trouble

emout = cell2table(emrow, 'VariableNames', {'reg1', 'reg2', 'em'});
writetable(emout, 'em_rows.csv');

% eample of plotting matrix once I convert EMD to matrix form
figure('name','connectome matrix')
imagesc(em);
set(gca, 'XTickLabel', labelRoiName);
set(gca, 'YTickLabel', labelRoiName);
colormap('hot');

% axes are wrong, not sure how to improve
