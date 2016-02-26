%% Run a Virtual Lesion

% FEF = dtiImportRoiFromNifti('/N/dc2/projects/lifebid/Rockefeller/working/michel/ants_test_FEF.nii.gz', ...
%                             '/N/dc2/projects/lifebid/Rockefeller/working/michel/matlab/FEF.mat');
%                         
% LIP = dtiImportRoiFromNifti('/N/dc2/projects/lifebid/Rockefeller/working/michel/ants_test_LIP.nii.gz', ...
%                             '/N/dc2/projects/lifebid/Rockefeller/working/michel/matlab/LIP.mat');
% 
% PITd = dtiImportRoiFromNifti('/N/dc2/projects/lifebid/Rockefeller/working/michel/ants_test_PITd.nii.gz', ...
%                              '/N/dc2/projects/lifebid/Rockefeller/working/michel/matlab/PITd.mat');
% 
% FEF_LIP = FEF;
% FEF_LIP.coords = [ FEF.coords; LIP.coords ];
% FEF_LIP.name = 'FEF_to_LIP';
% 
% FEF_PITd = FEF;
% FEF_PITd.coords = [ FEF.coords; PITd.coords ];
% FEF_PITd.name = 'FEF_to_PITd';
% 
% LIP_PITd = LIP;
% LIP_PITd.coords = [ LIP.coords; PITd.coords ];
% LIP_PITd.name = 'LIP_to_PITd';

%% load a pair of ROIs in - .mat format?
clear all, clc
roi1 = dtiReadRoi('PITd.mat'); roi1.name='PITd';
roi2 = dtiReadRoi('LIP.mat'); roi2.name='LIP';

% merge into single ROI
roi = roi1;
roi.coords = [roi1.coords; roi2.coords];
roi.name   = [roi1.name '_to_' roi2.name];

% load fiber group - if not already loaded
load wrk_fe_prob_c05.mat
% fg = fgRead('fg_prob_c05.mat');
% fg = fgRead('fg.mat');


% find indices of fibers connecting ROIs
% [ ~, ~, keepFL, ~ ] = dtiIntersectFibersWithRoi([], ['all'], [], FEF_LIP, fg);
% [ ~, ~, keepFP, ~ ] = dtiIntersectFibersWithRoi([], ['all'], [], FEF_PITd, fg);
[ ~, ~, keepLP, ~ ] = dtiIntersectFibersWithRoi([], ['all'], [], roi, fg);

% check that fibers are found
% sum(keepFL)
% sum(keepFP)
sum(keepLP)

% run virtual lesion to test evidence
% convert logicals back to indices
% seFL = feVirtualLesion(fe, find(keepFL));
% seFP = feVirtualLesion(fe, find(keepFP));
fe=fe_prob_c05;
seLP = feVirtualLesion(fe, find(keepLP));

%% plot results
se =seLP;

y_e        = se.s.unlesioned_e;
ywo_e      = se.s.lesioned_e;
dprime     = se.s.mean;
std_dprime = se.s.std;
xhis       = se.s.unlesioned.xbins;
woxhis     = se.s.lesioned.xbins;

histcolor{1} = [0 0 0];
histcolor{2} = [.95 .6 .5];
figName = sprintf('Strength_of_Evidence_test_PROB_vs_DET_model_rmse_mean_HIST');
fh = mrvNewGraphWin(figName);
patch([xhis,xhis],y_e(:),histcolor{1},'FaceColor',histcolor{1},'EdgeColor',histcolor{1});
hold on
patch([woxhis,woxhis],ywo_e(:),histcolor{2},'FaceColor',histcolor{2},'EdgeColor',histcolor{2}); 
set(gca,'tickdir','out', ...
        'box','off', ...
        'ticklen',[.025 .05], ...
        'ylim',[0 .2], ... 
        'xlim',[min(xhis) max(woxhis)], ...
        'xtick',[min(xhis) round(mean([xhis, woxhis])) max(woxhis)], ...
        'ytick',[0 .1 .2], ...
        'fontsize',16)
ylabel('Probability','fontsize',16)
xlabel('rmse','fontsize',16')

title(sprintf('Strength of evidence:\n mean %2.3f - std %2.3f',dprime,std_dprime), ...
    'FontSize',16)
legend({'No Lesion','Lesion'})
saveas(gcf,'prob_c05_les_noles_strength','fig')
saveas(gcf,'prob_c05_les_noles_strength','png')

%

prob = se.nolesion;
det  = se.lesion;
em   = se.em;

histcolor{1} = [0 0 0];
histcolor{2} = [.95 .6 .5];
figName = sprintf('EMD_PROB_DET_model_rmse_mean_HIST');
fh = mrvNewGraphWin(figName);
plot(prob.xhist,prob.hist,'r-','color',histcolor{1},'linewidth',4);
hold on
plot(det.xhist,det.hist,'r-','color',histcolor{2},'linewidth',4); 
set(gca,'tickdir','out', ...
        'box','off', ...
        'ticklen',[.025 .05], ...
        'ylim',[0 .12], ... 
        'xlim',[0 95], ...
        'xtick',[0 45 90], ...
        'ytick',[0 .06 .12], ...
        'fontsize',16)
ylabel('Proportion white-matter volume','fontsize',16)
xlabel('RMSE (raw MRI scanner units)','fontsize',16')
title(sprintf('Earth Movers Distance: %2.3f (raw scanner units)',em.mean),'FontSize',16)
legend({'No Lesion','Lesion'})
saveas(gcf,'prob_c05_les_noles_rmse','fig')
saveas(gcf,'prob_c05_les_noles_rmse','png')