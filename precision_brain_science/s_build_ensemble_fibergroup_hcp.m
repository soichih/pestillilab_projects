% This is a tentative script to combine a series of candidate conenctomes for a
% single subject built usign different tractography methods.
%
% Franco Pestilli Indiana University 2016.01.06

basedir = '/N/dc2/projects/lifebid/2t1/HCP/%s/fibers_new';
subjects = {'105115','110411','111312','113619'};

for is = 1:length(subjects)
tic
cd(sprintf('/N/dc2/projects/lifebid/2t1/HCP/%s/fibers_new',subjects{is}))
alfiles = dir('*2000*-500000*.tck');

for ifg = 1:length(alfiles)
            fprintf('\n Loading %i of %i fibergroup',ifg,length(alfiles))
            fprintf('\n READING: %s ... ', alfiles(ifg).name)
  if ifg == 1
      fgal = dtiImportFibersMrtrix(alfiles(ifg).name);
      fgWrite(fgal,fgal.name,'mat');
  else
      fgtmp = dtiImportFibersMrtrix(alfiles(ifg).name);
      fgWrite(fgtmp,fgtmp.name,'mat');
      fgal = fgMerge(fgal, fgtmp);
  end
  fprintf('\n DONE Loading %i of %i fibergroups... ', ifg, length(alfiles))

end

disp('\n Saving ensemble fiber group to disk... ')
fgal.name = sprintf('%s_HCP_90_b2000_ensemble_fibers.mat', subjects{is});
fgal.pathwayInfo = [];
fgWrite(fgal);
save(sprintf('%s_HCP_90_b2000_ensemble_fibers_orig_names.mat', subjects{is}),'alfiles','-v7.3');

% Change permissions to allow others to read/write.
eval(sprintf('!chmod 777 %s', fgal.name))
eval(sprintf('!chmod 777 %s_HCP_90_b2000_ensemble_fibers_orig_names.mat', subjects{is}))

toc
end