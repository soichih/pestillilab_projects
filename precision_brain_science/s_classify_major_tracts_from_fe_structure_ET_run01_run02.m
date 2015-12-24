!module load spm/8

rootpath = '/N/dc2/projects/lifebid/';
addpath(genpath('code/ccaiafa/Caiafa_Pestilli_paper2015/lifebid/'))
subject = {'FP'};
trackingType = {'ETrun01','ETrun02'}; % Ensemble Tracking and single tracking.

for isbj = 1:length(subject)
    fe_path = fullfile(rootpath,'code/ccaiafa/Caiafa_Pestilli_paper2015/Results');
    
    for it = 1:length(trackingType)
        switch trackingType{it}
            case 'ETrun01'
                fe_name = sprintf('fe_structure_%s_96dirs_b2000_1p5iso_ETC_500000_2.mat',subject{isbj});
                fasciclesClassificationSaveName =  ...
                    fullfile(rootpath,'major_tracts', ...
                    sprintf('%s_96_ET_major_tracts_RUN01.mat',subject{isbj}));
                
            case 'ETrun02'
                fe_name = sprintf('/ETC_Dec2015/fe_structure_FP_96dirs_b2000_1p5iso_ETC_run02_500000_2.mat' ...
                    ,subject{isbj});
                fasciclesClassificationSaveName =  ...
                    fullfile(rootpath,'major_tracts', ...
                    sprintf('%s_96_ET_major_tracts_RUN02.mat',subject{isbj}));
        end
        dtFile  = fullfile(rootpath,sprintf('2t1/predator/%s_96dirs_b2000_1p5iso/dtiInit/dt6.mat',subject{isbj}));
        fe_file = fullfile(fe_path,fe_name);
        
        disp('Load FE structure...')
        load(fe_file);
        w = feGet(fe,'fiber weights');
        
        disp('Extract fibers...')
        fg = feGet(fe,'fibers acpc');        
        clear fe
        fg = fgExtract(fg, w > 0, 'keep');
        
        % Find the major tracts
        disp('Segment tracts...')
        [fg_classified,~,classification]= AFQ_SegmentFiberGroups(dtFile, fg);
        fascicles = fg2Array(fg_classified);
        clear fg
        disp('Save results to disk...')
        save(fasciclesClassificationSaveName,'fg_classified','classification','fascicles','-v7.3')
        fprintf('\n\n\n Saved file: \n%s \n\n\n',fasciclesClassificationSaveName)
        clear fg_classified fascicles
    end
    
end

