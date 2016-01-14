% This scripts shows how to analyze a fiber group as a tract, by using tract profiles.
%
% Franco Pestilli Indiana University 2016


% 0. Set up paths to tracts files and dt6 file.
dt6path = fullfile('full/path/to/the/dt6/file/dt6.mat');


% 1. Plot a tract profile.
dt = dtiLoadDt6( fullfile(BASEDIR,'dt6.mat') );
[fa, md, rd, ad, cl, core] = dtiComputeDiffusionPropertiesAlongFG( fiberClean1, dt,[],[],200);
 

% 2. plot the tract profile for FA and MD
nodesToPlot = 50:151;

h.tpfig = figure('name', 'OpticRadiation_TP','color', 'w');
plot(fa(notdesToPlot),'color', [0.2 0.2 0.9],'linewidth',4)
set(gca, 'fontsize',20, 'box','off', 'TickDir','out', ...
    'xticklabel',{'LGN','V1'},'xlim',[0 100],'ylim',[0.25 .75],'Ytick',[0 .25 .5 .75],'Xtick',[0 100])
title('Tract Profile')
xlabel('Location')
ylh = ylabel('Fractional Anisotropy');
 
feSavefig(h.tpfig,'verbose','yes', 'figName','OpticRadiation_TP', 'figDir',TRKDIR, 'figType','jpg');

% 3. Plot the fiber group using MBA
h.fig = figure('name', 'OpticRadiation','color', 'k');
t1 = niftiRead(fullfile(BASEDIR, 'T1w_acpc_dc_restore_1p25.nii.gz'));

% Pick good slices as anatomical background.
slices      = {[6 0 0],[0 1 0],[0 0 -15]}; 
hold on

% Display the anatomy
h.fig  = mbaDisplayBrainSlice(t1, slices{1});
h.fig  = mbaDisplayBrainSlice(t1, slices{2});
h.fig  = mbaDisplayBrainSlice(t1, slices{3});

% Do the plotting.
[h.fig, h.light] = mbaDisplayConnectome(fiberClean1.fibers, h.fig);
hold on 

% 4 Plot the core fiber by overlaying the FA values on to
%[h.fig, h.light] = mbaDisplayConnectome(core.fibers,h.fig,[0 .25 .75],'single',[], [], 2);
axis([0 90 -110 0 -90 90])
view(0,90); camlight('left')
 
feSavefig(h.fig,'verbose','yes', 'figName','OpticRadiation', 'figDir',TRKDIR, 'figType','jpg');

