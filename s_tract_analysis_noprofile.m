% Tract Analysis
%
% This script is an example of analysis of tracts. 
%
% It returns fiber values in a tab delimited text file that can be read into
% excel. The text file is saved in the baseDirectory by default.
%
%
% Copyright Franco Pestilli Indiana University 2016
%
% Dependencies:
% addpath(genpath('~/path/to/spm8'))       % -> SPM/website
% addpath(genpath('~/path/to/vistasoft')); % -> https://www.github.com/vistalab/vistasoft
% addpath(genpath('~/path/to/life'));      % -> https://www.github.com/francopestilli/life
% addpath(genpath('~/path/to/mba'));       % -> https://www.github.com/francopestilli/mba

%% Set directory structure
%% I. Directory and Subject Informatmation
% Data mus have been preprocessed using dtiInit.m (VISTASOFT)
dirs          = 'dti32trilin';
logDir = '/path/to/output/Figures';
baseDir = {'/path/to/subjects/data/'};

% Group 1 (subjects group #1)
subjects = {'name1','name2'};

% Set fiber groups (e.g. fg structures). They can be .pdb or .mat files.
fiberName = {'fibers_connecting_rois.pdb'};

%% Set up the text file that will store the fiber vals.
dateAndTime     = getDateAndTime;
textFileName    = fullfile(logDir,['out_put_log_file_name',dateAndTime,'.txt']);
[fid1 message]  = fopen(textFileName, 'w');
fprintf(fid1, 'Subject_Code \t Fiber_Name \t Mean_FA \t FA_StErr \t Mean_MD \t MD_StErr \t Mean Radial ADC \t RD StErr \t Mean Axial ADC \t AD StErr \t Number of Fibers (arb) \t Mean Length \t Min Length \t Max Length \n');

%% Run the fiber properties functions
for i = 1:numel(baseDir)
    if i == 1; subs = subjects;
    elseif i == 2; subs = subsSession2; end
    
    for ii=1:numel(subs)
        sub = dir(fullfile(baseDir{i},[subs{ii} '*']));
        if ~isempty(sub)
            subDir   = fullfile(baseDir{i},sub.name);
            dt6Dir   = fullfile(subDir,dirs);
            fiberDir = fullfile(subDir,'path/to/mrtrix/fibers');
            roiDir   = fullfile(subDir,'ROIs');
            
            dt = dtiLoadDt6(fullfile(dt6Dir,'dt6.mat'));
            
            fprintf('\nProcessing %s\n', subDir);
            
            % Read in fiber groups
            for kk=1:numel(fiberName)
                fiberGroup = fullfile(fiberDir, fiberName{kk});
                
                if exist(fiberGroup,'file')
                    disp(['Computing dtiVals for ' fiberGroup ' ...']);
                    try
                        % Read the fiber group from file
                        fg = fgRead(fiberGroup);

                        % Remove outliers from the fiber group.
                        % Outliers are fibers that are either too long or too far away
                        % from the center of mass of the fibergroup at any point along
                        % the fiber length.
                        fg = mbaRemoveFibersOutliers(fg);
                        
                        % Extract the volume (all the voxels) of the fibers. We will perform all the analyses
                        % in the voxels in this volume.
                        coords         = horzcat(fg.fibers{:})';
                        numberOfFibers = numel(fg.fibers);
                        
                        % Compute the fiber length:
                        % Measure the step size of the first fiber. Assume that the rest are all the same.
                        stepSize    = mean(sqrt(sum(diff(fg.fibers{1},1,2).^2)));
                        fiberLength = cellfun('length',fg.fibers);
                        
                        % Extract values for each fiber.
                        [val1,val2,val3,val4,val5,val6] = dtiGetValFromTensors(dt.dt6, coords, inv(dt.xformToAcpc),'dt6','nearest');
                        dt6 = [val1,val2,val3,val4,val5,val6];
                        
                        % Clean the data in two ways.
                        % Some fibers extend a little beyond the brain mask. Remove those points by
                        % exploiting the fact that the tensor values out there are exactly zero.
                        dt6 = dt6(~all(dt6==0,2),:);
                        
                        % There shouldn't be any nans, but let's make sure:
                        dt6Nans = any(isnan(dt6),2);
                        if(any(dt6Nans))
                            dt6Nans = find(dt6Nans);
                            for jj=1:6
                                dt6(dt6Nans,jj) = 0;
                            end
                            fprintf('\ NOTE: %d fiber points had NaNs. These will be ignored...',length(dt6Nans));
                            disp('Nan points (ac-pc coords):');
                            for jj=1:length(dt6Nans)
                                fprintf('%0.1f, %0.1f, %0.1f\n',coords(dt6Nans(jj),:));
                            end
                        end
                        
                        % We now have the dt6 data from all of the fibers.  We
                        % extract the directions into vec and the eigenvalues into
                        % val.  The units of val are um^2/sec or um^2/msec
                        % mrDiffusion tries to guess the original units and convert
                        % them to um^2/msec. In general, if the eigenvalues are
                        % values like 0.5 - 3.0 then they are um^2/msec. If they
                        % are more like 500 - 3000, then they are um^2/sec.
                        [vec,val] = dtiEig(dt6);
                        
                        % Some of the ellipsoid fits are wrong and we get negative eigenvalues.
                        % These are annoying. If they are just a little less than 0, then clipping
                        % to 0 is not an entirely unreasonable thing. Maybe we should check for the
                        % magnitude of the error?
                        nonPD = find(any(val<0,2));
                        if(~isempty(nonPD))
                            fprintf('\n NOTE: %d fiber points had negative eigenvalues. These will be clipped to 0...\n', numel(nonPD));
                            val(val<0) = 0;
                        end
                        
                        threeZeroVals=find(sum(val,2)==0);
                        if ~isempty (threeZeroVals)
                            fprintf('\n NOTE: %d of these fiber points had all three negative eigenvalues. These will be excluded from analyses\n', numel(threeZeroVals));
                        end
                        
                        val(threeZeroVals,:)=[];
                        
                        % Now we have the eigenvalues just from the relevant fiber positions - but
                        % all of them.  So we compute for every single node on the fibers, not just
                        % the unique nodes.
                        [fa,md,rd,ad] = dtiComputeFA(val);
                        
                        %Some voxels have all the three eigenvalues equal to zero (some of them
                        %probably because they were originally negative, and were forced to zero).
                        %These voxels will produce a NaN FA
                        FA(1)=min(fa(~isnan(fa)));
                        FA(2)=mean(fa(~isnan(fa)));
                        FA(3)=max(fa(~isnan(fa))); % isnan is needed because sometimes if all the three eigenvalues are negative, the FA becomes NaN. These voxels are noisy.
                        MD(1)=min(md);
                        MD(2)=mean(md);
                        MD(3)=max(md);
                        radialADC(1) = min(rd);
                        radialADC(2) = mean(rd);
                        radialADC(3) = max(rd);
                        axialADC(1)  = min(ad);
                        axialADC(2)  = mean(ad);
                        axialADC(3)  = max(ad);
                        fibLength(1) = mean(fiberLength)*stepSize;
                        fibLength(2) = min(fiberLength)*stepSize;
                        fibLength(3) = max(fiberLength)*stepSize;
                        
                        avgFA = FA(2);
                        avgMD = MD(2);
                        avgRD = radialADC(2);
                        avgAD = axialADC(2);
                        avgLength = fibLength(1);
                        minLength = fibLength(2);
                        maxLength = fibLength(3);
                        numFibers = numel(fg.fibers);
                        % fg.params is empty
                        % meanScore = mean(fg.params{2}.stat);
                        
                        faSTD = std(fa);
                        faSEM = faSTD/sqrt(length(fg.fibers));
                        mdSTD = std(md);
                        mdSEM = mdSTD/sqrt(length(fg.fibers));
                        rdSTD = std(rd);
                        rdSEM = rdSTD/sqrt(length(fg.fibers));
                        adSTD = std(ad);
                        adSEM = adSTD/sqrt(length(fg.fibers));
                        
                        save('data_test.mat');
                        
                        % Write out to the the stats file using the tab delimeter.
                        fprintf(fid1,'%s\t %s\t %.6f\t %.6f\t %.6f\t %.6f\t %.6f\t %.6f\t %.6f\t %.6f\t %.6f\t %.6f\t %.6f\t %.6f\t \n',...
                                subs{ii},fg.name,avgFA,faSEM,avgMD,mdSEM,avgRD,rdSEM,avgAD,adSEM,numFibers,avgLength,minLength,maxLength); %,meanScore);
%                         fprintf(fid1,'%s\t %s\t %.6f\t %.6f\t %.6f\t %.6f\n',...
%                          subs{ii},fg.name,avgFA,faSEM,avgMD,mdSEM); 
                    
                    catch ME
                      fprintf('Fiber group being skipped: %s',fiberGroup);
                        disp(ME);
                        clear ME
%                         fprintf('Can"t load the fiber group - It might be empty. Skipping.\n');
                    end
                else disp(['Fiber group: ' fiberGroup ' not found. Skipping...'])
                end
            end
        else disp('No data found.');
        end
    end
end
% save the stats file.
fclose(fid1);

disp('DONE!');
return
