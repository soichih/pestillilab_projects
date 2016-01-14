% Tract Analysis.
%
% This script is an example of analysis of tracts that uses the profile of the tracts
% along their length and plots values of FA, MD etc. as function of position along a tract length. 
%
% Copyright Franco Pestilli Indiana University 2016
%
% Dependencis:
% addpath(genpath('~/path/to/spm8'))       % -> SPM/website
% addpath(genpath('~/path/to/vistasoft')); % -> https://www.github.com/vistalab/vistasoft
% addpath(genpath('~/path/to/life'));      % -> https://www.github.com/francopestilli/life
% addpath(genpath('~/path/to/mba'));       % -> https://www.github.com/francopestilli/mba


% 0. Set up paths to tracts files and dt6 file.
dt6path = fullfile('full/path/to/the/dt6/file/dt6.mat');
fiberGroupPath = fullfile('full/file/to/your/fiber/groups.mat');
anatomyFilePath = fullfile('/full/path/to/T1_file.nii.gz');

% 1. Load the fiber group and dt6 file.
fg = fgRead( fiberGroupPath );
dt = dtiLoadDt6( dt6path );

% 2. compute the core fiber from the fiber group (the tact profile is computed here)
[fa, md, rd, ad, cl, core] = dtiComputeDiffusionPropertiesAlongFG( fg, dt,[],[],200);
 
% 3. Select a center portion fo the tract and show the FA and MD values 
% normally we only use for analyses the middle most reliable portion of the fiber.
nodesToPlot = 50:151;

h.tpfig = figure('name', 'My tract profile','color', 'w');
plot(fa(notdesToPlot),'color', [0.2 0.2 0.9],'linewidth',4)
set(gca, 'fontsize',20, 'box','off', 'TickDir','out', ...
    'xticklabel',{'Tract begin','Tract end'},'xlim',[0 100],'ylim',[0.25 .75],'Ytick',[0 .25 .5 .75],'Xtick',[0 100])
title('Example fiber group')
xlabel('Location on tract')
ylh = ylabel('Fractional Anisotropy');
feSavefig(h.tpfig,'verbose','yes', 'figName','OpticRadiation_TP', 'figDir',TRKDIR, 'figType','jpg');

% 4. Plot the fiber group using MBA
h.fig = figure('name', 'OpticRadiation','color', 'k');
t1 = niftiRead( anatomyFilePath );

% Pick good slices as anatomical background (these will need to be changed).
slices      = {[10 0 0],[0 1 0],[0 0 -10]}; % Axial, Coronal and Sagittal slice.
hold on

% Display the three slices of anatomy selected above.
h.fig  = mbaDisplayBrainSlice(t1, slices{1});
h.fig  = mbaDisplayBrainSlice(t1, slices{2});
h.fig  = mbaDisplayBrainSlice(t1, slices{3});

% 5. Plot the core fiber by overlaying the FA values on to

% Plot all the fibers.
% [h.fig, h.light] = mbaDisplayConnectome(fg.fibers, h.fig);
% hold on 

% Plot the fiber core only.
[h.fig, h.light] = mbaDisplayConnectome(core.fibers,h.fig,[0 .25 .75],'single',[], [], 2);
axis([0 90 -110 0 -90 90])
view(0,90); camlight('left')
feSavefig(h.fig,'verbose','yes', 'figName','OpticRadiation', 'figDir',TRKDIR, 'figType','jpg');

