function [ outs ] = fxn_mba_tracts_117large(subjectnumber, datapath, outputdir)
% Tutorial Tract Segmentation using mba
% 
% This tutorial will show how to load a series of ROI's, a whole brain
% fiber group, and perform a series of logical operations between the
% fibers in the connectome group and the ROI's, with the aim to segment a
% white matter tract. The tutorial will also show how to clean the fiber
% tract, AKA how to remove the outliers and isolate the core of the tract.
% 
% Copyright Franco Pestilli, Sam Faber, Dan Bullock, and Julian Moehlen, 
% Indiana University 2015 

% First, we will load from disk some ROI's.
%subjectnumber = '105115';
%datapath = '/N/dc2/projects/lifebid/HCP/Dan/';
%outputdir = '/N/home/d/n/dnbulloc/Karst/Desktop/Figures/';

roipath = strcat(datapath, '/105115/dt6_b2000trilin/ROIs/SLI_attempt/LeftRightSeparated');
roinames = {  ...
            {'Y0_remove_lower.mat' , 'Y-20_remove_lower.mat', 'Y-30_remove_lower.mat',...
            '117_SLF1_Left_-14_0_38_15mm.mat','117_SLF1_Left_-15_-33_38_15mm.mat', ...
            '117_SLF1_Right_-18_43_14_15mm.mat'}, ... % SLF1 Left
            {'Y0_remove_lower.mat' , 'Y-20_remove_lower.mat', 'Y-30_remove_lower.mat',...
            '117_SLF1_Right_14_0_38_15mm.mat', '117_SLF1_Right_15_-33_38_15mm.mat', ...
            '117_SLF1_Right_18_43_14_15mm.mat'}, ...% SLF1 Right
            {'Not_Sub0_Rect_Y0.mat' , 'Not_Sub10_Rect_Y-20.mat', 'Not_Sub0_Rect_Y-30.mat',...
            'Not_25Y_Plane.mat' , 'Not_Above_40Z_-45Y.mat', 'Not_Sub_10Z_Plane.mat', 'Not_Center_Sphere_15.mat', 'Left_SLF1_NOT_Sphere2.mat'...
            '117_SLF2_Left_-25_-23_35_15mm.mat' , '117_Left_SLF2_-21_5_33_15mm.mat','NOT_LeftSLF2_-25_44_8.mat'}, ... %SLF2 Left
            {'Not_Sub0_Rect_Y0.mat' , 'Not_Sub10_Rect_Y-20.mat', 'Not_Sub0_Rect_Y-30.mat','Not_Center_Sphere_15.mat','Right_SLF1_NOT_Sphere2.mat',...
            'Not_25Y_Plane.mat' , 'Not_Above_40Z_-45Y.mat', 'Not_Sub_10Z_Plane.mat',...
            '117_SLF2_Right_21_5_33_15mm.mat', '117_SLF2_Right_25_-23_35_15mm.mat', 'NOT_RightSLF2_25_44_8.mat'}, ... %SLF2 Right
            {'Y0_remove_lower.mat' , 'Y-20_remove_lower.mat', 'Y-30_remove_lower.mat',...
            '117_Left_SLF3_-36_-13_18_15mm.mat', '117_Left_SLF3_-36_19_9_15mm.mat', '117_Left_SLF3_-36_-44_22_15mm.mat', ...
            'NOT_LeftSLF3_arcuate_-42_-45_13.mat'}, ...  %SLF 3 Left
            {'Y0_remove_lower.mat' , 'Y-20_remove_lower.mat', 'Y-30_remove_lower.mat',...
            '117_Right_SLF3_36_-13_18_15mm.mat', '117_Right_SLF3_36_19_9_15mm.mat', '117_Right_SLF3_36_-44_22_15mm.mat', ...
            'NOTRightSLF3_arcuate_42_-45_13.mat'}, ... %SLF 3 Right
            {'NOT_midsagittal_slice.mat', 'NOT_vertical_slice.mat', 'AND_LH_bottom_axial.mat', ...
            'AND_LH_middle_axial.mat', strcat(subjectnumber,'_AND_LH_top_axial_lateral.mat')}, ... % LH lateral IPS tract
            {'NOT_midsagittal_slice.mat', 'NOT_vertical_slice.mat', 'AND_RH_bottom_axial.mat', ...
            'AND_RH_middle_axial.mat', strcat(subjectnumber,'_AND_RH_top_axial_lateral.mat')}, ... % RH lateral IPS tract
            {'NOT_midsagittal_slice.mat', 'NOT_vertical_slice.mat', 'AND_LH_bottom_axial.mat', ...
            'AND_LH_middle_axial.mat', strcat(subjectnumber,'_AND_LH_top_axial_medial.mat')}, ... % LH medial IPS tract
            {'NOT_midsagittal_slice.mat', 'NOT_vertical_slice.mat', 'AND_RH_bottom_axial.mat', ...
            'AND_RH_middle_axial.mat', strcat(subjectnumber,'_AND_RH_top_axial_medial.mat')}, ... % RH medial IPS tract
            }; 
            
           %  {'Y0_remove_lower.mat' , 'Y-20_remove_lower.mat', 'Y-30_remove_lower.mat',...
         %   'LeftSLF1_-13_20_50_15mm.mat', 'LeftSLF1_-14_55_12_15mm.mat', 'LeftSLF1_-15_-20_47_15mm.mat', ...
          %  'LeftSLF1_-18_0_51_15mm.mat'}, ... % SLF1 Left
         %   {'Y0_remove_lower.mat' , 'Y-20_remove_lower.mat', 'Y-30_remove_lower.mat',...
          %  'RightSLF1_13_20_50_15mm.mat', 'RightSLF1_14_55_12_15mm.mat', 'RightSLF1_15_-20_47_15mm.mat', ...
        %    'RightSLF1_18_0_51_15mm.mat'}, ...% SLF1 Right
                    %{'Y0_remove_lower.mat' , 'Y-20_remove_lower.mat', 'Y-30_remove_lower.mat',...
            %'LeftSLF2_-32_0_43_15mm.mat' , 'LeftSLF2_-34_16_40_15mm.mat', 'LeftSLF2_-30_-30_47_15mm.mat', ...
           % 'NOT_LeftSLF2_-25_44_8.mat'}, ... %SLF2 Left
          %  {'Y0_remove_lower.mat' , 'Y-20_remove_lower.mat', 'Y-30_remove_lower.mat',...
           % 'RightSLF2_32_0_43_15mm.mat', 'RightSLF2_34_16_40_15mm.mat', 'RightSLF2_30_-30_47_15mm.mat', ...
           % 'NOT_RightSLF2_25_44_8.mat'}, ... %SLF2 Right
           % {'Y0_remove_lower.mat' , 'Y-20_remove_lower.mat', 'Y-30_remove_lower.mat',...
          %  'LeftSLF3_-42_20_10_15mm.mat', 'LeftSLF3_-44_0_14_15mm.mat', 'LeftSLF3_-45_-30_29_15mm.mat', ...
           % 'NOT_LeftSLF3_arcuate_-42_-45_13.mat'}, ...  %SLF 3 Left
         %   {'Y0_remove_lower.mat' , 'Y-20_remove_lower.mat', 'Y-30_remove_lower.mat',...
         %   'RightSLF3_42_20_10_15mm.mat', 'RightSLF3_44_0_14_15mm.mat', 'RightSLF3_45_-30_29_15mm.mat', ...
         %   'NOTRightSLF3_arcuate_42_-45_13.mat'}, ... %SLF 3 Right
        
        
roioperands = { ...
                {'not','not','not','and','and','and'}, ... % SLF 1 Left
                {'not','not','not','and','and','and'}, ... % SLF 1 Right 
                {'not','not','not','not','not','not','not','not','and','and','not'}, ... % SLF 2 Left
                {'not','not','not','not','not','not','not','not','and','and','not'}, ... % SLF 2 Right
                {'not','not','not','and','and','and','not'}, ... % SLF 3 Left
                {'not','not','not','and','and','and','not'}, ... % SLF 3 Right
                {'not', 'not', 'and', 'and', 'and'}, ... % LH lateral IPS tract
                {'not', 'not', 'and', 'and', 'and'}, ... % RH lateral IPS tract 
                {'not', 'not', 'and', 'and', 'and'}, ... % LH medial IPS tract
                {'not', 'not', 'and', 'and', 'and'}, ... % RH medial IPS tract
                };
            
            %{'not','not','not','and','and','and','and'}, ... % SLF 1 Left
                %{'not','not','not','and','and','and','and'}, ... % SLF 1 Right 
            % {'not','not','not','and','and','and','not'}, ... % SLF 2 Left
           %     {'not','not','not','and','and','and','not'}, ... % SLF 2 Right
            %    {'not','not','not','and','and','and','not'}, ... % SLF 3 Left
            %    {'not','not','not','and','and','and','not'}, ... % SLF 3 Right
            
            
            
colors = {[.8 .2 .15],[.8 .2 .15],[.2 .7 .15],[.2 .7 .15],[.2 .1 .8],[.2 .1 .8],[.8 .8 .1],[.8 .8 .1],[.8 .1 .8],[.8 .1 .8]};
fibernamesfull = {'SLF_1_Left','SLF_1_Right','SLF_2_Left','SLF_2_Right','SLF_3_Left','SLF_3_Right','LH_lateral_IPS_tract','RH_lateral_IPS_tract','LH_medial_IPS_tract','LH_medial_IPS_tract'};


% Set up the path to the toolboxes needed
addpath(genpath('/N/dc2/projects/lifebid/code/mba/'))

fgpath = strcat(datapath, subjectnumber, '/fibers');
display(fgpath)
fgname = 'dwi_data_b2000_aligned_trilin_csd_lmax10_dwi_data_b2000_aligned_trilin_brainmask_dwi_data_b2000_aligned_trilin_wm_prob-500000.pdb';

% Next, we load the whole brain fiber group from file.
% Below we combine all the whole-brain fiber groups measured usign different
% tractogrpahy parameters.
fg_files = dir(fullfile(fgpath,'*2000*lmax*prob*.pdb'));
for ifg = 1:length(fg_files)
    % Load the fiber group
    fg_name = fullfile(fullfile(fgpath,fg_files(ifg).name));
    display(fg_name)

    fg = fgRead(fg_name);
    if (ifg == 1)
        fgET = fg;
    else
        fgET = fgMerge(fgET,fg,'B2000-PROB-Ensemble-Connectome');
   display(length(fgET.fibers))   
    end
    
end 
%display(length(fgET(fibers)))
% Run the LiFE model to clean the whole-brain connectome.


maxDistance = {3,3,3,3,3,3,3,3,3,3}; % normalized (std)
maxLength   = {3,3,3,3,3,3,3,3,3,3}; % normalized (std)

for itract = 1:length(roinames) % OUTER LOOP addressing SLF 1, 2 and 3
    
    % Next, we will build the full path to the files and load them.
    current.operands   = roioperands{itract};
    current.rois_path  = fullfile(roipath,roinames{itract});
    current.tract_name = fprintf('SLF%i',itract);
    current.color      = colors{itract};
    current.rois = {};
    for iroi = 1:length(current.rois_path);
        current.rois{iroi} = dtiReadRoi(current.rois_path{iroi});
    end
    disp(current.tract_name)
    tic, fprintf('\n[%s] Segmenting tract from connectome... \n','t_mba_segment_SLF')
    [SLF{itract}, ~] = feSegmentFascicleFromConnectome(fgET, current.rois, current.operands, current.tract_name);
    SLF{itract}.color = current.color;
    toc
    
    tic
    % Clean the fibers by length, fibers that too long are likely to go far
    % frontal and not just touch MT+ and parietal.
    keep = [];
    [~, keep] = mbaComputeFibersOutliers(SLF{itract},maxDistance{itract},maxLength{itract});
    fprintf('\n[%s] Found a tract with %i fibers... \n',mfilename,sum(keep))
    SLF{itract} = fgExtract(SLF{itract},find(keep),'keep');
    
    % Save the TRACT to disk:
  %  SLF{itract}.name = strcat(subjectnumber, '_fiber_',fprintf('%i',itract));
  %  fgWrite(SLF{itract},strcat(outputdir,subjectnumber,'_', fibernamesfull{itract}),'mat');
   % disp (strcat(outputdir,subjectnumber,'_', {current.tract_name}))
   % disp (strcat(outputdir,subjectnumber,'_', {itract}))
    %disp (strcat(outputdir,subjectnumber,'_', SLF{itract}))
    toc
end % END OUTER LOOP

%[major_tracts,~,~] = s_run_afq(fg, fullfile(datapath, subjectnumber, 'dt6_b2000trilin/dt6.mat'), fullfile(datapath, subjectnumber, 'afq'))

% Visualize the fiber group
anatomypath = strcat (datapath,subjectnumber, '/anatomy/');
anatomyname = 'T1w_acpc_dc_restore_1p25.nii.gz';
t1          = niftiRead(fullfile(anatomypath,anatomyname));
slices      = {[68 0 0],[0 -57 0],[0 0 -51]}; 

fh = figure('name','SLF_1_2_3_Separate','color','k'); 
hold on

h  = mbaDisplayBrainSlice(t1, slices{1});
h  = mbaDisplayBrainSlice(t1, slices{2});
h  = mbaDisplayBrainSlice(t1, slices{3});

% pre track, anatomical views
%fig.views = {[0,0],[0,90],[-90,0],[90,0]};
%light.angle = {[0,-90],[90,45],[90,-45],[-90,-45]};
%fig.names = {strcat(subjectnumber,'_-64anatOnly_coronal'), strcat(subjectnumber, '_-64anatOnly_transverse'),strcat(subjectnumber, '_-64anatOnly_LEFTsaggital'),strcat(subjectnumber, '_-64anatOnly_RIGHTsaggital')};

for iview = 1:length(fig.views)
    %lh = camlight('left');
    disp('pre view pos')
    campos
    view(fig.views{iview}(1),fig.views{iview}(2))
    lh = camlight (light.angle{iview}(1),light.angle{iview}(2));
    disp('post view pos')
    campos
    axis off
    display (iview)
    feSavefig(fh,'verbose','yes', ...
        'figName',fig.names{iview}, ...
        'figDir',outputdir, ...
        'figType','png');
    delete(lh)
end

for itract = 1:length(SLF)
    %if exist('lh','var'), delete(lh); end
    [fh, lh] = mbaDisplayConnectome(SLF{itract}.fibers,fh, SLF{itract}.color, 'single');%color{itract}

    delete(lh)
    display (itract)
    fprintf('\n %i \n',itract)
end

keyboard
% Visualize two major tracts (ILF and IFOF)
% (1) Visualize IFOF
%[fh, lh] = mbaDisplayConnectome(major_tracts(IFOF_index).fibers,fh, IFOF_color, 'single');%color{itract}
%delete(lh)
    
% (2) Visualize ILF
%[fh, lh] = mbaDisplayConnectome(major_tracts(IFL_index).fibers,fh, ILF_color, 'single');%color{itract}
%delete(lh)

% COsidernot orthogonal views.
fig.views = {[0,0],[0,90],[-90,0],[90,0]};
light.angle = {[0,-90],[90,45],[90,-45],[-90,-45]};
fig.names = {strcat(subjectnumber,'_Ver3_-57_coronal'), strcat(subjectnumber, 'Ver3_-57_transverse'),strcat(subjectnumber, '_Ver3_-57_LEFTsaggital'),strcat(subjectnumber, '_Ver3_-57_RIGHTsaggital')};

for iview = 1:length(fig.views)
    %lh = camlight('left');
    disp('pre view pos')
    campos
    view(fig.views{iview}(1),fig.views{iview}(2))
    lh = camlight (light.angle{iview}(1),light.angle{iview}(2));
    disp('post view pos')
    campos
    axis off
    display (iview)
    feSavefig(fh,'verbose','yes', ...
        'figName',fig.names{iview}, ...
        'figDir',outputdir, ...
        'figType','png');
    delete(lh)
end

close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Perform a virtual lesion: vertical parietal tract.
% display.tract = true;
% display.distributions = true;
% display.evidence = true;
% [SE(iSbj,ih), fig] = feVirtualLesion(fe,keepFascicles,display);
% clear fe
% saveFig(fig(1).fh,fullfile(saveDir,[fig(1).name, '_',hemisphere{ih}]),'eps')
% saveFig(fig(2).fh,fullfile(saveDir,[fig(2).name(1:end-4), '_',hemisphere{ih}]),'eps')
% if plotAnatomy
%     % Load the T1 file for display
%     t1     = niftiRead(t1File);
%     
%     
%     % Show the new fiber group
%     fh2 = figure(fig(ifs).fh); hold on
%     h  = mbaDisplayBrainSlice(t1, slices{1});
%     h  = mbaDisplayBrainSlice(t1, slices{2});
%     h  = mbaDisplayBrainSlice(t1, slices{3});
%     view(vw(1),vw(2)); axis(axisLims);
%     
%     close all
%     matlabpool close force local
%     
%     
%     tic, fprintf('\n[%s] Saving results of virtual lesion... \n',mfilename)
%     save(fullfile(savedir,'strength_of_evidence.mat'),'SE'); toc
%     
% end % Main function

outs = strcat('Done with ', subjectnumber);
end