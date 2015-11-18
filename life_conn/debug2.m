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
%labelFileNames = labelFileNames([42:48 178:184]);
%allRois = allRois([42:48 178:184]);

% larger SUBSET
%lregs = [ 16 18 20 28 30 32 35 46 47 63 97 99 119 ];
%rregs = lregs + 136;
%regs = [ lregs rregs ];
%labelFileNames   = labelFileNames(regs);
%allRois          = allRois(regs);

% largest SUBSET
lregs = [ 2:2:18 19:59 61:94 97 99 100:102 104:136 ];
rregs = lregs + 136;
regs = [ lregs rregs ];
labelFileNames   = labelFileNames(regs);
allRois          = allRois(regs);

% anat SUBSET
lregs = [ 100:102 104:136 ];
rregs = lregs + 136;
regs = [ lregs rregs ];
labelFileNames   = labelFileNames(regs);
allRois          = allRois(regs);

% S/G SUBSET
lregs = [ 2:2:18 19:59 61:94 97 99 ];
rregs = lregs + 136;
regs = [ lregs rregs ];
labelFileNames   = labelFileNames(regs);
allRois          = allRois(regs);

labelRoiName     = cell(length(labelFileNames),1);
niftiRoiFullPath = cell(length(labelFileNames),1);
matRoiFullPath   = cell(length(labelFileNames),1);

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

% start the parallel pool so it doesn't give up
parpool % what warnings tell me to use

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
    
    % Perform a virtual lesion to extract EMD if any fibers are kept
    if sum(keep{ir}) > 0
        tic
        S{ir} = feVirtualLesion(fe, (keep{ir}));
        fprintf('Time taken to perform virtual lesion %2.2f \n', toc)
    else
        S{ir}.em.mean = 0;
        S{ir}.s.mean = 0;
    end
    
end

%% Extract and convert Earth Mover's Distance to matrix form

% the names of the regions
%labelRoiName;

em = zeros(length(labelRoiName), length(labelRoiName));
st = zeros(length(labelRoiName), length(labelRoiName));

for ii = 1:length(S)
    % display(EDGE{ii}.name);
    % display([labelRoiName(combinations(ii, 1)) '_to_' labelRoiName(combinations(ii, 2))]);
    em(combinations(ii, 1), combinations(ii, 2)) = S{ii}.em.mean;
    em(combinations(ii, 2), combinations(ii, 1)) = S{ii}.em.mean;
end

for ii = 1:length(S)
    st(combinations(ii, 1), combinations(ii, 2)) = S{ii}.s.mean;
    st(combinations(ii, 2), combinations(ii, 1)) = S{ii}.s.mean;
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
dlmwrite('em_whole_20151025.csv', em);
dlmwrite('st_whole_20151025.csv', st);

dlmwrite('em_labels_20151018.csv', labelRoiName'); % does it wrong, fixed by hand b/c not worth the trouble

emout = cell2table(emrow, 'VariableNames', {'reg1', 'reg2', 'em'});
writetable(emout, 'em_rows.csv');

fixLabel = regexprep(labelRoiName, '.label', '');
fixLabel = regexprep(fixLabel, '.thresh', '');

%% BCT Toolbox Guesses

% set proportional / absolute thresholding
em_tha = threshold_absolute(em, 5);
em_thp = threshold_proportional(em, 0.75);

% weighted conversion
em_bin = weight_conversion(em, 'binarize');
em_nrm = weight_conversion(em, 'normalize');
em_len = weight_conversion(em, 'lengths');
em_fix = weight_conversion(em, 'autofix');

% clustering / strength / density of EM network
em_deg = degrees_und(em);
em_str = strengths_und(em);
em_den = density_und(em);

% clustering coefficient
em_ccoef = clustering_coef_wu(em);
em_clen = clustering_coef_wu(em);

% rich club / transitivity coefficient
em_rc = rich_club_wu(em);
em_tr = transitivity_wu(em);

% global efficiency
em_glb = efficiency_wei(em);
em_loc = efficiency_wei(em, 1);

% community structure
em_lov = community_louvain(em);
em_mod = modularity_und(em);

% S score - not sure it matters...
[ em_sscore, em_ssize ] = score_wu(em, 0.5);

% distance and path length
[ em_dis, em_ded ] = distance_wei(wem_len);

% node betweenness / centrality metrics
em_btw = betweenness_wei(em);
[ em_edge_btw, em_edge_cvc ] = edge_betweenness_wei(em);

em_eig = eigenvector_centrality_und(em);

% network summaries using community affiliation vector
em_pcoef = participation_coef(em, em_lov);
em_modz = module_degree_zscore(em, em_lov);

% reorder EM matrix
[ rem, remIndicies, cost ] = reorder_matrix(em, 'line', 1);

[ em_Ind, em_ord ] = reorder_mod(em, em_lov);

[ MATreord, MATind, MATcost ] = reorderMAT(em, 1000, 'line');

% backbone of  connectivity
[ bbemTree, bbPlus ] = backbone_wu(em, 5);

%% BCT Plots

% 1. Threshold more strictly and binarize
% 2. Find and recreate a matrix (as best I can) from Olaf
% 3. Figure out how to evaluate all of this

% raw EMD matrix
figure('name','EMD Connectome Matrix')
colormap('hot');
imagesc(em);
set(gca, 'YTick', 1:1:length(labelRoiName), 'YTickLabel', fixLabel);
colorbar

% absolute threshold EMD
figure('name','Abs. Thresheld EMD Connectome Matrix')
colormap('hot');
imagesc(em_tha);
set(gca, 'YTick', 1:1:length(labelRoiName), 'YTickLabel', fixLabel);
colorbar

% proportional threshold EMD
figure('name','Proportional Thresheld EMD Connectome Matrix')
colormap('hot');
imagesc(em_thp);
set(gca, 'YTick', 1:1:length(labelRoiName), 'YTickLabel', fixLabel);
colorbar

% binary EMD
figure('name','Binary EMD Connectome Matrix')
colormap('hot');
imagesc(em_bin);
set(gca, 'YTick', 1:1:length(labelRoiName), 'YTickLabel', fixLabel);
colorbar

% normalized EMD
figure('name','Normalized EMD Connectome Matrix')
colormap('hot');
imagesc(em_nrm);
set(gca, 'YTick', 1:1:length(labelRoiName), 'YTickLabel', fixLabel);
colorbar

% length of EMD
figure('name','Length EMD Connectome Matrix')
colormap('hot');
imagesc(em_len);
set(gca, 'YTick', 1:1:length(labelRoiName), 'YTickLabel', fixLabel);
colorbar

% fixed (?) EMD
figure('name','Fixed EMD Connectome Matrix')
colormap('hot');
imagesc(em_fix);
set(gca, 'YTick', 1:1:length(labelRoiName), 'YTickLabel', fixLabel);
colorbar

% S-Score of matrix
figure('name','S-Score EMD Connectome Matrix')
colormap('hot');
imagesc(em_sscore);
set(gca, 'YTick', 1:1:length(labelRoiName), 'YTickLabel', fixLabel);
colorbar

% Weighted Path based on Distance
figure('name','Weighted Path - Distance - EMD Connectome Matrix')
colormap('hot');
imagesc(em_dis);
set(gca, 'YTick', 1:1:length(labelRoiName), 'YTickLabel', fixLabel);
colorbar

% Weighted Path based on number of edges
figure('name','Weighted Path - Edges - EMD Connectome Matrix')
colormap('hot');
imagesc(em_ded);
set(gca, 'YTick', 1:1:length(labelRoiName), 'YTickLabel', fixLabel);
colorbar

% Edge betweenness in EMD matrix
figure('name','Edge Betweenness EMD Connectome Matrix')
colormap('hot');
imagesc(em_edge_btw);
set(gca, 'YTick', 1:1:length(labelRoiName), 'YTickLabel', fixLabel);
colorbar

% reordered EMD
figure('name','Reordered EMD Connectome Matrix')
colormap('hot');
imagesc(rem);
set(gca, 'YTick', 1:1:length(labelRoiName), 'YTickLabel', fixLabel(remIndicies));
colorbar

% reoder EM matrix w/ community affiliation
figure('name','Reordered Community Weighted EMD Connectome Matrix')
colormap('hot');
imagesc(em_ord);
set(gca, 'YTick', 1:1:length(labelRoiName), 'YTickLabel', fixLabel(em_Ind));
colorbar

% reorderMAT of EM
figure('name','ReorderedMAT EMD Connectome Matrix')
colormap('hot');
imagesc(MATreord);
set(gca, 'YTick', 1:1:length(labelRoiName), 'YTickLabel', fixLabel(MATind));
colorbar

% backbone tree of EM 
figure('name','Backbone Tree EMD Connectome Matrix')
colormap('hot');
imagesc(bbemTree);
set(gca, 'YTick', 1:1:length(labelRoiName), 'YTickLabel', fixLabel);
colorbar

% backbone tree + strongest connections up to average
figure('name','Backbone Plus EMD Connectome Matrix')
colormap('hot');
imagesc(bbPlus);
set(gca, 'YTick', 1:1:length(labelRoiName), 'YTickLabel', fixLabel);
colorbar

%% Original Plots 

% eample of plotting matrix once I convert EMD to matrix form
figure('name','Reordered EMD Connectome Matrix')
colormap('hot');
imagesc(em);
%set(gca, 'XTickLabel', labelRoiName);
set(gca, 'YTick', 1:1:length(labelRoiName), 'YTickLabel', fixLabel);
colorbar
feSavefig(gcf, 'figType', 'eps');

figure('name','Strength Connectome Matrix')
colormap('hot');
imagesc(st);
%set(gca, 'XTickLabel', labelRoiName);
set(gca, 'YTick', 1:1:length(labelRoiName), 'YTickLabel', fixLabel);
colorbar
feSavefig(gcf, 'figType', 'eps');

% trimmed figure
trimEM = em;
trimEM(trimEM < 5) = 0;
figure('name','EMD Connectome Matrix')
colormap('hot');
imagesc(trimEM);
%set(gca, 'XTickLabel', labelRoiName);
set(gca, 'YTick', 1:1:length(labelRoiName), 'YTickLabel', fixLabel);
colorbar
feSavefig(gcf, 'figType', 'eps');

trimST = st;
trimST(trimST < 5) = 0;
figure('name','Strength Connectome Matrix')
colormap('hot');
imagesc(trimST);
%set(gca, 'XTickLabel', labelRoiName);
set(gca, 'YTick', 1:1:length(labelRoiName), 'YTickLabel', fixLabel);
colorbar
feSavefig(gcf, 'figType', 'eps');
