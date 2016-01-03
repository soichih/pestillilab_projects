!module load spm/8

restoredefaultpath
rootpath = '/N/dc2/projects/lifebid/';
addpath(genpath(fullfile(rootpath,'code/ccaiafa/Caiafa_Pestilli_paper2015/lifebid/')))
addpath(genpath(fullfile(rootpath,'code/vistasoft')))
addpath(genpath(fullfile(rootpath,'code/franpest/AFQ/')))

subject      = {'FP','MP','KK','KW','HT'}; % why not JW?
trackingType = {'ETrun01','ETrun02'};
fe_path      = fullfile(rootpath,'code/ccaiafa/Caiafa_Pestilli_paper2015/Results/ETC_Dec2015/ETC_full_range_lmax/');
tracts_path = '/N/dc2/projects/lifebid/major_tracts/';

for isbj = 1:length(subject)
    for it = 1:length(trackingType)
        fprintf('\n Working on Subject %s Run#%i \n',subject{isbj},it)
        switch trackingType{it}
            case 'ETrun01'
                fe_name = sprintf('fe_structure_%s_96dirs_b2000_1p5iso_ETC_run01_500000.mat',subject{isbj});
                fasciclesClassificationSaveName = sprintf('fe_structure_%s_96dirs_b2000_1p5iso_ETC_run01_500000_TRACTS.mat',subject{isbj});
                
            case 'ETrun02'
                fe_name = sprintf('fe_structure_%s_96dirs_b2000_1p5iso_ETC_run02_500000.mat',subject{isbj});
                fasciclesClassificationSaveName = sprintf('fe_structure_%s_96dirs_b2000_1p5iso_ETC_run02_500000_TRACTS',subject{isbj});
        end
        dtFile  = fullfile(rootpath,sprintf('2t1/predator/%s_96dirs_b2000_1p5iso/dtiInit/dt6.mat',subject{isbj}));
        fe_file = fullfile(fe_path,fe_name);
        tracts_file = fullfile(fe_path,fasciclesClassificationSaveName);

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
        save(tracts_file,'fg_classified','classification','fascicles','-v7.3')
        fprintf('\n\n\n Saved file: \n%s \n\n\n',fasciclesClassificationSaveName)
        clear fg_classified fascicles
        
        fprintf('\n DONE Subject %s Run#%i \n',subject{isbj},it)
    end
end

