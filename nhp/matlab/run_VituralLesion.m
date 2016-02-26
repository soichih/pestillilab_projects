%% Run a Virtual Lesion

FEF = dtiImportRoiFromNifti('/N/dc2/projects/lifebid/Rockefeller/working/michel/ants_test_FEF.nii.gz', ...
                            '/N/dc2/projects/lifebid/Rockefeller/working/michel/matlab/FEF.mat');
                        
LIP = dtiImportRoiFromNifti('/N/dc2/projects/lifebid/Rockefeller/working/michel/ants_test_LIP.nii.gz', ...
                            '/N/dc2/projects/lifebid/Rockefeller/working/michel/matlab/LIP.mat');

PITd = dtiImportRoiFromNifti('/N/dc2/projects/lifebid/Rockefeller/working/michel/ants_test_PITd.nii.gz', ...
                             '/N/dc2/projects/lifebid/Rockefeller/working/michel/matlab/PITd.mat');

FEF_LIP = FEF;
FEF_LIP.coords = [ FEF.coords; LIP.coords ];
FEF_LIP.name = 'FEF_to_LIP';

FEF_PITd = FEF;
FEF_PITd.coords = [ FEF.coords; PITd.coords ];
FEF_PITd.name = 'FEF_to_PITd';

LIP_PITd = LIP;
LIP_PITd.coords = [ LIP.coords; PITd.coords ];
LIP_PITd.name = 'LIP_to_PITd';

% % load a pair of ROIs in - .mat format?
% roi1 = dtiReadRoi('path/to/roi1.mat');
% roi2 = dtiReadRoi('path/to/roi2.mat');
% 
% % merge into single ROI
% roi = roi1;
% roi.coords = [roi1.coords; roi2.coords];
% roi.name   = [roi1.name '_to_' roi2.name];

% load fiber group - if not already loaded
%fg = fgRead('path/to/best/fg.mat');

% find indices of fibers connecting ROIs
[ ~, ~, keepFL, ~ ] = dtiIntersectFibersWithRoi([], ['all'], [], FEF_LIP, fg);
[ ~, ~, keepFP, ~ ] = dtiIntersectFibersWithRoi([], ['all'], [], FEF_PITd, fg);
[ ~, ~, keepLP, ~ ] = dtiIntersectFibersWithRoi([], ['all'], [], LIP_PITd, fg);

% check that fibers are found
sum(keepFL)
sum(keepFP)
sum(keepLP)

% run virtual lesion to test evidence
% convert logicals back to indices
seFL = feVirtualLesion(fe, find(keepFL));
seFP = feVirtualLesion(fe, find(keepFP));
seLP = feVirtualLesion(fe, find(keepLP));
 