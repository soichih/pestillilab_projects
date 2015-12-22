function fg = t_merge_fiber_groups(subpath)

topdir = '/N/dc2/projects/lifebid/HCP/Brent/vss-2016/mrtrix';
ensbtk = 'ensemble_tracks';

%% load .tck files and save .mat files

files = dir(fullfile(topdir, ensbtk, '*.tck'));

for ii = 1:length(files)
    fg = dtiImportFibersMrtrix(files(ii).name);
    fgWrite(fg, fg.name, 'mat');
end
    
%% merge


