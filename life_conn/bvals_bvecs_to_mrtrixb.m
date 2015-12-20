% 'FP_96dirs_b2000_1p5iso' 

%% build paths

subj = { 'MP_96dirs_b2000_1p5iso' 'HT_96dirs_b2000_1p5iso' 'KK_96dirs_b2000_1p5iso' 'KW_96dirs_b2000_1p5iso' 'JW_96dirs_b2000_1p5iso' };
stem = 'run02_fliprot_aligned_trilin';
projdir = '/N/dc2/projects/lifebid/2t1/predator';

for ii = 1:length(subj)
    bvecs = fullfile(projdir, subj{ii}, 'diffusion_data', strcat(stem, '.bvecs'));
    bvals = fullfile(projdir, subj{ii}, 'diffusion_data', strcat(stem, '.bvals'));
    out = fullfile(projdir, subj{ii}, 'fibers', strcat(stem, '.b'));
    mrtrix_bfileFromBvecs(bvecs, bvals, out);
end
    