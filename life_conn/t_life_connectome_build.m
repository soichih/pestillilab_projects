function t_life_connectome_build()
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

% If clobber is set to 1 we will delete all files previously created
clobber = false;
fs_subject = 'takemura';

% Initialize the modules and FreeSurfer variables needed for the code
% below:
out = initialize_env;
fsSubjectDir = getenv('SUBJECTS_DIR');

% pull FS SUBJECTS_DIR directory
if notDefined('annotationFileName')
    annotationFileName = {'aparc.a2009s'};
end

% Create all the necessary label files
for ia = 1:length(annotationFileName)
    fs_annotationToLabelFiles(fs_subject,annotationFileName{ia},[],fsSubjectDir);
end
%keyboard

% File all the label ROIs for this subject
labelFileNames   = dir(fullfile(fsSubjectDir,fs_subject,'label','*.label'));
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

for il = 1:length(labelFileNames)
    if ~(exist([niftiRoiFullPath{il},'_smooth3mm.nii.gz'],'file')==2) || clobber
        fs_labelFileToNiftiRoi(fs_subject,labelRoiName{il},niftiRoiFullPath{il},labelFileNames(il).name(1:2),[],[],fsSubjectDir);
    else
        fprintf('[%s] Found ROI, skipping: \n%s\n',mfilename,niftiRoiFullPath{il})
    end
    if ~(exist([matRoiFullPath{il}],'file')==2) || clobber
        dtiImportRoiFromNifti([niftiRoiFullPath{il},'_smooth3mm.nii.gz'], matRoiFullPath{il});
    else
        fprintf('[%s] Found ROI, skipping: \n%s\n',mfilename,niftiRoiFullPath{il})
    end
end


% Make combination of rROis
% Compute all the combinations of the ROIs
combinations = combntns(1:length(labelFileNames),2);
    
% Load whole brain fiber group
wbfg = fgRead(fullfile(sprintf('%s',fibersPath),subjects,'fibers','fg_nae.pdb/mat'));toc

% Load each ROI and find the EDGE between them
for ir = 1:length(combinaions)
    roi1 = dtiReadRoi(fullfile(roiDir,allRois(combinations(ir,1)).name));
    roi2 = dtiReadRoi(fullfile(roiDir,allRois(combinations(ir,2)).name));
    
    % Combine the two ROIs into a single ROI
    roi(ir) = roi1;
    roi(ir).coords = [roi1.coords; roi2.coords];
    roi(ir).name   = [roi1.name, 'to', roi2.name];
    
    % Find the edge (tract) between the nodes (rois)
    % Check results of this operation, we might nee dto do somethign
    % different.
    [EDGE(ir),~, keep(ir), keepID(ir)] = dtiIntersectFibersWithRoi([],['bothendpoints'], [], roi, fg);
    
    % Clean the fiber usign tract-core approach % see code I gave to Dan.
    %EDGE = cleaned(EDGE);
end
keyboard
end % End main function

%% helper functions
function FS_SUBJECT = matchSubject2FSSUBJ(subject)
switch subject
    case {'105115'}
        FS_SUBJECT = '105115';
    otherwise
        keyboard
end
end

function out = initialize_env()
out(1).cmd = 'module load fsl';
[out(1).ok,out(1).text] = system(out(1).cmd);
out(2).cmd = 'module load freesurfer';
[out(2).ok,out(2).text] = system(out(2).cmd);
out(3).cmd = 'export SUBJECTS_DIR=/N/dc2/projects/lifebid/HCP/Brent/ap_pa_dev/freesurfer/';
[out(3).ok,out(3).text] = system(out(3).cmd);
out(4).cmd = 'source /N/soft/rhel6/freesurfer/5.3.0/SetUpFreeSurfer.sh';
[out(4).ok,out(4).text] = system(out(4).cmd);

for ii = 1:length(out)
    if (out(ii).ok > 0)
       warning('One of the shell comnands (%s) failed%\returning the following error %s',out(ii).cmd, out(ii).text) 
    end
end

end