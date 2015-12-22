% cd to subject fibers/ folder

subj = {'FP_96dirs_b2000_1p5iso' 'MP_96dirs_b2000_1p5iso' ... 
    'KK_96dirs_b2000_1p5iso' 'KW_96dirs_b2000_1p5iso' 'JW_96dirs_b2000_1p5iso'};

proj='/N/dc2/projects/lifebid/2t1/predator';

for jj = 1:length(subj)
    
    cd(fullfile(proj, subj{jj}, 'fibers'));
    files = dir('run02*.tck');

    display(['Running Subject: ' subj{jj}]);
    for ii = 1:length(files)
        fg = dtiImportFibersMrtrix(files(ii).name);
        fgWrite(fg, fg.name, 'mat');
    end
    
end
