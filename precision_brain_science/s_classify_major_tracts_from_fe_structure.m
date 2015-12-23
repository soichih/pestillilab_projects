addpath(genpath('/N/dc2/projects/lifebid/code/ccaiafa/Caiafa_Pestilli_paper2015/lifebid/'))
addpath(genpath('/N/dc2/projects/lifebid/code/franpest/vistasoft'))
addpath(genpath('/N/dc2/projects/lifebid/code/franpest/AFQ'))

subject = {'HT','FP'};

for isbj = 1:length(subject)
fe_path = '/N/dc2/projects/lifebid/code/ccaiafa/Caiafa_Pestilli_paper2015/Results';
fe_name = sprintf('fe_structure_%s_96dirs_b2000_1p5iso_prob.mat',subject{isbj});
dtFile  = sprintf('/N/dc2/projects/lifebid/2t1/predator/%s_96dirs_b2000_1p5iso/dtiInit/dt6.mat',subject{isbj});
fe_file = fullfile(fe_path,fe_name);

disp('Load FE structure...')
load(fe_file);

disp('Extract fibers...')
fg = feGet(fe,'fibers acpc');
clear fe

% Find the major tracts
disp('Segment tracts...')
[fg_classified,~,classification]= AFQ_SegmentFiberGroups(dtFile, fg);
fascicles = fg2Array(fg_classified);
clear fg
disp('Save results to disk...')
fasciclesClassificationSaveName =  fullfile('/N/dc2/projects/lifebid/code/temp_results_4_cesar', ...
                                   sprintf('%s_96_lmax10_major_tracts.mat',subject{isbj}));
save(fasciclesClassificationSaveName,'fg_classified','classification','fascicles','-v7.3')
fprintf('\n\n\n Saved file: \n%s \n\n\n',fasciclesClassificationSaveName)
clear fg_classified fascicles
end
