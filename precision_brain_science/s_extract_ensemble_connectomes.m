% s_extract_ensemble_connectomes
%
% Example script that loads a series of Ensemble Tractogrpahy FE structures and 
% extracts the Optimized Connectomes (the complete set of non-zero weight fibers).
%
% 2016 Franco Pestilli Indiana University

rootpath = '/N/dc2/projects/lifebid/';
addpath(genpath('code/ccaiafa/Caiafa_Pestilli_paper2015/lifebid/'))
subject = {'KW','KK','HT','FP'};

for isbj = 1:length(subject)
    fe_path = fullfile(rootpath,'code/ccaiafa/Caiafa_Pestilli_paper2015/Results');
    switch subject{isbj}
    case 'FP'
           fe_name = sprintf('fe_structure_%s_96dirs_b2000_1p5iso_ETC_500000_2.mat',subject{isbj});
    otherwise
           fe_name = sprintf('fe_structure_%s_96dirs_b2000_1p5iso_ETC_500000.mat',subject{isbj});     
    end
    optimizedFiberGroupsSaveName =  ...
                fullfile(rootpath,'optimized_fascicles_groups', ...
                sprintf('%s_96_ET_major_tracts.mat',subject{isbj}));
end

disp('Load FE structure...')
fe_file = fullfile(fe_path,fe_name);
load(fe_file);

disp('Extract fibers...')
w = feGet(fe,'fiber weights');
fg = feGet(fe,'fibers acpc');        
clear fe
fg = fgExtract(fg, w > 0, 'keep');

disp('Save optimized fasciles to disk...')
save(optimizedFiberGroupsSaveName,'fg',,'-v7.3')
fprintf('\n\n\n Saved file: \n%s \n\n\n',optimizedFiberGroupsSaveName)
clear fg
end
end

