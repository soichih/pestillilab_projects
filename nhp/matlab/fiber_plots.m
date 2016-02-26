%% quick plot of fibers

% all fibers
allFib = fg.fibers;

% all non-zero weighted fibers
fitFib = fe.fg.fibers(fe.life.fit.weights > 0);

% load image
anat = niftiRead('antsWarp_diff.nii.gz');

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
hold on
h = mbaDisplayBrainSlice(anat, [1 0 0]);
h = mbaDisplayBrainSlice(anat, [0 1 0]);
h = mbaDisplayBrainSlice(anat, [0 0 1]);

% whole brain tracking of fitted fibers
[fh, lh] = mbaDisplayConnectome(fitFib, fh, [0.8,0.2,0], 'single');

% fibers between ROI pairs
[fh, lh] = mbaDisplayConnectome({fg.fibers{keepFL}}, fh, [0.8,0.2,0], 'single');
[fh, lh] = mbaDisplayConnectome({fg.fibers{keepFP}}, fh, [0.8,0.2,0], 'single');
[fh, lh] = mbaDisplayConnectome({fg.fibers{keepLP}}, fh, [0.8,0.2,0], 'single');

% run reorientations
%axis([-55, 50,-30, 60,-90, 60]);
xlim([-65, 65]);
%ylim([-30,60]);
zlim([-35,79]);
