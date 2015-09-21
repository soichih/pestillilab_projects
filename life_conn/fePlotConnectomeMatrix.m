function [fh, c] = fePlotConnectomeMatrix(connectome_files)
%
% function [fh, c] = fePlotConnectome(connectome_files)
%
% Function to plot a connectome matrix from results saved to disk.
% 
% INPUTS 
%     - connectome_files.em     = Scalars (doubles) reporting the Earth Movers distances
%                                 computed for conenctions between 
%                                 two brain regions.
%     - conectome_files.regions = Strings reporting the names of each brain
%                                 region used to compute the correspondign 
%                                 earth movers distance.
%
% Copyright Franco Pestilli Indiana University

% Load data from file.
c.em      = dlmread(connectome_files.em);
keyboard
c.regions = load(connectome_files.regions); 

% eample of plotting matrix once I convert EMD to matrix form
figure(1,'name','connectome matrix','color','w')
imagesc(c.em);
set(gca, 'XTickLabel', c.regions);
set(gca, 'YTickLabel', c.regions);
colormap('hot');
set(gca,'tickdir','out','ticklen',[.01 .1])
keyboard
% axes are wrong, not sure how to improve
