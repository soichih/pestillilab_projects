% This is a tentative script to combine a series of candidate conenctomes for a
% single subject built usign different tractography methods.
%
% Franco Pestilli Indiana University 2015.11.09

basedir = '/N/dc2/projects/lifebid/2t1/HCP/%s/fibers';
subjects = {'105115','110411','111312','113619'};

%%2T1
for is = 1:length(subjects)
tic
cd(sprintf('/N/dc2/projects/lifebid/2t1/HCP/%s/fibers',subjects{is}))
alfiles = dir('*2000*00.pdb');
for ifg = 1:length(alfiles)
            fprintf('\n Loading %i fibergroup \n',ifg)
if ifg == 1
        fgal = fgRead(alfiles(ifg).name);
    else
        fgal = fgMerge(fgal, fgRead(alfiles(ifg).name));
end
fprintf('\n DONE Loading %i fibergroup... \n', ifg)

end

disp('\n Saving ensemble fiber group to disk... \n')
fgal.name = sprintf('%s_96_b2000_ensemble_fibers.mat', subjects{is});
fgal.pathwayInfo = [];
fgWrite(fgal);
save(sprintf('%s_HCP_b2000_ensemble_fibers_orig_names.mat', subjects{is}),'alfiles','-v7.3');

% Change permissions to allow others to read/write.
eval(sprintf('!chmod 777 %s', fgal.name))
eval(sprintf('!chmod 777 %s_96_b2000_ensemble_fibers_orig_names.mat', subjects{is}))

toc

end

clear fgal
%% 2T2
basedir = '/N/dc2/projects/lifebid/2t2/HCP/%s/fibers';
subjects = {'115320','118730','117122'};

for is = 1:length(subjects)
tic
cd(sprintf('/N/dc2/projects/lifebid/2t2/HCP/%s/fibers',subjects{is}))
alfiles = dir('*2000*00.pdb');
for ifg = 1:length(alfiles)
            fprintf('\n Loading %i fibergroup \n',ifg)
if ifg == 1
        fgal = fgRead(alfiles(ifg).name);
    else
        fgal = fgMerge(fgal, fgRead(alfiles(ifg).name));
end
fprintf('\n DONE Loading %i fibergroup... \n', ifg)

end

disp('\n Saving ensemble fiber group to disk... \n')
fgal.name = sprintf('%s_96_b2000_ensemble_fibers.mat', subjects{is});
fgal.pathwayInfo = [];
fgWrite(fgal);
save(sprintf('%s_HCP_b2000_ensemble_fibers_orig_names.mat', subjects{is}),'alfiles','-v7.3');

% Change permissions to allow others to read/write.
eval(sprintf('!chmod 777 %s', fgal.name))
eval(sprintf('!chmod 777 %s_96_b2000_ensemble_fibers_orig_names.mat', subjects{is}))

toc

end