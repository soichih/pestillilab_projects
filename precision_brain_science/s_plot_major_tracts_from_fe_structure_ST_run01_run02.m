function s_plot_major_tracts_from_fe_structure_ST_run01_run02

restoredefaultpath
rootpath = '/N/dc2/projects/lifebid/';
addpath(genpath(fullfile(rootpath,'code/ccaiafa/Caiafa_Pestilli_paper2015/lifebid/')))
addpath(genpath(fullfile(rootpath,'code/vistasoft')))
addpath(genpath(fullfile(rootpath,'code/franpest/AFQ/')))
addpath(genpath(fullfile(rootpath,'code/mba/')))

subject = {'FP','MP','KK','KW','HT'}; % why not JW?
runType = {'STrun01','STrun02'};
trackingType = {'DT_TENSOR_', ...
                'SD_PROB_lmax2', 'SD_STREAM_lmax2', ...
                'SD_PROB_lmax4', 'SD_STREAM_lmax4', ...
                'SD_PROB_lmax6', 'SD_STREAM_lmax6', ...
                'SD_PROB_lmax8', 'SD_STREAM_lmax8', ...
                'SD_PROB_lmax10','SD_STREAM_lmax10', ...
                'SD_PROB_lmax12','SD_STREAM_lmax12', ...
                };
fe_path      = fullfile(rootpath,'code/ccaiafa/Caiafa_Pestilli_paper2015/Results/ETC_Dec2015/Single_TC/');
%tracts_path = '/N/dc2/projects/lifebid/major_tracts/';

for iTrack = 1:length(trackingType)
for isbj = 1:length(subject)
    for iRun = 1:length(runType)
        fprintf('\n Working on Subject %s Run#%i \n',subject{isbj},iRun)
        switch runType{iRun}
            case 'STrun01'
                fasciclesClassificationSaveName = sprintf('fe_structure_%s_96dirs_b2000_1p5iso_STC_run01_500000_%s_TRACTS.mat',subject{isbj},trackingType{iTrack});
                
            case 'STrun02'
                fasciclesClassificationSaveName = sprintf('fe_structure_%s_96dirs_b2000_1p5iso_STC_run02_500000_%s_TRACTS.mat',subject{isbj},trackingType{iTrack});
        end
        tracts_file = fullfile(fe_path,fasciclesClassificationSaveName);
        
        % Find the major tracts
        disp('Load calssification tracts...')
        load(tracts_file)
        
        % Plot the tracts
        t1File  = fullfile(rootpath,sprintf('2t1/predator/%s_96dirs_b2000_1p5iso/',subject{isbj}),'anatomy','t1.nii.gz');
        anatomy = niftiRead(t1File);
        
        savedir  = fullfile(fe_path,'major_tracts');
        mkdir(savedir);
        
        fig_name   = sprintf('%s_fig_',fasciclesClassificationSaveName);
        viewCoords = [-90,0];
        slice = [1 0 0];
        color = getColors;
        [fig_h, ~, ~] = plotFascicles(fascicles, color, slice, anatomy, viewCoords, fig_name);
        feSavefig(fig_h,'verbose','yes','figName',[fig_name, 'leftSAG'],'figDir',savedir,'figType','jpg');
        close all; drawnow
        
        viewCoords = [0,90];
        slice      = [0 0 6];
        [fig_h, ~, ~] = plotFascicles(fascicles, color, slice, anatomy, viewCoords, fig_name);
        feSavefig(fig_h,'verbose','yes','figName',[fig_name, 'AX'],'figDir',savedir,'figType','jpg');
        close all; drawnow
        
        viewCoords = [90,0];
        slice = [-1 0 0];
        [fig_h, ~, ~] = plotFascicles(fascicles, color, slice, anatomy, viewCoords, fig_name);
        feSavefig(fig_h,'verbose','yes','figName',[fig_name, 'rightSAG'],'figDir',savedir,'figType','jpg');
        close all; drawnow
        
        clear fascicles
    end
end
end

end % END MAIN FUNCTION

function [fig_h, light_h, brain_h] = plotFascicles(fascicles, color, slice, anatomy, viewCoords, fig_name)
fig_h = figure('name',fig_name,'color','k');
brain_h = mbaDisplayBrainSlice(anatomy, slice);
hold on
set(gca,'visible','off','ylim',[-108 69],'xlim',[-75 75],'zlim',[-45 78])
for iFas  = 1:length(fascicles)
    if numel(fascicles(iFas).fibers)>3
    fibers_idx = randsample(1:length(fascicles(iFas).fibers),ceil(length(fascicles(iFas).fibers)*1));
    [~, light_h] = mbaDisplayConnectome(fascicles(iFas).fibers(fibers_idx),fig_h,color{iFas},'single');
    delete(light_h)
    end
end
view(viewCoords(1),viewCoords(2))
light_h = camlight('right');
lighting phong;
%set(fig_h,'Units','normalized', 'Position',[0.5 .2 .4 .8]);
drawnow

end

function colors = getColors

% % Prepare the colors for plotting, Left HM warm, Right HM cool
% numColRes = 12;
% allColors = 1:1:numColRes;
% colormaps = {'spri ng','summer','autumn','winter','bone'};
% for iMap = 1:length(colormaps)
% %figure(iMap)
% for iFas  = 1:length(allColors)
% color{iMap, iFas} = getSmoothColor(allColors(iFas),numColRes,colormaps{iMap});
% %plot(iFas,1,'o','markerfacecolor',color{iMap, iFas},'markersize',16); hold on
% %text(iFas-.1,1,sprintf('%i',iFas),'color','w')
% end
% end
% colors = {color{1,10}, color{1,10}, color{1,5}, color{1,5}, ...
%     color{2,5}, color{2,5},   color{3,1}, color{3,1}, ...
%     color{5,8}, color{5,10},  color{3,6}, color{3,6}, ...
%     color{4,6},  color{4,6},  color{4,9},  color{4,9}, ...
%     color{2,3},  color{2,3},  color{4,3},  color{4,3}};
%
colors = {[233,150,122]./255, [233,150,122]./255, ... % Salmon
    [255,215,0]./255,   [255,215,0]./255, ... % Gold
    [64,224,208]./255,  [64,224,208]./255, ...% Turquise
    [255,99,71]./255,   [255,99,71]./255,  ...% Tomato
    [220 220 220]./255, [220 220 220]./255, ...% Gainsboro
    [220,20,60]./255,   [220,20,60]./255,   ...
    [221,160,221]./255, [221,160,221]./255, ...
    [199,21,133]./255,  [199,21,133]./255, ...
    [230,230,250]./255, [230,230,250]./255, ...
    [100,149,237]./255, [100,149,237]./255};

%figure
%for iFas  = 1:length(colors)
%plot(iFas,1,'o','markerfacecolor',colors{iFas},'markersize',16); hold on
%text(iFas-.1,1,sprintf('%i',iFas),'color','w')
%end
end

function color = getSmoothColor(colorNum,totalColors,colorMap,skipRange)

% default return color
color = [0.5 0.5 0.5];

% check arguments
if ~any(nargin == [1 2 3 4])
    help getSmoothColor
    return
end

% default arguments
if ieNotDefined('totalColors'), totalColors = 256;end
if ieNotDefined('colorMap'), colorMap = 'gray';end
if ~any(strcmp(colorMap,{'hsv','gray','pink','cool','bone','copper','flag'}))
    if ~exist(colorMap,'file')
        disp(sprintf('(getSmoothColor) Unknown colormap function %s',colorMap));
        return
    end
end
if ieNotDefined('skipRange')
    if strcmp(colorMap,'gray')
        skipRange = 0.8;
    else
        skipRange = 1;
    end
end

% get colors to choose from
if skipRange > 0
    colors = eval(sprintf('%s(ceil(totalColors*((1-skipRange)+1)))',colorMap));
else
    colors = eval(sprintf('%s(ceil(totalColors*((1+skipRange)+1)))',colorMap));
    colors = colors(end-totalColors+1:end,:);
end

% select out the right color
if (colorNum >= 1) & (colorNum <= totalColors)
    color = colors(colorNum,:);
else
    % out of bounds. Warn and return gray
    disp(sprintf('(getSmoothColor) Color %i out of bounds [1 %i]',colorNum,totalColors));
end
end

function figDir = feSavefig(h,varargin)
% Saves a figure for publishing purpose.
%
%  function figDir = savefig(h,varargin)
%
% INPUTS: Must be pairs, e.g., 'name',value
%
%   figName  - the name of the figure file.
%              Default: sprintf('feFig_%s',get(h,'Name'))
%   figDir   - Name of the subfolder where to save this figure.
%              Default: current dir ('.')
%   figType  - fig, eps, jpg, png
%              Default: 'png' fastest smallest file, low resolution.
%   verbose  - display on screen the print command being invoked.
%
% NOTES:
%   This function invokes a series of print commands:
%   print(h, '-cmyk', '-painters','-depsc2','-tiff','-r500', '-noui', 'figureName')
%
% EXAMPLE:
%   feSavefig(figureHandle,'verbose','yes','figName','myfig','figDir','/path/to/fig/folder/');
%
%
% Copyright (2016), Franco Pestilli, Indiana University, pestillifranco@gmail.com.

% set up default variables:
figName           = sprintf('feFig_%s',get(h,'Name')); % the name of the figure file
figDir            = '.'; % the subfolder where to save this figure
figType           = 'png';
verbose           = 'yes'; % 'yes', 'no', display on screen what iRun is going on

if ~isempty(varargin)
    if mod(length(varargin),2), error('varargin must be pairs'); end
    for ii=1:2:(length(varargin)-1)
        eval(sprintf('%s = ''%s'';',varargin{ii}, varargin{ii+1}));
    end
end

% make the figure dir if iRun does not exist:
if ~isdir(figDir), mkdir(figDir);end

% Create a print command that will save the figure
switch figType
    case {'png'}
        printCommand = ...
            sprintf('print(%s, ''-painters'',''-dpng'', ''-noui'', ''%s'')', ...
            num2str(h.Number),fullfile(figDir,figName));
        
    case {'jpg'}
        printCommand = ...
            sprintf('print(%s, ''-djpeg95'',''-r500'', ''-noui'', ''%s'')', ...
            num2str(h.Number),fullfile(figDir,figName));
        
    case {'eps'}
        printCommand = ...
            sprintf('print(%s, ''-cmyk'', ''-painters'',''-depsc2'',''-tiff'',''-r500'' , ''-noui'', ''%s'')', ...
            num2str(h.Number),fullfile(figDir,figName));
        
    case {'fig'}
        printCommand = ...
            sprintf('saveas(%s, ''%s'', ''fig'')', num2str(h.Number),figName);
        
    otherwise
        error('[%s] Cannot save figure with type set to: %s', mfilename,figType)
end

if strcmpi(verbose,'yes')
    fprintf('[%s] Saving eps figure %s/%s\nUsing command: \n%s...\n', ...
        mfilename,figDir,figName,printCommand);
end

% Do the printing here:
eval(printCommand);

% Delete output if iRun was nto requested
if (nargout < 1), clear figDir;end

end

