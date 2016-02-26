%% load fe of interest
load fe_prob_c1.mat
% load fe_det_c1.mat
load fe_prob_c05.mat

%function [fh, fe] = plot_LiFEres_WholeBrain()
%% (1.3) Extract the RMSE of the model on the fitted data set. 
% We now use the LiFE-BD structure and the fit to compute the error in each
% white-matter voxel spanned by the tractography model.
% prob.rmse   = feGet(fe,'vox rmse');
prob.rmse   = feGet(fe_prob_c1,'vox rmse');
prob05.rmse   = feGet(fe_prob_c05,'vox rmse');
% det.rmse   = feGet(fe_det_c1,'vox rmse');


%% (1.4) Extract the RMSE of the model on the second data set. 
% Here we show how to compute the cross-valdiated RMSE of the tractography
% model in each white-matter voxel. We store this probrmation for later use
% and to save computer memory.
% prob.rmsexv = feGetRep(fe,'vox rmse');
prob.rmsexv   = feGet(fe_prob_c1,'vox rmse');
prob05.rmsexv   = feGet(fe_prob_c05,'vox rmse');
% det.rmsexv   = feGet(fe_det_c1,'vox rmse');

%% (1.5) Extract the Rrmse. 
% We show how to extract the ratio between the model prediction error
% (RMSE) and the test-retest reliability of the data.
% prob.rrmse  = feGetRep(fe,'vox rmse ratio');
prob.rrmse   = feGetRep(fe_prob_c1,'vox rmse ratio');
prob05.rrmse   = feGetRep(fe_prob_c05,'vox rmse ratio');
% det.rrmse   = feGetRep(fe_det_c1,'vox rmse ratio');

%function [fh, fe] = life_BD_demo()
%% (1.6) Extract the fitted weights for the fascicles. 
%     The following line shows how to extract the weight assigned to each
%     fascicle in the connectome.
%     prob.w      = feGet(fe,'fiber weights');
    prob.w   = feGet(fe_prob_c1,'fiber weights');
    prob05.w   = feGet(fe_prob_c05,'fiber weights');

%     det.w   = feGet(fe_det_c1,'fiber weights');
     
    %% (1.7) Plot a histogram of the RMSE. 
    % % We plot the histogram of  RMSE across white-mater voxels.
    % [fh(1), ~, ~] = plotHistRMSE(info);
    % 
    % %% (1.8) Plot a histogram of the RMSE ratio.
    % % As a reminder the Rrmse is the ratio between data test-retest reliability
    % % and model error (the quality of the model fit).
    % [fh(2), ~] = plotHistRrmse(info);
    % 
    % %% (1.9) Plot a histogram of the fitted fascicle weights. 
    % [fh(3), ~] = plotHistWeights(info);
    % clear fe


% ---------- Local Plot Functions ----------- %
%% function [fh, rmse, rmsexv] = plotHistRMSE(info)
% Make a plot of the RMSE:
rmse   = prob.rmse;
rmse_05   = prob05.rmse;
% rmse_det= det.rmse;

figName = sprintf('%s - RMSE');%,info.tractography);
fh = mrvNewGraphWin(figName);
[y,x] = hist(rmse,50);
plot(x,y,'k-');
hold on
        [y,x] = hist(rmse_05,50);
        plot(x,y,'r-');
set(gca,'tickdir','out','fontsize',16,'box','off');
title('Root-mean squared error distribution across voxels','fontsize',16);
ylabel('number of voxels','fontsize',16);
xlabel('rmse (scanner units)','fontsize',16);
legend({'RMSE prob curv 1','RMSE prob curv 0.5'},'fontsize',16);
% legend({'RMSE fitted data set','RMSE cross-validated'},'fontsize',16);
% legend({'RMSE fitted data set'},'fontsize',16);
saveas(gcf,'RMSE_prob_1_05','fig')
saveas(gcf,'RMSE_prob_1_05','png')
%end

% %% function [fh, R] = plotHistRrmse(info)
% % Make a plot of the RMSE Ratio:
% 
% R       = prob.rrmse;
% figName = sprintf('%s - RMSE RATIO',prob.tractography);
% fh      = mrvNewGraphWin(figName);
% [y,x]   = hist(R,linspace(.5,4,50));
% plot(x,y,'k-','linewidth',2);
% hold on
% plot([median(R) median(R)],[0 1200],'r-','linewidth',2);
% plot([1 1],[0 1200],'k-');
% set(gca,'tickdir','out','fontsize',16,'box','off');
% title('Root-mean squared error ratio','fontsize',16);
% ylabel('number of voxels','fontsize',16);
% xlabel('R_{rmse}','fontsize',16);
% legend({sprintf('Distribution of R_{rmse}'),sprintf('Median R_{rmse}')});
% end

%function [fh, w] = plotHistWeights(prob)
%% Make a plot of the weights:
w       = prob.w;
w05       = prob05.w;
% w_det   = det.w;

figName = sprintf('%s - Distribution of fascicle weights');%,prob.tractography);
fh      = mrvNewGraphWin(figName);
[y,x]   = hist(w( w > 0 ),logspace(-5,-.3,40));
semilogx(x,y,'k-','linewidth',2)
set(gca,'tickdir','out','fontsize',16,'box','off')
title( ...
    sprintf('Number of fascicles candidate connectome: %2.0f\nNumber of fascicles in optimized connetome: %2.0f' ...
    ,length(w),sum(w > 0)),'fontsize',16)
ylabel('Number of fascicles','fontsize',16)
xlabel('Fascicle weight','fontsize',16)
    % add a second plot
    hold on
    [y,x]   = hist(w05( w05 > 0 ),logspace(-5,-.3,40));
    semilogx(x,y,'r-','linewidth',2)
    title( ...
    sprintf('Number of fascicles candidate connectome: %2.0f\nNumber of fascicles in optimized connetome: %2.0f\nNumber of fascicles in optimized connetome: %2.0f' ...
    ,length(w),sum(w > 0),sum(w05 > 0)),'fontsize',16)

saveas(gcf,'weights_prob_1_05','fig')
saveas(gcf,'weights_prob_1_05','png')
%end

%% Comparison plots

% compute evidence
% se = feComputeEvidence(prob.rmse_prob_c1, det.rmse_det_c1);
se = feComputeEvidence(prob.rmse, prob05.rmse);


probabalistic   = se.nolesion.rmse.all;
deterministic = se.lesion.rmse.all;

figName = sprintf('RMSE');
fh = mrvNewGraphWin(figName);
[y,x] = hist(probabalistic,50);
plot(x,y,'k-');
hold on
[y,x] = hist(deterministic,50);
plot(x,y,'r-');
set(gca,'tickdir','out','fontsize',16,'box','off');
title('Root-mean squared error distribution across voxels','fontsize',16);
ylabel('number of voxels','fontsize',16);
xlabel('rmse (scanner units)','fontsize',16);
% legend({'Probabalistic','Deterministic'},'fontsize',16);
legend({'Prob Curvature 1','Prob Curvature 0.5'},'fontsize',16);



% plots
%function fh = distributionPlotStrengthOfEvidence(se)
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
legend({'Prob Curvature 1','Prob Curvature 0.5'})
saveas(gcf,'prob_1_05_rmseVSprob','fig')
saveas(gcf,'prob_1_05_rmseVSprob','png')

%end

%function fh = distributionPlotEarthMoversDistance(se)
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
legend({'Probabilistic','Deterministic'})
%end