%% quick plot of fibers

clear all, clc
load wrk_fe_prob_c1
fe = fe_prob_c1
% all fibers
allFib = fg.fibers;

% all non-zero weighted fibers
fitFib = fe.fg.fibers(fe.life.fit.weights > 0);

% load image
path='/N/dc2/projects/lifebid/Rockefeller/working/michel/';
 anat = niftiRead(strcat(path,'t2.nii.gz'));
%anat = niftiRead(strcat(path,'t1.nii.gz'));

hold on;
for ii = 1:size(allFib, 1)
    tmp = allFib{ii};
    plot3(tmp(1,:), tmp(2,:), tmp(3,:));
end
 
fh = figure();
hold on;
for ii = 1:size(fitFib, 1)
    tmp = fitFib{ii};
    plot3(tmp(1,:), tmp(2,:), tmp(3,:));
end

%% mbaDisplayConnectome

fh = figure();

fh  = mbaDisplayBrainSlice(anat, [-1 0 0]);
hold on
% whole brain tracking
[fh, lh] = mbaDisplayConnectome(fitFib, fh, [0.8,0.2,0], 'single');

% fibers between ROI pairs
[fh, lh] = mbaDisplayConnectome({fg.fibers{keepFL}}, fh, [0.8,0.2,0], 'single');
[fh, lh] = mbaDisplayConnectome({fg.fibers{keepFP}}, fh, [0.8,0.2,0], 'single');
[fh, lh] = mbaDisplayConnectome({fg.fibers{keepLP}}, fh, [0.8,0.2,0], 'single');


%axis([-55, 50,-30, 60,-90, 60]);
xlim([-65, 65]);
%ylim([-30,60]);
zlim([-35,79]);

for itract = 1:length(fitFib)
    %if exist('lh','var'), delete(lh); end
    
    %delete(lh)
    %display (itract)
    %fprintf('\n %i \n',itract)
end
