!module load spm/8

restoredefaultpath
rootpath = '/N/dc2/projects/lifebid/';
addpath(genpath(fullfile(rootpath,'code/ccaiafa/Caiafa_Pestilli_paper2015/lifebid/')))
addpath(genpath(fullfile(rootpath,'code/vistasoft')))
addpath(genpath(fullfile(rootpath,'code/franpest/AFQ/')))

subject = {'FP','MP','KK','KW','HT'}; % why not JW?
runType = {'STrun01','STrun02'};
trackingType = {'DT_TENSOR_', ...
                'SD_PROB_lmax2', 'SD_STREAM_lmax2', ...
                'SD_PROB_lmax4', 'SD_STREAM_lmax4', ...
                'SD_PROB_lmax6', 'SD_STREAM_lmax6', ...
                'SD_PROB_lmax8', 'SD_STREAM_lmax8', ...
                'SD_PROB_lmax10','SD_STREAM_lmax10', ...
                'SD_PROB_lmax12','SD_STREAM_lmax12', ...
                };
fe_path      = fullfile(rootpath,'code/ccaiafa/Caiafa_Pestilli_paper2015/Results/ETC_Dec2015/Single_TC/');
tracts_path = '/N/dc2/projects/lifebid/major_tracts/';

for iTrack = 1:length(trackingType)
for isbj = 1:length(subject)
    for iRun = 1:length(runType)
        fprintf('\n Working on Subject %s Run#%i \n',subject{isbj},iRun)
        switch runType{iRun}
            case 'STrun01'
                fe_name = sprintf('fe_structure_%s_96dirs_b2000_1p5iso_STC_run01_%s.mat',subject{isbj},trackingType{iTrack});
                fasciclesClassificationSaveName = sprintf('fe_structure_%s_96dirs_b2000_1p5iso_STC_run01_500000_%s_TRACTS.mat',subject{isbj},trackingType{iTrack});
                
            case 'STrun02'
                fe_name = sprintf('fe_structure_%s_96dirs_b2000_1p5iso_STC_run02_%s.mat',subject{isbj},trackingType{iTrack});
                fasciclesClassificationSaveName = sprintf('fe_structure_%s_96dirs_b2000_1p5iso_STC_run02_500000_%s_TRACTS',subject{isbj},trackingType{iTrack});
        end
        dtFile  = fullfile(rootpath,sprintf('2t1/predator/%s_96dirs_b2000_1p5iso/dtiInit/dt6.mat',subject{isbj}));
        fe_file = fullfile(fe_path,subject{isbj},fe_name);
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
        
        fprintf('\n DONE Subject %s Run#%i \n',subject{isbj},iRun)
    end
end
end

